#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void test_expf(float *y, float *x) {
	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	y[idx] = expf(x[idx]);
	printf("123\n");
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
  size_t blockdim = 10240;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch  = 10;
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

  FILE *fp_random = fopen("/home/xwu/float.random.unary.txt", "r");
  FILE *fp_ret    = fopen("/home/xwu/cuda_expf.txt", "w");       


  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);

  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
	    fscanf(fp_random, "%x", (uint32_t *)&input_x[i]);
      //printf("%f\n", input_x[i]);
    }


    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float), cudaMemcpyHostToDevice);
    cudaEventRecord(gpuStart, 0);
    test_expf<<<griddim, blockdim>>>(outputBuffer, inputBuffer_x);
    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(float), cudaMemcpyDeviceToHost);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
    for (int i = 0; i < batchlength; i++) {
	    fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
	    //printf("%f\n", output[i]);
    }
  }
  cudaFree(inputBuffer_x);
  cudaFree(inputBuffer_y);
  cudaFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);
}
