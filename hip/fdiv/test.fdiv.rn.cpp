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

__attribute__((noinline)) __device__ float slow_fdiv_rn(float y_f32, float x_f32) {

  uint32_t rounding_mode    = 0;
  uint32_t y_u32            = *(uint32_t *)&y_f32;
  uint32_t x_u32            = *(uint32_t *)&x_f32;
  uint32_t y_exp            = (y_u32 >> 0x17) & 0xff;
  uint32_t x_exp            = (x_u32 >> 0x17) & 0xff;
  uint32_t exp_fixup        = 0;

  float    x0_f32           = x_f32;
  uint32_t &x0_u32          = *(uint32_t *)&x0_f32;
  float    y0_f32           = y_f32;
  uint32_t &y0_u32          = *(uint32_t *)&y0_f32;
  float    r0_f32           = 0.0;
  uint32_t &r0_u32          = *(uint32_t *)&r0_f32;

  float    q_f32            = 1.0;
  uint32_t &q_u32           = *(uint32_t *)&q_f32;

  /*01b0*/
  if(x_exp - 0x1 > 0xfd || y_exp - 0x1 > 0xfd){
    // x is denormal, nan, inf
    // y is denormal, nan, inf
    /*01f0*/
    bool x_is_nan = isnan(x_f32); 
    bool y_is_nan = isnan(y_f32);
    if(x_is_nan || y_is_nan){
      /*0740*/
      // return nan;
      q_u32 = 0x7fffffff; //NOTE: FADD.FTZ R3, R6, c[0x0][0x16c] ???
      return q_f32;
    }

    /*0230*/
    bool x_or_y_not_zero = false;
    x_or_y_not_zero = (((y_u32 | x_u32) & 0x7fffffff) != 0x0);
    if(!x_or_y_not_zero){
      /*0720*/
      // 0.0 / 0.0
      // return nan;
      q_u32 = 0x7fffffff; //NOTE: MUFU.RSQ R0, -QNAN ???
      return q_f32;
    }

    /*0250*/
    bool x_not_inf = !isinf(x_f32);
    bool y_not_inf = !isinf(y_f32);
    if(!x_not_inf && !y_not_inf){
      /*0720*/
      // inf / inf
      // return nan;
      q_u32 = 0x7fffffff; //NOTE: MUFU.RSQ R0, -QNAN ???
      return q_f32;
    }

    /*0290*/
    bool y_not_zero = ((y_u32 & 0x7fffffff) != 0);
    if((!x_not_inf) || (!y_not_zero)){
      /*0700*/
      // y = 0x0
      // x = 0x80000001
      // 0 / inf
      // return zero
      q_u32 = (x_u32 ^ y_u32) & 0x80000000;
      return q_f32;
    }

    /*02c0*/
    bool x_not_zero = ((x_u32 & 0x7fffffff) != 0);
    if((!x_not_zero) || (!y_not_inf)){
      /*06d0*/
      // inf / 0
      // return inf
      q_u32 = (x_u32 ^ y_u32) & 0x80000000;
      q_u32 = q_u32 | 0x7f800000;
      return q_f32;
    }

    float     denormal_fixup_f32   = 0.0;
    uint32_t  &denormal_fixup_u32  = *(uint32_t *)&denormal_fixup_f32;
    denormal_fixup_u32             = 0x5f800000;  // 2^64
    /*02f0*/
    if(y_exp != 0){
      /*0310*/
      // y is not denormal
      exp_fixup   = 0;
    }else{
      /*0320*/
      // y is denormal
      y0_f32          = y0_f32 * denormal_fixup_f32;
      exp_fixup   = -0x40;
    }
    /*0300*/
    if (x_exp == 0) {
      /*0340*/
      // x is denormal
      // y = 0x1
      // x = 0x1
      x0_f32 = x0_f32 * denormal_fixup_f32;
      exp_fixup = exp_fixup + 0x40;
    }
  }
  /*0360*/
  // scale the exp of x0 to 0x7f 0r 0x7f + 0x40
  x0_u32             = x0_u32 - ((x_exp - 0x7f) << 0x17);
  // scale the exp of y0 to 0x7f 0r 0x7f + 0x40
  y0_u32             = y0_u32 - ((y_exp - 0x7f) << 0x17);

  //exp_fixup          = y_exp - x_exp + exp_fixup;

  // NOTE: FADD.FTZ R6, -R7, -RZ
  // -x0 should to flush to zero ??
  r0_f32             = __builtin_amdgcn_rcpf(x0_f32);

  // first iteration
  float rd1_f32      = __builtin_fmaf(r0_f32, -x0_f32, 1.0);
  float r1_f32       = __builtin_fmaf(r0_f32, rd1_f32, r0_f32);

  float q0_f32       = __builtin_fmaf(y0_f32, r1_f32,  0.0);

  // second iteration
  float dq1_f32      = __builtin_fmaf(q0_f32, -x0_f32, y0_f32);
  float q1_f32       = __builtin_fmaf(r1_f32, dq1_f32, q0_f32);

  // third iteration
  float dq2_f32      = __builtin_fmaf(q1_f32, -x0_f32, y0_f32);
  float q2_rn_f32    = __builtin_fmaf(r1_f32, dq2_f32, q1_f32);

  /*0450*/
  uint32_t&q2_rn_u32 = *(uint32_t*)&q2_rn_f32;
  uint32_t q2_exp    = (q2_rn_u32 >> 0x17) & 0xff;

  float q3_f32       = q2_rn_f32;
  uint32_t&q3_u32    = *(uint32_t*)&q3_f32;
  uint32_t q_exp     = q2_exp + (y_exp - x_exp + exp_fixup);

  /*0490*/
  if (!(q_exp - 0x1 >= 0xfe)){
    /*06b0*/
    // q_exp => [1,0xfe]
    // y = 0x1
    // x = 0x1
    q_u32 = (y_exp - x_exp + exp_fixup) * 0x800000 + q2_rn_u32;
    return q_f32;
  }
  /*04b0*/
  // q_exp => (-inf,0] U [0xff, 0x7fffffff]
  if ((int32_t)q_exp > 0xfe) {
    /*0680*/
    // q_exp => [0xff, 0x7fffffff]
    // return inf
    q_u32 = (q2_rn_u32 & 0x80000000) | 0x7f800000;
    return q_f32;
  }
  /*04d0*/
  if((int32_t)q_exp >= 0x1){
    /*0750*/
    // q_exp in [0x1, 0xfe]
    // return inf
    q_f32 = q2_rn_f32;
    return q_f32;
  }
  /*04f0*/
  if (!((int32_t) q_exp >= -0x18)) {
    /*0750*/
    // q is tiny
    // return 0
    q_u32 = q2_rn_u32 & 0x80000000;
    return q_f32;
  }

  uint32_t q2_sign = q2_rn_u32 & 0x80000000;

  float q2_rz_f32;
  float q2_rd_f32;
  float q2_ru_f32;

  uint32_t &q2_rz_u32 = *(uint32_t *)&q2_rz_f32;
  uint32_t &q2_rd_u32 = *(uint32_t *)&q2_rd_f32;
  uint32_t &q2_ru_u32 = *(uint32_t *)&q2_ru_f32;

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 3\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q2_rz_f32)
               : "v"(r1_f32), "v"(dq2_f32), "v"(q1_f32));

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 2\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q2_rd_f32)
               : "v"(r1_f32), "v"(dq2_f32), "v"(q1_f32));

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 1\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q2_ru_f32)
               : "v"(r1_f32), "v"(dq2_f32), "v"(q1_f32));

  bool is_mantissa_droped  = ((q2_rz_u32 & 0x7fffff | 0x800000) << (q_exp + 0x20)) != 0;
  uint32_t number_mantissa_droped = 0;
  if (q_exp != 0) {
    number_mantissa_droped = -q_exp;
  } else {
    number_mantissa_droped = 0;
  }

  uint32_t q3_mantissa   = (q2_rz_u32 & 0x7fffff | 0x800000) >> number_mantissa_droped;
  uint32_t q_mantissa    = q3_mantissa >> 0x1;
  /*0620*/
  uint32_t mantiss_fixup = 0;
  if ((is_mantissa_droped && (q_exp != 0)) || !(q2_ru_f32 == q2_rd_f32)) {
    mantiss_fixup = 0x1;
  } else {
    mantiss_fixup = 0;
  }
  /*0630*/
  //round to neareast
  uint32_t carry_out = (mantiss_fixup | (0x1 & q_mantissa)) & q3_mantissa;
  /*0650*/
  q_u32 = q_mantissa + carry_out;
  /*0660*/
  q_u32 = q_u32 | q2_sign;
  return q_f32;
}

__device__ float fdiv_rn(float y_f32, float x_f32) {

  uint32_t y_u32            = *(uint32_t *)&y_f32;
  uint32_t x_u32            = *(uint32_t *)&x_f32;
  uint32_t y_exp            = (y_u32 << 1 >> 24);
  uint32_t x_exp            = (x_u32 << 1 >> 24);
  uint32_t fixup_exp        = 0;
  float    x0_f32           = x_f32;
  float    y0_f32           = y_f32;
  float    r0_f32           = 0.0;
  float    q_f32            = 0.0;
  uint32_t &x0_u32          = *(uint32_t *)&x0_f32;
  uint32_t &y0_u32          = *(uint32_t *)&y0_f32;
  uint32_t &r0_u32          = *(uint32_t *)&r0_f32;
  uint32_t &ret_u32         = *(uint32_t *)&q_f32;

  /*0010*/
  r0_f32  = __builtin_amdgcn_rcpf(x0_f32);
  float rd1_f32;
  float r1_f32;
  float q1_f32;
  float qd1_f32;
  /*0060*/
  rd1_f32  = __builtin_fmaf(r0_f32, -x0_f32, 1.0);
  r1_f32   = __builtin_fmaf(r0_f32, rd1_f32, r0_f32);
  q1_f32   = r1_f32 * y0_f32;
  qd1_f32  = __builtin_fmaf(q1_f32,-x0_f32, y0_f32);
  q_f32    = __builtin_fmaf(r1_f32, qd1_f32, q1_f32);
  /*0050*/
  if (x_exp - 1 < 0xfc && y_exp - 1 < 0xfe && y_exp < 0x7f + x_exp
  && y_exp > 24) {
    //0xfc = 252
    //0xfe = 254
    //exclude x_exp = 0(denormal), 0xfd, 0xfe, 0xff(nan, inf)
    //exclude y_exp = 0(denormal), 0xff(nan, inf)
    //exclude y_exp - x_exp >= 127    =>   q = inf
    return q_f32;
  }else{
    return slow_fdiv_rn(y0_f32, x0_f32);
  }
}

__global__ void test_fdiv_rn(float* out, float* x, float* y) {
	int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
	float ret = fdiv_rn(x[idx], y[idx]);
	out[idx] = ret;
}

int main(int argc, char* argv[]) {
	float tCpu, tGpu, tSharedMemGpu;
	clock_t cpuStart, cpuEnd;
	hipEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
	hipDeviceProp_t devProp;
	hipGetDeviceProperties(&devProp, 0);
	// time_t c_start, c_end;
	/* Initial input,output for the host and create memory objects for the
	 * kernel*/
	size_t griddim  = 102400;
	size_t blockdim = 1024;
	size_t batch    = 100;
	size_t batchlength = griddim * blockdim;
	float* output = (float*)malloc(batchlength * sizeof(float));
	float* input_x = (float*)malloc(batchlength * sizeof(float));
	float* input_y = (float*)malloc(batchlength * sizeof(float));
	memset(input_x, 0, batchlength * sizeof(float));
	memset(input_y, 0, batchlength * sizeof(float));
	memset(output, 0, batchlength * sizeof(float));

	// Allocate device memory
	float* inputBuffer_x;
	float* inputBuffer_y;
	float* outputBuffer;
	hipMalloc((void**)&inputBuffer_x, (batchlength) * sizeof(float));
	hipMalloc((void**)&inputBuffer_y, (batchlength) * sizeof(float));
	hipMalloc((void**)&outputBuffer, (batchlength) * sizeof(float));

	//FILE* fp_random = fopen("/home/centos/xwu/float.random.simple.txt", "r");
	FILE* fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
  //FILE* fp_ret    = fopen("/home/centos/xwu/hip__fdiv_rn.txt", "w");
  FILE* fp_ret    = fopen("/home/xwu/hip__fdiv_rn.txt", "w");
  //FILE* fp_ret = fopen("/dev/shm/hip__ddiv_rn.txt", "w");

	hipEventCreate(&gpuStart);
	hipEventCreate(&gpuEnd);
	for (int j = 0; j < batch; j++) {
		for (int i = 0; i < batchlength; i++) {
			fscanf(fp_random, "%x %x", (uint32_t*)&input_y[i], (uint32_t*)&input_x[i]);
			//printf("%lx %lx\n", *(uint64_t *)&input_x[i], *(uint64_t *)&input_y[i]);
		}

    //input_y[0] = 3.0;
    //input_x[0] = -2.0;

    // input[0]  = -0x0.0248f0000491cp-1022;
    // input[0]  = 0x1.947c0ffd28f8p+1023;
		// input[0]  = 0x0.98e1600131c2cp-1022;
		//*(uint64_t *)&input[0] = 0xfff8000000000000;
    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test_fdiv_rn, dim3(griddim), dim3(blockdim), 0, 0, outputBuffer, inputBuffer_y, inputBuffer_x);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
		for (int i = 0; i < batchlength; i++) {
			//fprintf(fp_ret, "%x %x %x\n", *(uint32_t*)&input_y[i], *(uint32_t*)&input_x[i], *(uint32_t*)&output[i]);
			fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
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
