#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void test_fdiv_rz(float *out, float *a, float *b) {
  // printf("123");
  //  double x = in;
  //  uint32_t  a = __funnelshift_lc(0x3, 0x7, 32);
  //  printf("%x, %u\n", a, a);
  int idx = threadIdx.x + blockDim.x * blockIdx.x;
  // printf("%a\n", in[idx]);
  // out[idx] = __drcp_ru(in[idx]);
  //printf("%a, %a\n", a[idx], b[idx]);
  out[idx] = __fdiv_rz(a[idx], b[idx]);
  // printf("%f, %la, %lx\n", out[0], out[0], *(uint64_t *)&out[0]);
  // printf("123 %lf", 0.0/0.0);
  // printf("%a\n", out[idx]);
  return;
}

int main() {
  // float tCpu, tGpu, tSharedMemGpu;
  float tGpu;
  // clock_t cpuStart, cpuEnd;
  // cudaEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  cudaEvent_t gpuStart, gpuEnd;
  // time_t c_start, c_end;
  size_t griddim = 102400; // 102400;
  size_t blockdim = 1024;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch = 10;
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

  FILE *fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
  //FILE *fp_ret = fopen("/home/centos/xwu/cuda__fdiv_rz.txt", "w");
  FILE *fp_ret = fopen("/home/xwu/cuda__fdiv_rz.txt", "w");

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%x %x", (uint32_t *)&input_y[i], (uint32_t *)&input_x[i]);
      //printf("%x %x\n", *(uint32_t *)&input_y[i], *(uint32_t*)&input_x[i]);
      // printf("%lx %lx\n", *(uint64_t *)&input_x[i],
      // *(uint64_t *)&input_y[i]);
    }
    // printf("%p",fp_random);
    // for (int i = 0; i < batchlength; i++) {
    //   fscanf(fp_random, "%la", &input_x[i]);
    //   fscanf(fp_random, "%la", &input_y[i]);
    // }

    // input_x[0] = 3.0;
    // input_y[0] = -2.0;

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
               cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
               cudaMemcpyHostToDevice);
    // c_start = clock(); //!< 单位为ms
    // drcp<<<griddim, blockdim>>>(outputBuffer, inputBuffer);
    // printf("123");
    cudaEventRecord(gpuStart, 0);
    test_fdiv_rz<<<griddim, blockdim>>>(outputBuffer, inputBuffer_y, inputBuffer_x);
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
