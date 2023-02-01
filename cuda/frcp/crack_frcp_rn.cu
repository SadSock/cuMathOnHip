#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void crack_frcp_rn(float *y, float x) {
  //printf("x = %x %f\n", *(uint32_t *)&x, x);
  *y = __frcp_rn(x);
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
  size_t blockdim = 1;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch  = 1;
  float *output  = (float *)malloc(batchlength * sizeof(float));
  float *input_x = (float *)malloc(batchlength * sizeof(float));
  memset(input_x, 0, batchlength * sizeof(float));
  memset(output,  0, batchlength * sizeof(float));

  // Allocate device memory
  float *inputBuffer_x;
  float *outputBuffer;
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(float));
  cudaMalloc((void **)&outputBuffer,  (batchlength) * sizeof(float));
  //FILE *fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
  //FILE *fp_ret = fopen("/home/centos/xwu/cuda__ddiv_rn.txt", "w");

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
    }

    *(uint32_t*)&input_x[0] = 0x80000001;

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float), cudaMemcpyHostToDevice);
    cudaEventRecord(gpuStart, 0);
    crack_frcp_rn<<<griddim, blockdim>>>(outputBuffer, input_x[0]);
    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(float), cudaMemcpyDeviceToHost);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
    printf("%x %f\n", *(uint32_t *)&output[0], output[0]);
    for (int i = 0; i < batchlength; i++) {
      //fprintf(fp_ret, "%x %f\n", *(uint32_t *)&output[i], output[i]);
    }
  }
  //fclose(fp_random);
  //fclose(fp_ret);
  cudaFree(inputBuffer_x);
  cudaFree(outputBuffer);
  free(input_x);
  free(output);
}
