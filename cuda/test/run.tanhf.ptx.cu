#include <stdio.h>
#include "cuda.h"
#include <cuda_runtime_api.h>

//using namespace nvcuda;

int main(){
  CUresult err;
  int n = 1;
  int size = n * sizeof(float);
  float *a;

  // Allocate memory on host
  a = (float *)malloc(size);

  // Allocate memory on device
  float *d_a;
  cudaMalloc((void **)&d_a, size);

  uint32_t in_u32 = 0x7f800001;
  float in = *(float *)&in_u32;
  // Launch kernel on device
  int threads_per_block = 1;
  int num_blocks = (n + threads_per_block - 1) / threads_per_block;

  // 定义kernel函数
  dim3 dimBlock(threads_per_block);
  dim3 dimGrid(num_blocks);

  // 设置kernel参数
  void *args[]={&d_a, &in};

  // 初始化 CUDA
  err = cuInit(0);
  if (err != CUDA_SUCCESS) {
    printf("cuInit error: %d\n", err);
    return 1;
  }

  // 获取设备
  CUdevice device;
  err = cuDeviceGet(&device, 0);
  if (err != CUDA_SUCCESS) {
    printf("cuDeviceGet error: %d\n", err);
    return 1;
  }

  // 创建上下文
  CUcontext context;
  err = cuCtxCreate(&context, 0, device);
  if (err != CUDA_SUCCESS) {
    printf("cuCtxCreate error: %d\n", err);
    return 1;
  }

  // 加载模块
  CUmodule module;
  err = cuModuleLoad(&module, "test.tanhf.ptx.ptx");
  if (err != CUDA_SUCCESS) {
      const char* error_string;
      cuGetErrorString(err, &error_string);
      printf("cuModuleLoad error: %s\n", error_string);
    return 1;
  }

  // 获取函数句柄
  CUfunction function;
  err = cuModuleGetFunction(&function, module, "test_tanhf");
  if (err != CUDA_SUCCESS) {
      const char* error_string;
      cuGetErrorString(err, &error_string);
      printf("cuModuleGetFunction error: %s\n", error_string);
      return 1;
  }

  // 启动kernel
  err = cuLaunchKernel(function, 1, 1, 1, // grid dim
                       1, 1, 1,           // block dim
                       0, NULL,           // shared mem and stream
                       args, 0);

  if (err != CUDA_SUCCESS) {
      const char* error_string;
      cuGetErrorString(err, &error_string);
      printf("cuModuleGetFunction error: %s\n", error_string);
      return 1;
  }

  // Copy output vector from device to host
  cudaMemcpy(a, d_a, size, cudaMemcpyDeviceToHost);
  printf("lf: %lf\n", a[0]);
  printf("lx: %lx\n", *(uint32_t*)&a[0]);
  printf("la: %la\n", a[0]);
  // Free memory on device
  cudaFree(d_a);
  // Free memory on host
  free(a);

  return 0;
}
