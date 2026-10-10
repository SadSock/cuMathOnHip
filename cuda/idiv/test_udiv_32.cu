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


__global__ void crack_udiv(uint32_t *out, uint32_t x, uint32_t y) {


    volatile m32 y0;
    m32 x0, y1;
    m32 rcp0, rcp1, rcp2, rcp3;
    m32 neg_one;
    m32 q0, q1, q2;
    m32 rem0, rem1;
    y0.u32 = y;
    x0.u32 = x;


    y1.f32 = __uint2float_ru(y0.u32);
    asm("rcp.approx.ftz.f32 %0, %1;" :"=f"(rcp0.f32) : "f"(y1.f32));
    rcp1.u32 = rcp0.u32 + 0xffffffe;        // rcp1 = rcp0 * 2^32 - d
    //
    asm("cvt.rzi.ftz.u32.f32 %0, %1;" :"=r"(rcp2.u32) : "f"(rcp1.f32));
    //R5 = -rcp2.u32
    //R3 = rcp2.u32
    //R5 = neg_one = -rcp2.u32 * y.u32
    neg_one.u32 = y0.u32 * (-rcp2.u32);
    //R3 = R3 * R5 = (rcp2.u32 * neg_one.u32) / 2^32
    rcp3.u32 = __umulhi(rcp2.u32, neg_one.u32) + rcp2.u32;

    //R5 = y
    //R3 = q0 =x * R3 / 2^32
    q0.u32 = __umulhi(x0.u32, rcp3.u32);
    //R0 = rem0 = -q0 * y + x
    rem0.u32 = - q0.u32 * y0.u32 + x0.u32;

    // if(rem0 >y){
    //q1 = q0 + 1;
    //rem1 = rem0 - y
    //}

    if(rem0.u32 >= y0.u32){
        q1.u32 = q0.u32 + 1u;
        rem1.u32 = rem0.u32 - y0.u32;
    }else{
        q1.u32 = q0.u32;
        rem1.u32 = rem0.u32;
    }

    // if(rem1 > y){
    //q2 = q1 + 1;
    //rem2 = rem1 - y
    //}

    if(rem1.u32 >= y0.u32){
        q2.u32 = q1.u32 + 1u;
    }else{
        q2.u32 = q1.u32;
    }



    //asm("setp.ne.u32 %0, 0%, 0;" :  : "r"(y0.u32));

    if(y0.u32==0U)
        *out = ~y0.u32;
    else
        *out = q2.u32;

  return;
}

int main() {
  // uint32_t tCpu, tGpu, tSharedMemGpu;
  float tGpu;
  // clock_t cpuStart, cpuEnd;
  // cudaEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
  cudaEvent_t gpuStart, gpuEnd;
  // time_t c_start, c_end;
  size_t griddim  = 1; // 102400;
  size_t blockdim = 1;  // 1024;
  size_t batchlength = griddim * blockdim;
  size_t batch  = 1;
  uint32_t *output  = (uint32_t *)malloc(batchlength * sizeof(uint32_t));
  uint32_t *input_x = (uint32_t *)malloc(batchlength * sizeof(uint32_t));
  uint32_t *input_y = (uint32_t *)malloc(batchlength * sizeof(uint32_t));
  memset(input_x, 0, batchlength * sizeof(uint32_t));
  memset(input_y, 0, batchlength * sizeof(uint32_t));
  memset(output,  0, batchlength * sizeof(uint32_t));

  // Allocate device memory
  uint32_t *inputBuffer_x;
  uint32_t *inputBuffer_y;
  uint32_t *outputBuffer;
  cudaMalloc((void **)&inputBuffer_x, (batchlength) * sizeof(uint32_t));
  cudaMalloc((void **)&inputBuffer_y, (batchlength) * sizeof(uint32_t));
  cudaMalloc((void **)&outputBuffer,  (batchlength) * sizeof(uint32_t));

  cudaEventCreate(&gpuStart);
  cudaEventCreate(&gpuEnd);
  for (int j = 0; j < batch; j++) {
    for (int i = 0; i < batchlength; i++) {
    }

    //*(uint32_t*)&input_x[0] = 0x481aab7f;

    input_x[0] = 200;

    cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(uint32_t), cudaMemcpyHostToDevice);
    cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(uint32_t), cudaMemcpyHostToDevice);
    cudaEventRecord(gpuStart, 0);
    crack_udiv<<<griddim, blockdim>>>(outputBuffer, 1023, 2);
    cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(uint32_t), cudaMemcpyDeviceToHost);
    cudaEventRecord(gpuEnd, 0);
    cudaEventSynchronize(gpuStart);
    cudaEventSynchronize(gpuEnd);
    cudaEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    cudaDeviceSynchronize();
    printf("%x %d\n", *(uint32_t *)&output[0], output[0]);
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
