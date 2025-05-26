#include <cstdio>
#include <cuda_runtime.h>

__global__ void processNumbersKernel(int* results) {
    // 计算全局线程ID (0到2^32-1)
    unsigned int tid = blockIdx.x * blockDim.x + threadIdx.x;
    // 将结果保存到全局内存
    float rcp;
    asm("rcp.approx.ftz.f32 %0, %1;" : "=f"(rcp) : "f"(*(float*)&tid));
    results[tid] = *(int *)&rcp; // 强制转换为int（注意溢出）
}

int main() {
    const unsigned long long N = 4294967296ULL; // 2^32
    const int blockSize = 1024;                 // 每块1024线程
    const int gridSize = 4194304;               // 总块数 = 2^32 / 1024

    int* results = nullptr;
    cudaError_t err = cudaMalloc(&results, N * sizeof(int));

    // 检查内存分配是否成功
    if (err != cudaSuccess) {
        fprintf(stderr, "内存分配失败: %s\n", cudaGetErrorString(err));
        return 1;
    }

    // 启动核函数
    processNumbersKernel<<<gridSize, blockSize>>>(results);
    cudaDeviceSynchronize();

    // 错误检查
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        fprintf(stderr, "CUDA错误: %s\n", cudaGetErrorString(err));
        cudaFree(results);
        return 1;
    }

    // 释放内存
    cudaFree(results);
    return 0;
}
