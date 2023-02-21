#include <fstream>
#include <hip/hip_runtime.h>
#include <iostream>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "bessel.h"

using namespace std;



__global__ void test_bessel(double *out, double *in) {
  int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
  //printf("%lf\n", in[idx]);
  out[idx] = maca::cyl_bessel_i1(in[idx]);
}

int main(int argc, char *argv[]) {

  hipDeviceProp_t devProp;
  hipGetDeviceProperties(&devProp, 0);
  time_t c_start, c_end;
  /* Initial input,output for the host and create memory objects for the
   * kernel*/
  size_t griddim =  10240;//10240;
  size_t blockdim = 1024;//1024;
  size_t batch = 1;
  size_t batchlength = griddim * blockdim;
  double *output = (double *)malloc(batchlength * sizeof(double));
  double *input = (double *)malloc(batchlength * sizeof(double));
  memset(input, 0, batchlength * sizeof(double));
  memset(output, 0, batchlength * sizeof(double));

  double *inputBuffer;
  double *outputBuffer;
  hipMalloc((void **)&inputBuffer, (batchlength) * sizeof(double));
  hipMalloc((void **)&outputBuffer, (batchlength) * sizeof(double));

  FILE* fp_random = fopen("/home/xwu/double.random.txt", "r");
  FILE* fp_ret    = fopen("/home/xwu/hip.txt", "w");

  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%lx", (uint64_t *)&input[i]);
      //printf("%la\n", input[i]);
      //printf("%la\n", input[i]);
    }
    // input[0] = 0x0.8c50000118ap-1022;
    // input[0] = 0x1.947c0ffd28f8p+1023;
    //*(uint64_t *)&input[0] = 0xfff8000000000000;
    hipMemcpy(inputBuffer, input, (batchlength) * sizeof(double),
              hipMemcpyHostToDevice);
    c_start = clock();    //!< 单位为ms
    hipLaunchKernelGGL(test_bessel, dim3(griddim), dim3(blockdim), 0, 0, outputBuffer,
                       inputBuffer);
    c_end   = clock();
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    printf("The pause used %f ms by clock()\n",difftime(c_end,c_start));
    for (int i = 0; i < batchlength; i++) {
      fprintf(fp_ret, "%lx\n", *(uint64_t *)&output[i]);
      //printf("%la\n", output[i]);
    }
  }
  fclose(fp_random);
  fclose(fp_ret);
  hipFree(inputBuffer);
  hipFree(outputBuffer);
  free(input);
  free(output);

  return 0;
}
