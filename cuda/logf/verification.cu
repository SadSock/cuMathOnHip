#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void verification_logf(float *y, float x) {
	
  	printf("%f\n", x);
    *y = expf(x);
	  printf("%f\n", *y);
    return;
}

int main() {
  // float tCpu, tGpu, tSharedMemGpu;
  float tGpu;
  // clock_t cpuStart, cpuEnd;
  // cudaEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  cudaEvent_t gpuStart, gpuEnd;
  // time_t c_start, c_end;
  size_t griddim  = 1; // 102400;
  size_t blockdim = 1024;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch  = 1;
  float *output  = (float *)malloc(batchlength * sizeof(float));
  float *input_x = (float *)malloc(batchlength * sizeof(float));
  float *input_y = (float *)malloc(batchlength * sizeof(float));
  memset(input_x, 0, batchlength * sizeof(float));
  memset(input_y, 0, batchlength * sizeof(float));
  memset(output,  0, batchlength * sizeof(float));

  // Allocate device memory
  float *inputBuffer_x;
  float *inputBuffer_y;
  float *outputBuffer;
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(float));
  cudaMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(float));
  cudaMalloc((void **)&outputBuffer,  (batchlength) * sizeof(float));

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);

  for (int j = 0; j < batch; j++) {

    float input = 2.718281828f;

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float), cudaMemcpyHostToDevice);
    cudaEventRecord(gpuStart, 0);
    verification_logf<<<griddim, blockdim>>>(outputBuffer, input);
    
    
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
      printf("CUDA error: %s\n", cudaGetErrorString(error));
    }

    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(float), cudaMemcpyDeviceToHost);
	  printf("%f\n", output[0]);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
  }
  cudaFree(inputBuffer_x);
  cudaFree(inputBuffer_y);
  cudaFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);
}
