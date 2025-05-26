#include <cmath>
#include <cstdint>
#include <fstream>
#include <hip/hip_runtime.h>
#include <iostream>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
//#include <hip/rocrand.h>
using namespace std;

// Class mask bits

#define CLASS_SNAN 0x001
#define CLASS_QNAN 0x002
#define CLASS_NINF 0x004
#define CLASS_NNOR 0x008
#define CLASS_NSUB 0x010
#define CLASS_NZER 0x020
#define CLASS_PZER 0x040
#define CLASS_PSUB 0x080
#define CLASS_PNOR 0x100
#define CLASS_PINF 0x200


union m32{
    uint32_t u32;
    int32_t  s32;
    float    f32;
};

__device__ float __fdiv_rd(float _y, float _x) {

  m32 x0;
  m32 y0;
  m32 x1;
  m32 y1;
  m32 q, q1,q2,q3_rd,q3_ru,q3_rz,q4;
  m32 d1,d2;
  m32 x_rcp;
  uint32_t exp_fixup     = 0;
  uint32_t x0_biased_exp = 0;
  uint32_t y0_biased_exp = 0;

  x0.f32 = _x;
  y0.f32 = _y;
  x0_biased_exp = x0.u32 << 1 >> 24;
  y0_biased_exp = y0.u32 << 1 >> 24;
  x1.f32 = _x;
  y1.f32 = _y;

  /*00e0*/
  if (x0_biased_exp - 1 > 0xfd || y0_biased_exp - 1 > 0xfd) {
    // x0 is nan or inf (biased_exp = 0xff)
    // x0 is 0 or denormal (biased_exp = 0x0)
    // y0 is nan or inf (biased_exp = 0xff)
    // y0 is 0 or denormal (biased_exp = 0x0)

    /*0110*  ->   *0150*/
    if (isnan(x0.f32) || isnan(y0.f32)) {
      q.u32 = 0x7fffffff;
      return q.f32; // return qnan
    }
    /*0160*  ->   *01a0*/
    if (x0.f32 == 0.0 && y0.f32 == 0.0) { // 0.0 / 0.0
      q.u32 = 0x7fffffff;
      return q.f32; // return qnan
    } else {
      /*01c0*  ->   *01e0*/
      if (isinf(x0.f32) && isinf(y0.f32)) { // inf / inf
        q.u32 = 0x7fffffff;
        return q.f32; // return qnan
      } else {

        /*0220*  ->   *0260*/
        if (isinf(x0.f32) || y0.f32 == 0.0) { // 0 / inf
          q.u32 = (x0.u32 ^ y0.u32) & 0x80000000;
          return q.f32; // return 0
        }

        /*0270*  ->   *02c0*/
        if (isinf(y0.f32) || x0.f32 == 0.0) { // inf / 0
          q.u32 = ((x0.u32 ^ y0.u32) & 0x80000000) | 0x7f800000;
          return q.f32; // return inf
        }
      }
    }

    /*02d0*  ->   *0320*/
    if ((int32_t)y0_biased_exp - 1 >= 0) {
      y1.f32 = y0.f32;
    } else { // y0 is denormal
      m32 denormal_fixup;
      denormal_fixup.u32 = 0x5f800000; // 2^64
      exp_fixup          = -0x40; // -64
      y1.f32             = y0.f32 * denormal_fixup.f32;
    }

    /*0320*  ->   *0360*/
    if ((int32_t)x0_biased_exp - 1 >= 0) {
      x1.f32 = x0.f32;
    } else { // x0 is denormal
      m32 denormal_fixup;
      denormal_fixup.u32 = 0x5f800000; // 2^64
      exp_fixup          = exp_fixup + 0x40; // 64
      x1.f32             = x0.f32 * denormal_fixup.f32;
    }
  }

  /*0380*/
  // set the true exp of x1.f32 to 0
  // in other words, set the biased exp of x1.f32 to 0x7f
  x1.u32 = x1.u32 - ((x0_biased_exp - 0x7f) * 0x800000);

  /*03b0*/
  // set the true exp of y1.f32 to 0
  // in other words, set the biased exp of y1.f32 to 0x7f
  y1.u32 = y1.u32 - ((y0_biased_exp - 0x7f) * 0x800000);

  /*03a0*/
  x_rcp.f32 = __builtin_amdgcn_rcpf(x1.f32);

  /*03a0   -> 0410*/
  q1.f32       = __builtin_fma(y1.f32, x_rcp.f32, 0.0);
  d1.f32       = __builtin_fma(-x1.f32, q1.f32, y1.f32);
  q2.f32       = __builtin_fma(x_rcp.f32, d1.f32, q1.f32);
  d2.f32       = __builtin_fma(-x1.f32, q2.f32, y1.f32);

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 3\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q3_rz.f32)
               : "v"(x_rcp), "v"(d2.f32), "v"(q2.f32));

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 2\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q3_rd.f32)
               : "v"(x_rcp), "v"(d2.f32), "v"(q2.f32));

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 1\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q3_ru.f32)
               : "v"(x_rcp), "v"(d2.f32), "v"(q2.f32));

  uint32_t q3_rd_exp = q3_rd.u32 << 1 >> 0x18;
  uint32_t q4_rd_exp = q3_rd_exp + y0_biased_exp - x0_biased_exp;
  uint32_t q5_rd_exp = q4_rd_exp + exp_fixup;

  if (!(q5_rd_exp - 0x1 > 0xfd)) { // q is normal float number
    q.u32 = q3_rd.u32 + ((y0_biased_exp - x0_biased_exp + exp_fixup) << 23);
    return q.f32;
  }

  uint32_t q_sign = q3_rd.u32 & 0x80000000;

  if ((int32_t)q5_rd_exp > 0xfe) {                // q is inf
    // round down
    if ((q3_rd.u32 & 0x80000000) != 0x0) // q is negative ?
      q.u32 = 0x7f800000;                // inf
    else
      q.u32 = 0x7f7fffff; // the float with the largest absolute value
    q.u32 = q.u32 | q_sign;
    return q.f32;
  }

  if((int32_t)q5_rd_exp > 0x0){  // q is  not  denormal
      q.u32 = q3_rd.u32;
      return q.f32;
  }

  if ((int32_t)q5_rd_exp < -0x18) { // q is infinitesimals
    if ((q3_rd.u32 & 0x80000000) == 0x0)
      q.u32 = 0x0; // 0
    else
      q.u32 = 0x1; // the float with the lowest absolute value
    q.u32 = q.u32 | q_sign;
    return q.f32;
  }

  uint32_t q3_rz_mantissa = q3_rz.u32 & 0x7fffff;

  uint32_t hardware_rounding;
  uint32_t software_rounding;
  uint32_t rounding_fixup;

  //is mantissa drkopped by hardware
  if (q3_rd.u32 != q3_ru.u32) {
    hardware_rounding = 0x1;
  } else {
    hardware_rounding = 0x0;
  }

  q4.u32 = q3_rz_mantissa | 0x800000;

  uint32_t mantissa_dropped_software = q4.u32 << (q5_rd_exp + 0x1f);

  if (mantissa_dropped_software == 0){
    software_rounding = 0x0;
  }else{
    software_rounding = 0x1;
  }

  /*0680*  -> *06f0*/
  if ((software_rounding|hardware_rounding)!= 0 && q_sign != 0){
    rounding_fixup = 0x1;
  }else{
    rounding_fixup = 0x0;
  }

  q.u32 = q4.u32 >> (0x1 - q5_rd_exp);
  q.u32 = q.u32 + rounding_fixup;
  q.u32 = q.u32 | q_sign;

  return q.f32;
}

__global__ void test__fdiv_rd(float *out, float *y, float *x) {
  int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
  //printf("%a, %a\n", y[idx], x[idx]);
  float ret = __fdiv_rd(y[idx], x[idx]);
  out[idx] = ret;
}

int main(int argc, char *argv[]) {
  float tCpu, tGpu, tSharedMemGpu;
  clock_t cpuStart, cpuEnd;
  hipEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  hipDeviceProp_t devProp;
  hipGetDeviceProperties(&devProp, 0);
  // time_t c_start, c_end;
  /* Initial input,output for the host and create memory objects for the
   * kernel*/
  size_t  griddim     = 1024;
  size_t  blockdim    = 640;
  size_t  batch       = 5000;
  size_t  batchlength = griddim * blockdim;
  float  *output      = (float *)malloc(batchlength * sizeof(float));
  float  *input_x     = (float *)malloc(batchlength * sizeof(float));
  float  *input_y     = (float *)malloc(batchlength * sizeof(float));
  memset(input_x, 0, batchlength * sizeof(float));
  memset(input_y, 0, batchlength * sizeof(float));
  memset(output, 0, batchlength * sizeof(float));

  // Allocate device memory
  float *inputBuffer_x;
  float *inputBuffer_y;
  float *outputBuffer;
  hipMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(float));
  hipMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(float));
  hipMalloc((void **)&outputBuffer, (batchlength) * sizeof(float));

  FILE* fp_random    = fopen("/home/xwu/float.random.txt", "r");
  FILE* fp_ret       = fopen("/home/xwu/hip__fdiv_rd.txt", "w");
  //	FILE* fp_ret = fopen("/dev/shm/hip__ddiv_rn.txt", "w");

  hipEventCreate(&gpuStart);
  hipEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%x %x", (uint32_t*)&input_y[i],(uint32_t*)&input_x[i]);
      //printf("%lx %lx\n", *(uint64_t *)&input_x[i], *(uint64_t *)&input_y[i]);
    }

    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test__fdiv_rd, dim3(griddim), dim3(blockdim), 0, 0,
                       outputBuffer, inputBuffer_y, inputBuffer_x);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    for (int i = 0; i < batchlength; i++) {
        fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
      //printf("%x\n", *(uint32_t *)&output[i]);
    }
  }

  // Cleanup after kernel execution
  fclose(fp_random);
  fclose(fp_ret);
  hipFree(inputBuffer_x);
  hipFree(inputBuffer_y);
  hipFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);

  return 0;
}
