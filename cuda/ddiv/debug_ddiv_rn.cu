#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void ddiv_rn(double *out, double a, double b) {
  // double x = in;
  // uint32_t  a = __funnelshift_lc(0x3, 0x7, 32);
  // printf("%x, %u\n", a, a);
  // int idx = threadIdx.x + blockDim.x * blockIdx.x;
  // printf("%a\n", in[idx]);
  // out[idx] = __drcp_ru(in[idx]);
  *out = __ddiv_rn(a, b);
  // printf("%f, %la, %lx\n", out[0], out[0], *(uint64_t *)&out[0]);
  // printf("%a\n", out[idx]);
  return;
}

int main() {

  // time_t c_start, c_end;
  size_t griddim = 1;  // 102400;
  size_t blockdim = 1; // 1024;
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

  //FILE *fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
  //FILE *fp_ret = fopen("/home/centos/cuda__drcp_rn.txt", "w");

  //for (int i = 0; i < batchlength; i++) {
  //  fscanf(fp_random, "%la", &input_x[i]);
  //  fscanf(fp_random, "%la", &input_y[i]);
  //}

  input_x[0] = 3.0;
  input_y[0] = -2.0;

  cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double),
             cudaMemcpyHostToDevice);
  cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double),
             cudaMemcpyHostToDevice);
  // c_start = clock(); //!< 单位为ms
  // drcp<<<griddim, blockdim>>>(outputBuffer, inputBuffer);
  ddiv_rn<<<griddim, blockdim>>>(outputBuffer, input_x[0], input_y[0]);
  // c_end = clock();
  cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
             cudaMemcpyDeviceToHost);

  for (int i = 0; i < batchlength; i++) {
    // fprintf(fp_ret, "%f, %la, %lx\n", output[i], output[i],
    //          *(uint64_t *)&output[i]);
    printf("%lx\n", *(uint64_t *)&output[i]);
  }

  // printf("The pause used %f ms by clock()\n", difftime(c_end, c_start));
  //  printf("%f, %la, %lx\n", out[0], out[0], *(uint64_t *)&out[0]);
  cudaDeviceSynchronize();
  // Cleanup after kernel execution
  //fclose(fp_random);
  //fclose(fp_ret);
  cudaFree(inputBuffer_x);
  cudaFree(inputBuffer_y);
  cudaFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);
}
