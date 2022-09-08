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

static constexpr uint64_t neg_nan_hex = 0xfff8000000000000;
#define neg_nan (*((double*)(&neg_nan_hex)));
#define iszero(a) (a == 0.0)
#define rounding_mode_ru (0x4)
#define rounding_mode_rz (0xc)
#define rounding_mode_rd (0x8)

__device__ double ___ddiv_rz(double y, double x)
{
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;
    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );

    double x0 = x;
    double y0 = y;

    uint32_t* x0_lo = (uint32_t*)&x0 + 0;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;

    uint32_t* y0_lo = (uint32_t*)&y0 + 0;
    uint32_t* y0_hi = (uint32_t*)&y0 + 1;

    uint32_t x0_exp_bias = ((*x0_hi) << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;

    uint32_t y0_exp_bias = ((*y0_hi) << 1) >> 21;
    uint32_t y0_exp_true = y0_exp_bias - 0x3ff;
    int32_t y0_exp_scale = 0;

    uint32_t exp_diff = y0_exp_bias - x0_exp_bias;

    // process abnormal
    bool x0_abnorm = (x0_exp_bias - 1) > 0x7fd;
    bool y0_abnorm = (y0_exp_bias - 1) > 0x7fd;
    if (x0_abnorm || y0_abnorm) {
        bool x_nan = isnan(x0);
        bool y_nan = isnan(y0);

        if (y_nan) {
            *y0_hi = *y0_hi | 0x80000;
            return y0;
        }
        if (x_nan) {
            *x0_hi = *x0_hi | 0x80000;
            return x0;
        }

        bool x_zero = iszero(x0);
        bool y_zero = iszero(y0);
        if (x_zero && y_zero) {
            return neg_nan;
        }

        bool x_inf = isinf(x0);
        bool y_inf = isinf(y0);
        if (x_inf && y_inf) {
            return neg_nan;
        }

        if (y_zero || x_inf) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_lo = 0;
            return x0; // return signed zero
        }
        if (y_inf || x_zero) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_hi = (*x0_hi) ^ 0x7ff00000; // get inf
            *x0_lo = 0;
            return x0; // return signed inf
        }

        if (y0_exp_bias == 0) // y denormal
        {
            y0 = y0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = -0x36;
        }
        if (x0_exp_bias == 0) // y denormal
        {
            x0 = x0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = y0_exp_scale + 0x36;
        }
    }

    // iter
    *x0_hi = *x0_hi - (x0_exp_true << 20);
    *y0_hi = *y0_hi - (y0_exp_true << 20);

    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;

    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;

    double r2 = __builtin_fma(r1, dd1, r1);
    double s1 = r0 * y0;
    double s2 = __builtin_fma(-x0, s1, y0);

    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, s2, s1);
    double d3 = __builtin_fma(-x0, r3, y0);

    double r5_rz = 0.0;
    rounding_mode = rounding_mode_rz;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4 "
        : "=v"(r5_rz)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));

    uint64_t* r5_lh = (uint64_t*)&r5_rz;
    uint32_t* r5_lo = (uint32_t*)&r5_rz + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_rz + 1;
    uint32_t r5_exp_raw = (*r5_hi << 1) >> 21;
    uint32_t r5_exp_true = r5_exp_raw + exp_diff + y0_exp_scale;

    // r5_abnorm
    bool r5_abnorm = (r5_exp_true - 1) > 0x7fd;
    if (r5_abnorm) {
        uint32_t r5_sign = (*r5_hi) & 0x80000000;
        int32_t r5_exp_s = r5_exp_true - 0x3ff;

        double ret;
        if (r5_exp_s > 0x3ff) { // inf

            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0xffefffffffffffff;
            }
            else
            {
                *(uint64_t*)&ret = 0x7fefffffffffffff;
            }
            return ret;
        }
        else if (r5_exp_s < -0x434) // -1076
        {
            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0x8000000000000000;
            }
            else
            {
                *(uint64_t*)&ret = 0;
            }
            return ret;
        }

        // 恢复尾数中隐含的1
        *r5_hi = *r5_hi & 0x000fffff;
        *r5_hi = *r5_hi | 0x00100000;

        // 计算结果的mantisa
        *r5_lh = *r5_lh >> (1 - r5_exp_true);

        // 恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        return r5_rz;
    }

    *r5_hi = *r5_hi + ((r5_exp_true - r5_exp_raw) << 20);

    return r5_rz;
}

__global__ void test_ddiv(double *out, double *x, double *y) {
  int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
  double ret = ___ddiv_rz(x[idx], y[idx]);
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
  size_t griddim = 1024;
  size_t blockdim = 1024;
  size_t batch = 1;
  size_t batchlength = griddim * blockdim;
  double *output = (double *)malloc(batchlength * sizeof(double));
  double *input_x = (double *)malloc(batchlength * sizeof(double));
  double *input_y = (double *)malloc(batchlength * sizeof(double));
  memset(input_x, 0, batchlength * sizeof(double));
  memset(input_y, 0, batchlength * sizeof(double));
  memset(output, 0, batchlength * sizeof(double));

  double *inputBuffer_x;
  double *inputBuffer_y;
  double *outputBuffer;
  hipMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(double));
  hipMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(double));
  hipMalloc((void **)&outputBuffer, (batchlength) * sizeof(double));

  FILE *fp_random = fopen("../../float.random.txt", "r");
  FILE *fp_ret = fopen("../../hip__ddiv_rz.txt", "w");

  hipEventCreate(&gpuStart);
  hipEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%lx %lx", (uint64_t *)&input_x[i], (uint64_t *)&input_y[i]);
      //printf("%lx %lx\n", *(uint64_t *)&input_x[i], *(uint64_t *)&input_y[i]);
    }
    // input[0] = -0x0.0248f0000491cp-1022;
    //  input[0] = 0x1.947c0ffd28f8p+1023;
    // input[0] = 0x0.98e1600131c2cp-1022;
    //*(uint64_t *)&input[0] = 0xfff8000000000000;
    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test_ddiv, dim3(griddim), dim3(blockdim), 0, 0,
                       outputBuffer, inputBuffer_x, inputBuffer_y);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    // std::cout << "GPU RUN TIME : " << tGpu * 1000 << " us" << std::endl;
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    // printf("The pause used %f ms by clock()\n",difftime(c_end,c_start));
    for (int i = 0; i < batchlength; i++) {
      fprintf(fp_ret, "%lx\n", *(uint64_t *)&output[i]);
      // printf("%la, %lx\n", output[i], *(uint64_t *)&output[i]);
      // fprintf(fp_ret, "%la, %lx\n", output[i], *(uint64_t *)&output[i]);
    }
  }
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
