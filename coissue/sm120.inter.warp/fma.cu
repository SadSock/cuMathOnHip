#include <cuda_runtime.h>
#include <stdio.h>
#include <stdint.h>
#include <set>


#define warpSize 32
#define batch 20
#define WARMUP_ITER 2000000    // 预热迭代次数，确保进入稳定频率
#define ITER 1024 // 每个线程的迭代次数

__global__ void warmup(float src_a, float src_b,
                            float* result) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    volatile float a = src_a;
    volatile float b = src_b;
    volatile float acc = a * static_cast<float>(idx) + b;
    for (uint64_t i = 0; i < WARMUP_ITER; i++) {
        acc = acc * a + b;
    }

    if (idx == 0) {
        result[0] = acc;
    }
}


__global__ void fma_quad_warp(const float *fa, const float *fb, float *fc, uint64_t *ts, uint64_t *te) {


  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  unsigned int warpId = idx / warpSize;


  __shared__ float sfa[warpSize * 20];
  __shared__ float sfb[warpSize * 20];

  if(warpId == 0){
    for (int i = 0; i < batch; i++){
      sfa[i * warpSize + idx] = fa[i * warpSize + idx];
      sfb[i * warpSize + idx] = fb[i * warpSize + idx];
    }
  }

  __syncthreads();

  if(warpId == 0){

    float fa0, fb0, fc0;
    float fa1, fb1, fc1;
    float fa2, fb2, fc2;
    float fa3, fb3, fc3;
    float fa4, fb4, fc4;

    fa0 = sfa[0 * warpSize +idx];
    fa1 = sfa[1 * warpSize +idx];
    fa2 = sfa[2 * warpSize +idx];
    fa3 = sfa[3 * warpSize +idx];
    fa4 = sfa[4 * warpSize +idx];

    fb0 = sfb[0 * warpSize +idx];
    fb1 = sfb[1 * warpSize +idx];
    fb2 = sfb[2 * warpSize +idx];
    fb3 = sfb[3 * warpSize +idx];
    fb4 = sfb[4 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc0 = fa0 * fb0 + 0;
    fc1 = fa1 * fb1 + 0;
    fc2 = fa2 * fb2 + 0;
    fc3 = fa3 * fb3 + 0;
    fc4 = fa4 * fb4 + 0;

    // code 1

    for(int i = 1; i < ITER; i++){
      fc0 = fa0 * fb0 + fc0;
      fc1 = fa1 * fb1 + fc1;
      fc2 = fa2 * fb2 + fc2;
      fc3 = fa3 * fb3 + fc3;
      fc4 = fa4 * fb4 + fc4;
    }

    uint64_t end = clock64();

    fc[0 * warpSize + idx] = fc0;
    fc[1 * warpSize + idx] = fc1;
    fc[2 * warpSize + idx] = fc2;
    fc[3 * warpSize + idx] = fc3;
    fc[4 * warpSize + idx] = fc4;

    ts[idx] = start;
    te[idx] = end;
  }

  if(warpId == 4){

    // 同一个SPs上的两个warp共同完成计算
    idx = idx - warpSize * 4;

    float fa5, fb5, fc5;
    float fa6, fb6, fc6;
    float fa7, fb7, fc7;
    float fa8, fb8, fc8;
    float fa9, fb9, fc9;

    fa5 = sfa[5 * warpSize +idx];
    fa6 = sfa[6 * warpSize +idx];
    fa7 = sfa[7 * warpSize +idx];
    fa8 = sfa[8 * warpSize +idx];
    fa9 = sfa[9 * warpSize +idx];

    fb5 = sfb[5 * warpSize +idx];
    fb6 = sfb[6 * warpSize +idx];
    fb7 = sfb[7 * warpSize +idx];
    fb8 = sfb[8 * warpSize +idx];
    fb9 = sfb[9 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc5 = fa5 * fb5 + 0;
    fc6 = fa6 * fb6 + 0;
    fc7 = fa7 * fb7 + 0;
    fc8 = fa8 * fb8 + 0;
    fc9 = fa9 * fb9 + 0;

    // code 2

    for(int i = 1; i < ITER; i++){
      fc5 = fa5 * fb5 + fc5;
      fc6 = fa6 * fb6 + fc6;
      fc7 = fa7 * fb7 + fc7;
      fc8 = fa8 * fb8 + fc8;
      fc9 = fa9 * fb9 + fc9;
    }

    uint64_t end = clock64();

    fc[5 * warpSize + idx] = fc5;
    fc[6 * warpSize + idx] = fc6;
    fc[7 * warpSize + idx] = fc7;
    fc[8 * warpSize + idx] = fc8;
    fc[9 * warpSize + idx] = fc9;

    ts[warpSize + idx] = start;
    te[warpSize + idx] = end;
  }


  if(warpId == 8){

    // 同一个SPs上的两个warp共同完成计算
    idx = idx - warpSize * 8;

    float fa10, fb10, fc10;
    float fa11, fb11, fc11;
    float fa12, fb12, fc12;
    float fa13, fb13, fc13;
    float fa14, fb14, fc14;

    fa10 = sfa[10 * warpSize +idx];
    fa11 = sfa[11 * warpSize +idx];
    fa12 = sfa[12 * warpSize +idx];
    fa13 = sfa[13 * warpSize +idx];
    fa14 = sfa[14 * warpSize +idx];

    fb10 = sfb[10 * warpSize +idx];
    fb11 = sfb[11 * warpSize +idx];
    fb12 = sfb[12 * warpSize +idx];
    fb13 = sfb[13 * warpSize +idx];
    fb14 = sfb[14 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc10 = fa10 * fb10 + 0;
    fc11 = fa11 * fb11 + 0;
    fc12 = fa12 * fb12 + 0;
    fc13 = fa13 * fb13 + 0;
    fc14 = fa14 * fb14 + 0;

    // code 2

    for(int i = 1; i < ITER; i++){
      fc10 = fa10 * fb10 + fc10;
      fc11 = fa11 * fb11 + fc11;
      fc12 = fa12 * fb12 + fc12;
      fc13 = fa13 * fb13 + fc13;
      fc14 = fa14 * fb14 + fc14;
    }

    uint64_t end = clock64();

    fc[10 * warpSize + idx] = fc10;
    fc[11 * warpSize + idx] = fc11;
    fc[12 * warpSize + idx] = fc12;
    fc[13 * warpSize + idx] = fc13;
    fc[14 * warpSize + idx] = fc14;

    ts[warpSize * 2 + idx] = start;
    te[warpSize * 2 + idx] = end;
  }

  if(warpId == 12){

    // 同一个SPs上的两个warp共同完成计算
    idx = idx - warpSize * 12;

    float fa15, fb15, fc15;
    float fa16, fb16, fc16;
    float fa17, fb17, fc17;
    float fa18, fb18, fc18;
    float fa19, fb19, fc19;

    fa15 = sfa[15 * warpSize +idx];
    fa16 = sfa[16 * warpSize +idx];
    fa17 = sfa[17 * warpSize +idx];
    fa18 = sfa[18 * warpSize +idx];
    fa19 = sfa[19 * warpSize +idx];

    fb15 = sfb[15 * warpSize +idx];
    fb16 = sfb[16 * warpSize +idx];
    fb17 = sfb[17 * warpSize +idx];
    fb18 = sfb[18 * warpSize +idx];
    fb19 = sfb[19 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc15 = fa15 * fb15 + 0;
    fc16 = fa16 * fb16 + 0;
    fc17 = fa17 * fb17 + 0;
    fc18 = fa18 * fb18 + 0;
    fc19 = fa19 * fb19 + 0;

    // code 2

    for(int i = 1; i < ITER; i++){
      fc15 = fa15 * fb15 + fc15;
      fc16 = fa16 * fb16 + fc16;
      fc17 = fa17 * fb17 + fc17;
      fc18 = fa18 * fb18 + fc18;
      fc19 = fa19 * fb19 + fc19;
    }

    uint64_t end = clock64();

    fc[15 * warpSize + idx] = fc15;
    fc[16 * warpSize + idx] = fc16;
    fc[17 * warpSize + idx] = fc17;
    fc[18 * warpSize + idx] = fc18;
    fc[19 * warpSize + idx] = fc19;

    ts[warpSize * 3 + idx] = start;
    te[warpSize * 3 + idx] = end;
  }

}

int main() {

  const size_t bytes = warpSize * batch * sizeof(float);


  float *hA = (float *)malloc(bytes);
  float *hB = (float *)malloc(bytes);
  float *hC = (float *)malloc(bytes);

  uint64_t *hS = (uint64_t *)malloc(warpSize * 4 * sizeof(uint64_t));
  uint64_t *hE = (uint64_t *)malloc(warpSize * 4 * sizeof(uint64_t));

  for (int i = 0; i < warpSize * batch; ++i) {
    hA[i] = 1.0f;
    hB[i] = 1.0f;
  }

  float *dA, *dB, *dC;
  uint64_t *dS, *dE;
  float* d_warm_result;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaMalloc(&d_warm_result, sizeof(float));

  cudaMalloc(&dA, bytes);
  cudaMalloc(&dB, bytes);
  cudaMalloc(&dC, bytes);

  cudaMalloc(&dS, warpSize * 4 * sizeof(uint64_t));
  cudaMalloc(&dE, warpSize * 4 * sizeof(uint64_t));

  cudaMemcpy(dA, hA, bytes, cudaMemcpyHostToDevice);
  cudaMemcpy(dB, hB, bytes, cudaMemcpyHostToDevice);

  // 预热 GPU，尽量让 SM 时钟进入稳定状态
  cudaDeviceProp prop;
  cudaGetDeviceProperties(&prop, 0);
  int warm_blocks = prop.multiProcessorCount * 4;

  for(uint64_t i = 0; i < 100; i++){
    warmup<<<warm_blocks, 1024>>>(1.0, 1.0, d_warm_result);
  }
  cudaDeviceSynchronize();


  // 一个warp
  // 输出 dC 是 10 batch * 32 threads 的二维数组
  //

  memset(hC, 0, bytes);
  memset(hS, 0, warpSize * 4 * sizeof(uint64_t));
  memset(hE, 0, warpSize * 4 * sizeof(uint64_t));


  // 记录开始事件
  cudaEventRecord(start);
  fma_quad_warp<<<1, 32 * 16>>>(dA, dB, dC, dS, dE);
  // 记录结束事件
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);  // 等待事件完成

  // 计算时间差（毫秒）
  float ms = 0;
  cudaEventElapsedTime(&ms, start, stop);
  cudaDeviceSynchronize();

  printf("biwarp kernel: %.3f ms\n", ms);
  // printf("吞吐量: %.3f GB/s\n",
  //        (bytes * 2.0 / 1e9) / (ms / 1000.0));  // 假设每个元素读写各一次

  cudaMemcpy(hC, dC, bytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(hS, dS, warpSize * 4 * sizeof(uint64_t), cudaMemcpyDeviceToHost);
  cudaMemcpy(hE, dE, warpSize * 4 * sizeof(uint64_t), cudaMemcpyDeviceToHost);

  for(int j = 0; j < batch; j++){
    for(int i = 0; i < warpSize; i++){
      if(hC[0] != hC[i + j * warpSize]){
	return 0;
      }
    }
  }

  printf("ret = %f\n",hC[0]);

  std::set<uint64_t> tsSet;
  std::set<uint64_t> teSet;

  for(int i = 0; i < warpSize * 4; i++){

    tsSet.insert(hS[i]);
    teSet.insert(hE[i]);

  }


  uint64_t S = 0;
  uint64_t E = 0;

  S = *tsSet.begin();
  E = *teSet.rbegin();


  printf("biwarp total cycles %lu\n", E - S);

  printf("fma avg lantency: %f\n", (double)(E - S) / (double)(batch * ITER));

  cudaDeviceSynchronize();

  cudaFree(dA);
  cudaFree(dB);
  cudaFree(dC);
  cudaFree(dS);
  cudaFree(dE);
  free(hA);
  free(hB);
  free(hC);
  free(hS);
  free(hE);

  return 0;
}
