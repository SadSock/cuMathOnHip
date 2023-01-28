#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void test_fdiv_rd(float *out, float *a, float *b) {
  //   printf("%x, %u\n", a, a);
  int idx = threadIdx.x + blockDim.x * blockIdx.x;
  //printf("%a, %a\n", a[idx], b[idx]);
  out[idx] = __fdiv_rd(a[idx], b[idx]);
  return;
}

int main() {
  // float tCpu, tGpu, tSharedMemGpu;
  float tGpu;
  // clock_t cpuStart, cpuEnd;
  // cudaEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  cudaEvent_t gpuStart, gpuEnd;
  // time_t c_start, c_end;
  size_t griddim = 1024; // 102400;
  size_t blockdim = 640;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch = 5000;
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
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(float));
  cudaMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(float));
  cudaMalloc((void **)&outputBuffer, (batchlength) * sizeof(float));

  FILE *fp_random = fopen("/home/xwu/float.random.txt", "r");
  //FILE *fp_ret = fopen("/home/centos/xwu/cuda__fdiv_rd.txt", "w");
  FILE *fp_ret = fopen("/home/xwu/cuda__fdiv_rd.txt", "w");

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%x %x", (uint32_t *)&input_y[i], (uint32_t *)&input_x[i]);
    }

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
               cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
               cudaMemcpyHostToDevice);
    // c_start = clock(); //!< 单位为ms
    // drcp<<<griddim, blockdim>>>(outputBuffer, inputBuffer);
    // printf("123");
    cudaEventRecord(gpuStart, 0);
    test_fdiv_rd<<<griddim, blockdim>>>(outputBuffer, inputBuffer_y, inputBuffer_x);
    // c_end = clock();
    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
               cudaMemcpyDeviceToHost);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
    for (int i = 0; i < batchlength; i++) {
      fprintf(fp_ret, "%x\n", *(uint32_t *)&output[i]);
    }
  }
  // printf("The pause used %f ms by clock()\n", difftime(c_end, c_start));
  //  printf("%f, %la, %lx\n", out[0], out[0], *(uint64_t *)&out[0]);
  // Cleanup after kernel execution
  fclose(fp_random);
  fclose(fp_ret);
  cudaFree(inputBuffer_x);
  cudaFree(inputBuffer_y);
  cudaFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);
}
