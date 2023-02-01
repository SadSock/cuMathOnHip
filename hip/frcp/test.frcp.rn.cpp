#include <cmath>
#include <cstdint>
#include <hip/hip_runtime.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include "fdiv.ru.h"

using namespace std;

// Class mask bits

__global__ void test__fdiv_ru(float *out, float *y, float *x) {
  int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
  //printf("%a, %a\n", y[idx], x[idx]);
  float ret = __fdiv_ru(y[idx], x[idx]);
  out[idx] = ret;
}

int main(int argc, char *argv[]) {
  float tCpu, tGpu, tSharedMemGpu;
  clock_t cpuStart, cpuEnd;
  hipEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  hipDeviceProp_t devProp;
  hipGetDeviceProperties(&devProp, 0);
  // time_t c_start, c_end;
  /* Initial input,output for the host and create memory objects for the
   * kernel*/
  size_t  griddim     = 1024;
  size_t  blockdim    = 640;
  size_t  batch       = 1000;
  size_t  batchlength = griddim * blockdim;
  float  *output      = (float *)malloc(batchlength * sizeof(float));
  float  *input_x     = (float *)malloc(batchlength * sizeof(float));
  float  *input_y     = (float *)malloc(batchlength * sizeof(float));
  memset(input_x, 0, batchlength * sizeof(float));
  memset(input_y, 0, batchlength * sizeof(float));
  memset(output, 0, batchlength * sizeof(float));

  // Allocate device memory
  float *inputBuffer_x;
  float *inputBuffer_y;
  float *outputBuffer;
  hipMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(float));
  hipMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(float));
  hipMalloc((void **)&outputBuffer, (batchlength) * sizeof(float));

  FILE* fp_random    = fopen("/home/xwu/float.random.txt", "r");
  FILE* fp_ret       = fopen("/home/xwu/hip__fdiv_ru.txt", "w");
  //	FILE* fp_ret = fopen("/dev/shm/hip__ddiv_rn.txt", "w");

  hipEventCreate(&gpuStart);
  hipEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
      fscanf(fp_random, "%x %x", (uint32_t*)&input_y[i],(uint32_t*)&input_x[i]);
      //printf("%lx %lx\n", *(uint64_t *)&input_x[i], *(uint64_t *)&input_y[i]);
    }

    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test__fdiv_ru, dim3(griddim), dim3(blockdim), 0, 0,
                       outputBuffer, inputBuffer_y, inputBuffer_x);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
    for (int i = 0; i < batchlength; i++) {
        fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
      //printf("%x\n", *(uint32_t *)&output[i]);
    }
  }

  // Cleanup after kernel execution
  fclose(fp_random);
  fclose(fp_ret);
  hipFree(inputBuffer_x);
  hipFree(inputBuffer_y);
  hipFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);

  return 0;
}
