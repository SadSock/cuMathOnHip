#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void test_bessel(double *out, double *in) {

    int idx = threadIdx.x + blockDim.x * blockIdx.x;
  out[idx] = cyl_bessel_i1(in[idx]);
  return;
}

int main() {

  // time_t c_start, c_end;
  size_t griddim = 10240;//10240;  // 102400;
  size_t blockdim = 1024;//1024; // 1024;
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
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(double));
  cudaMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(double));
  cudaMalloc((void **)&outputBuffer, (batchlength) * sizeof(double));

  FILE *fp_random = fopen("/home/xwu/double.random.txt", "r");
  FILE *fp_ret = fopen("/home/xwu/cuda.txt", "w");

  for (int i = 0; i < batchlength; i++) {
    fscanf(fp_random, "%lx", (uint64_t *)&input_x[i]);
    //printf("%la\n", input_x[i]);
  }

  cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double),
             cudaMemcpyHostToDevice);
  cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double),
             cudaMemcpyHostToDevice);
  // c_start = clock(); //!< 单位为ms
  test_bessel<<<griddim, blockdim>>>(outputBuffer, inputBuffer_x);
  // c_end = clock();
  cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
             cudaMemcpyDeviceToHost);
  cudaDeviceSynchronize();
  for (int i = 0; i < batchlength; i++) {
    fprintf(fp_ret, "%lx\n", *(uint64_t *)&output[i]);
    //printf("%la\n", output[i]);
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
