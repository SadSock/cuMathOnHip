#define DEBUG
#include <cstdint>
#include <cmath>
#include <hip/hip_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "expf.h"
using namespace std;

__global__ void test_expf(float *out, float x) {
    float ret = hip::expf(x);
    printf("ret = %f %x\n", ret, *(uint32_t*)&ret);
    ret = expf(x);
    printf("ret = %f %x\n", ret, *(uint32_t*)&ret);
    out[0] = ret;
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
  size_t griddim = 1;
  size_t blockdim = 1;
  size_t batch = 1;
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

  hipEventCreate(&gpuStart);
  hipEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {

    input_x[0] = 4.111;
    printf("intput = %f\n", input_x[0]);

    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test_expf, dim3(griddim), dim3(blockdim), 0, 0,
                       outputBuffer, input_x[0]);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    for (int i = 0; i < batchlength; i++) {
      // fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
      printf("%x\n", *(uint32_t *)&output[i]);
    }
  }

  // Cleanup after kernel execution
  // fclose(fp_random);
  // fclose(fp_ret);
  hipFree(inputBuffer_x);
  hipFree(inputBuffer_y);
  hipFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);

  return 0;
}
