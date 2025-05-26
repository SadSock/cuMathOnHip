#include <cstdint>
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
  m64 _in;
  _in.u64 = 0x4043cb73d87dca60;
  out[idx] = maca::cyl_bessel_i1(_in.f64);
}

int main(int argc, char *argv[]) {

  hipDeviceProp_t devProp;
  hipGetDeviceProperties(&devProp, 0);
  time_t c_start, c_end;
  /* Initial input,output for the host and create memory objects for the
   * kernel*/
  size_t griddim = 1;
  size_t blockdim = 1;
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

  hipMemcpy(inputBuffer, input, (batchlength) * sizeof(double), hipMemcpyHostToDevice);
  c_start = clock(); //!< 单位为ms
  hipLaunchKernelGGL(test_bessel, dim3(griddim), dim3(blockdim), 0, 0,
                     outputBuffer, inputBuffer);
  c_end = clock();
  hipMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
            hipMemcpyDeviceToHost);
  hipDeviceSynchronize();
  printf("The pause used %f ms by clock()\n", difftime(c_end, c_start));
  //printf("%f\n",output[0]);
  printf("lf = %lf\n", output[0]);
  printf("la = %la\n" ,output[0]);
  printf("lx = %lx\n", *(uint64_t*)&output[0]);
  hipFree(inputBuffer);
  hipFree(outputBuffer);
  free(input);
  free(output);

  return 0;
}
