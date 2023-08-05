#include <cstdint>
#include <math.h>
#include <hip/hip_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "logf.h"
using namespace std;

__global__ void test_logf(float *out, float *x) {
    int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
    m32 ret0, ret1;
    ret0.f32 = _ZN4maca4logfEf(x[idx]);
    ret1.f32 = logf(x[idx]);


    int64_t ulp =  std::abs((int64_t)ret0.u32 - (int64_t)ret1.u32);
    if(ulp > 2){
        printf("%x %x ulp =%ld\n", ret0.u32, ret1.u32,  ulp);
    }
    
    out[idx] = ret0.f32 + ret1.f32;
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
  size_t griddim = 100;
  size_t blockdim = 1024;
  size_t batch = 10000;
  size_t batchlength = griddim * blockdim;
  float *output = (float *)malloc(batchlength * sizeof(float));
  float *input_x = (float *)malloc(batchlength * sizeof(float));
  float *input_y = (float *)malloc(batchlength * sizeof(float));
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

  FILE *fp_random = fopen("/home/xwu/float.unary.txt", "r");
  // FILE *fp_ret = fopen("/home/xwu/maca_expf.txt", "w");

  hipEventCreate(&gpuStart);
  hipEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%x", (uint32_t *)&input_x[i]);
    }


    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test_logf, dim3(griddim), dim3(blockdim), 0, 0,
                       outputBuffer, inputBuffer_x);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    // printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    // for (int i = 0; i < batchlength; i++) {
    //   fprintf(fp_ret, "%x\n", *(uint32_t *)&output[i]);
    // }
  }

  // Cleanup after kernel execution
  fclose(fp_random);
  // fclose(fp_ret);
  hipFree(inputBuffer_x);
  hipFree(inputBuffer_y);
  hipFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);

  return 0;
}
