#include <cuda_runtime.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

namespace maca {
    __device__ __noinline__ double log(double x) { return ::log(x); }
} // namespace maca

__global__ void crack_log(double *y, double x) {
    *y = maca::log(x);
  return;
}

int main() {
  // double tCpu, tGpu, tSharedMemGpu;
  float tGpu;
  // clock_t cpuStart, cpuEnd;
  // cudaEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  cudaEvent_t gpuStart, gpuEnd;
  // time_t c_start, c_end;
  size_t griddim  = 1; // 102400;
  size_t blockdim = 1;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch  = 1;
  double *output  = (double *)malloc(batchlength * sizeof(double));
  double *input_x = (double *)malloc(batchlength * sizeof(double));
  double *input_y = (double *)malloc(batchlength * sizeof(double));
  memset(input_x, 0, batchlength * sizeof(double));
  memset(input_y, 0, batchlength * sizeof(double));
  memset(output,  0, batchlength * sizeof(double));

  // Allocate device memory
  double *inputBuffer_x;
  double *inputBuffer_y;
  double *outputBuffer;
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(double));
  cudaMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(double));
  cudaMalloc((void **)&outputBuffer,  (batchlength) * sizeof(double));

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
    }

    //*(uint32_t*)&input_x[0] = 0x481aab7f;

    input_x[0] = 200;

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double), cudaMemcpyHostToDevice);
    cudaEventRecord(gpuStart, 0);
    crack_log<<<griddim, blockdim>>>(outputBuffer, input_x[0]);
    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(double), cudaMemcpyDeviceToHost);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
    printf("%x %f\n", *(uint32_t *)&output[0], output[0]);
    for (int i = 0; i < batchlength; i++) {
    }
  }
  cudaFree(inputBuffer_x);
  cudaFree(inputBuffer_y);
  cudaFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);
}
