#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


union m32 {
  uint32_t u32;
  int32_t s32;
  float f32;
};

__global__ void crack_idiv(int32_t *out, int32_t x, int32_t y) {

    volatile m32 y0;
    m32 x0, x1, y1, y2;
    m32 rcp0, rcp1, rcp2, rcp3;
    m32 neg_one;
    m32 q0, q1, q2;
    m32 rem0, rem1;
    m32 sign;
    y0.s32 = y;
    x0.s32 = x;

    sign.u32 = y0.u32 ^ x0.u32;
    y1.s32 = abs(y0.s32);

    // 估计a, 使得a小于2^32 / y，并且尽量接近2^32 / y
    y2.f32 = __int2float_ru(y1.s32);
    asm("rcp.approx.ftz.f32 %0, %1;" :"=f"(rcp0.f32) : "f"(y2.f32));
    rcp1.u32 = rcp0.u32 + 0xffffffe;        // rcp1 = rcp0 * 2^32 - d
    asm("cvt.rzi.ftz.u32.f32 %0, %1;" :"=r"(rcp2.u32) : "f"(rcp1.f32));

    // 整数牛顿迭代，使得a在小于2^32 / y的情况下，更加接近2^32 / y
    neg_one.u32 = y1.u32 * (-rcp2.u32);
    rcp3.u32 = __umulhi(rcp2.u32, neg_one.u32) + rcp2.u32;

    x1.s32 = abs(x0.s32);

    q0.u32 = __umulhi(x1.u32, rcp3.u32);
    rem0.u32 = - q0.u32 * y1.u32 + x1.u32;

    if(rem0.u32 >= y1.u32){
        q1.u32 = q0.u32 + 1u;
        rem1.u32 = rem0.u32 - y1.u32;
    }else{
        q1.u32 = q0.u32;
        rem1.u32 = rem0.u32;
    }


    if(rem1.u32 >= y1.u32){
        q2.u32 = q1.u32 + 1u;
    }else{
        q2.u32 = q1.u32;
    }

    if(sign.s32 <= 0){
        q2.u32 = - q2.u32;
    }

    if(y0.u32 == 0U)
        q2.u32 = ~ y0.u32;

    *out = q2.s32;

  return;
}

int main() {
  // int32_t tCpu, tGpu, tSharedMemGpu;
  float tGpu;
  // clock_t cpuStart, cpuEnd;
  // cudaEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  cudaEvent_t gpuStart, gpuEnd;
  // time_t c_start, c_end;
  size_t griddim  = 1; // 102400;
  size_t blockdim = 1;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch  = 1;
  int32_t *output  = (int32_t *)malloc(batchlength * sizeof(int32_t));
  int32_t *input_x = (int32_t *)malloc(batchlength * sizeof(int32_t));
  int32_t *input_y = (int32_t *)malloc(batchlength * sizeof(int32_t));
  memset(input_x, 0, batchlength * sizeof(int32_t));
  memset(input_y, 0, batchlength * sizeof(int32_t));
  memset(output,  0, batchlength * sizeof(int32_t));

  // Allocate device memory
  int32_t *inputBuffer_x;
  int32_t *inputBuffer_y;
  int32_t *outputBuffer;
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(int32_t));
  cudaMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(int32_t));
  cudaMalloc((void **)&outputBuffer,  (batchlength) * sizeof(int32_t));

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
    }

    //*(int32_t*)&input_x[0] = 0x481aab7f;

    input_x[0] = 200;

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(int32_t), cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(int32_t), cudaMemcpyHostToDevice);
    cudaEventRecord(gpuStart, 0);
    crack_idiv<<<griddim, blockdim>>>(outputBuffer, 1024, -2);
    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(int32_t), cudaMemcpyDeviceToHost);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
    printf("%x %d\n", *(int32_t *)&output[0], output[0]);
    for (int i = 0; i < batchlength; i++) {
    }
  }
  cudaFree(inputBuffer_x);
  cudaFree(inputBuffer_y);
  cudaFree(outputBuffer);
  free(input_x);
  free(input_y);
  free(output);
}
