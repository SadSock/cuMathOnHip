#define DEBUG
#include <cstdint>
#include <cmath>
#include <hip/hip_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <stdint.h>
#include "exp.h"
using namespace std;

__global__ void verification_exp(double *out, double x) {
    
  double ret = 0.0;
  ret = _ZN4maca3expEd(x);
  printf("ret = %lf %lx\n", ret, *(uint64_t *)&ret);
  ret = exp(x);
  printf("ret = %lf %lx\n", ret, *(uint64_t *)&ret);
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
  double *output = (double *)malloc(batchlength * sizeof(double));
  double *input_x = (double *)malloc(batchlength * sizeof(double));
  double *input_y = (double *)malloc(batchlength * sizeof(double));
  memset(input_x, 0, batchlength * sizeof(double));
  memset(input_y, 0, batchlength * sizeof(double));
  memset(output, 0, batchlength * sizeof(double));

  // Allocate device memory
  double *inputBuffer_x;
  double *inputBuffer_y;
  double *outputBuffer;
  hipMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(double));
  hipMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(double));
  hipMalloc((void **)&outputBuffer, (batchlength) * sizeof(double));

  hipEventCreate(&gpuStart);
  hipEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {

    input_x[0] = 0.0;
    printf("intput = %lf\n", input_x[0]);

    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(verification_exp, dim3(griddim), dim3(blockdim), 0, 0,
                       outputBuffer, input_x[0]);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
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
