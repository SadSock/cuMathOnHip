#include <fstream>
#include <hip/hip_runtime.h>
#include <iostream>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

using namespace std;


__device__ double __drcp_rz(double x) {

  uint32_t rounding_mode = 0;
  uint32_t rounding_mode_backup = 0;

  asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
               : "=s"(rounding_mode_backup), "=s"(rounding_mode)
               : );

  double ret = 0.0;
  double x0 = x;
  uint32_t *x0_hi = (uint32_t *)&x0 + 1;
  uint32_t *x0_lo = (uint32_t *)&x0;

  uint32_t x0_exp_bias = (*x0_hi << 1) >> 21;
  uint32_t x0_exp_true = x0_exp_bias - 0x3ff;
  uint32_t x0_exp_scale = 0;

  if (x0_exp_bias - 0x1 >
      0x7fd) { // exp - 1 > 2045  => inf, nan, denormal, zero
    if (isnan(x0)) {             // nan
      *x0_hi = *x0_hi | 0x80000; // qnan
      return x0;
    }
    if (isinf(x0)) {                // inf
      *x0_hi = *x0_hi & 0x80000000; // zero
      *x0_lo = 0x0;
      return x0;
    }
    if (x0 == 0.0) {
      *x0_hi = *x0_hi & 0x80000000; // inf
      *x0_hi = *x0_hi ^ 0x7fefffff;
      *x0_lo =          0xffffffff;
      return x0;
    }

    if (x0_exp_bias == 0x0) {               // denormal
      x0 = x0 * 1.80143985094819840000e+16; // 2^54
      x0_exp_scale = 0x36;
    } else {
      x0_exp_scale = 0x0;
    }
  }

  *x0_hi = *x0_hi - (x0_exp_true << 20);

  //get the initial rcp(x0)
  float x0_f32 = (float)x0;
  float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
  double r0 = (double)r0_f32;

  // iteration
  double d1 = __builtin_fma(-x0, r0, 1.0);
  double r1 = __builtin_fma(r0, d1, r0);
  double dd1 = d1 * d1;
  double r2 = __builtin_fma(r1, dd1, r1);
  double d2 = __builtin_fma(-x0, r2, 1.0);
  double r4 = __builtin_fma(r2, d2, r2);
  double r3 = __builtin_fma(r2, d1, r0);
  double d3 = __builtin_fma(-x0, r3, 1.0);
  double r5_rz = 0;


  rounding_mode = 0xc;
  //uint32_t rounding_mode_backup = 0;
  asm volatile(
               "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
               "v_fma_f64 %0, %2, %3, %4\n\t"
               "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %5\n\t"
               : "=v"(r5_rz)
               : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3), "s"(rounding_mode_backup));

  uint64_t *r5_lh = (uint64_t *)&r5_rz;
  uint32_t *r5_lo = (uint32_t *)&r5_rz + 0;
  uint32_t *r5_hi = (uint32_t *)&r5_rz + 1;
  uint32_t r5_mantissa = (*r5_hi << 1) >> 21;
  uint32_t r5_sign = *r5_hi & 0x80000000;

  int32_t r5_exp_true = r5_mantissa + x0_exp_scale - x0_exp_bias;
  uint32_t r5_exp_bias = r5_mantissa + x0_exp_scale - x0_exp_true;

  if (r5_exp_bias - 0x1 > 0x7fd) { // 2045
    if (r5_exp_true > 0x3ff) {     // inf
      if (r5_sign != 0) {          // negative number
        *(uint64_t *)&ret = 0xffefffffffffffff;
      } else { // positive number
        *(uint64_t *)&ret = 0x7fefffffffffffff;
      }
      return ret;
    }

    if (r5_exp_true < -0x434) { //-1076
      if (r5_sign != 0) { // negative number
        *(uint64_t *)&ret = 0x8000000000000000;
      } else { // positive number
        *(uint64_t *)&ret = 0x0000000000000001;
      }
      return ret;
    }

    uint32_t *r5_rz_lo = (uint32_t *)&r5_rz + 0;
    uint32_t *r5_rz_hi = (uint32_t *)&r5_rz + 1;

    //恢复尾数中隐含的1
    *r5_hi = *r5_hi & 0x000fffff;
    *r5_hi = *r5_hi | 0x00100000;
    *r5_lo = *r5_rz_lo;

    //计算结果的mantissa
    *r5_lh = *r5_lh >> (-r5_exp_true - 0x3fe);

    //恢复结果的exp
    *r5_hi = *r5_hi & 0x800fffff;
    //恢复结果的sign
    *r5_hi = *r5_hi | r5_sign;

    return r5_rz;
  }

  *r5_hi = *r5_hi - ((x0_exp_true - x0_exp_scale) << 20);

  return r5_rz;
}

__global__ void test_drcp(double *out, double *in) {
  int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
  out[idx] = __drcp_rz(in[idx]);
}

int main(int argc, char *argv[]) {

  hipDeviceProp_t devProp;
  hipGetDeviceProperties(&devProp, 0);
  time_t c_start, c_end;
  /* Initial input,output for the host and create memory objects for the
   * kernel*/
  size_t griddim = 10240;
  size_t blockdim = 1024;
  size_t batch = 50;
  size_t batchlength = griddim * blockdim;
  double *output = (double *)malloc(batchlength * sizeof(double));
  double *input = (double *)malloc(batchlength * sizeof(double));
  memset(input, 0, batchlength * sizeof(double));
  memset(output, 0, batchlength * sizeof(double));

  double *inputBuffer;
  double *outputBuffer;
  hipMalloc((void **)&inputBuffer, (batchlength) * sizeof(double));
  hipMalloc((void **)&outputBuffer, (batchlength) * sizeof(double));

  FILE* fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
  FILE* fp_ret    = fopen("/home/centos/xwu/hip__drcp_rz.txt", "w");

  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%la", &input[i]);
    }
    // input[0] = 0x0.8c50000118ap-1022;
    // input[0] = 0x1.947c0ffd28f8p+1023;
    //*(uint64_t *)&input[0] = 0xfff8000000000000;
    hipMemcpy(inputBuffer, input, (batchlength) * sizeof(double),
              hipMemcpyHostToDevice);
    c_start = clock();    //!< 单位为ms
    hipLaunchKernelGGL(test_drcp, dim3(griddim), dim3(blockdim), 0, 0, outputBuffer,
                       inputBuffer);
    c_end   = clock();
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    printf("The pause used %f ms by clock()\n",difftime(c_end,c_start));
    for (int i = 0; i < batchlength; i++) {
      fprintf(fp_ret, "%lx\n", *(uint64_t *)&output[i]);
    }
  }
  fclose(fp_random);
  fclose(fp_ret);
  hipFree(inputBuffer);
  hipFree(outputBuffer);
  free(input);
  free(output);

  return 0;
}
