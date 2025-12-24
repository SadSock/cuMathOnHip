#include <cuda_runtime.h>
#include <stdio.h>
#include <time.h>

#define NUM_ITER 1000000    // 足够大的迭代次数
#define WARMUP_ITER 2000000    // 预热迭代次数，确保进入稳定频率
#define BLOCK_SIZE 256      // 8 warps (256 / 32)

__global__ void warmup(int iterations, float src_a, float src_b,
                            float* result) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    volatile float a = src_a;
    volatile float b = src_b;
    volatile float acc = a * static_cast<float>(idx) + b;
    for (int i = 0; i < iterations; i++) {
        acc = acc * a + b;
    }

    if (idx == 0) {
        result[0] = acc;
    }
}

__global__ void warp_schedule(int warp_id1, int warp_id2,
                              float src_a, float src_b, float src_c,
                              float* result) {
    int warp_id = threadIdx.x / 32;

    if(warp_id != warp_id1 && warp_id != warp_id2){
      return;
    }

    volatile float a = src_a;
    volatile float b = src_b;
    volatile float c = src_c;
    volatile float dummy = c; // 防止编译器优化

    for (int i = 0; i < NUM_ITER; i++) {
        dummy = a * b + c; // 关键计算
    }

    if (warp_id == warp_id1) {
        result[0] = dummy; // warp_id1 写入 result[0]
    }
    if (warp_id == warp_id2) {
        result[1] = dummy; // warp_id2 写入 result[1]
    }
}

int main() {
    float* d_result;
    float* d_prep_result;
    cudaMalloc(&d_result, sizeof(float) * 2); // 分配两个 float
    cudaMalloc(&d_prep_result, sizeof(float));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // 预热 GPU，尽量让 SM 时钟进入稳定状态
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    int prep_blocks = prop.multiProcessorCount * 2;
    float prep_src_a = static_cast<float>((clock() >> 8) & 0xFF) * 0.01f + 1.1f;
    float prep_src_b = static_cast<float>(clock() & 0xFF) * 0.01f + 0.9f;
    warmup<<<prep_blocks, 1024>>>(WARMUP_ITER,
                                             prep_src_a, prep_src_b,
                                             d_prep_result);
    cudaDeviceSynchronize();

    // 预分配结果矩阵 (4x4)
    float results[4][4] = {0};

    // 测试 4x4 = 16 种组合
    for (int i = 0; i < 4; i++) {          // warp_id1: 0,1,2,3
        for (int j = 0; j < 4; j++) {      // warp_id2: 4,5,6,7
            int warp_id1 = i;
            int warp_id2 = 4 + j;  // 4,5,6,7

            float src_a = 1.0f + 0.01f * (i + j);
            float src_b = 2.0f + 0.02f * (i + j);
            float src_c = 3.0f + 0.03f * (i + j);

            // 执行 kernel
            cudaEventRecord(start);
            warp_schedule<<<1, BLOCK_SIZE>>>(warp_id1, warp_id2,
                                             src_a, src_b, src_c,
                                             d_result);
            cudaEventRecord(stop);
            cudaEventSynchronize(stop);

            float time;
            cudaEventElapsedTime(&time, start, stop);

            // 计算 GFLOPS (warps * 2 FLOPS)
            results[i][j] = (2.0f * NUM_ITER * 2) / (time * 1e-3)/ 1e9;
        }
    }

    // 打印结果表格 (4x4)
    printf("               | warpA_id = %s | warpA_id = %s | warpA_id = %s | warpA_id = %s |\n", "0", "1", "2", "3");
    printf("-----------------------------------------------------------------------------\n");
    for (int i = 0; i < 4; i++) {
    printf("warpB_id = %d   |", 4 + i);
        for (int j = 0; j < 4; j++) {
            printf("     %.2f     |", results[i][j]);
        }
        printf("\n");
    }

    // 验证双写回：检查两个 warp 的结果是否一致
    float host_result[2];
    cudaMemcpy(host_result, d_result, sizeof(float)*2, cudaMemcpyDeviceToHost);
    printf("\nwarp_id1=%d, warp_id2=%d: %.2f vs %.2f\n",
           0, 4, host_result[0], host_result[1]);

    cudaFree(d_result);
    cudaFree(d_prep_result);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
