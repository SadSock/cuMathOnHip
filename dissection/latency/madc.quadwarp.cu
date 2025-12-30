#include <cuda_runtime.h>
#include <stdio.h>
#include <stdint.h>
#include <set>


#define warpSize 32
#define batch 20
#define WARMUP_ITER 2000000    // 预热迭代次数，确保进入稳定频率
#define ITER 10240 // 每个线程的迭代次数

__global__ void warmup(uint32_t src_a, uint32_t src_b,
                            uint32_t* result) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    volatile uint32_t a = src_a;
    volatile uint32_t b = src_b;
    volatile uint32_t acc = a * static_cast<uint32_t>(idx) + b;
    for (uint64_t i = 0; i < WARMUP_ITER; i++) {
        acc = acc * a + b;
    }

    if (idx == 0) {
        result[0] = acc;
    }
}


__global__ void fma_quad_warp(const uint32_t *fa, const uint32_t fb, uint32_t *fc, uint64_t *ts, uint64_t *te) {


  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  unsigned int warpId = idx / warpSize;

  __shared__ uint32_t sfa[warpSize * 20];

  if(warpId == 0){
    for (int i = 0; i < batch; i++){
      sfa[i * warpSize + idx] = fa[i * warpSize + idx];
    }
  }

  __syncthreads();

  if(warpId == 0){

    uint32_t fa0, fc0;
    uint32_t fa1, fc1;
    uint32_t fa2, fc2;
    uint32_t fa3, fc3;
    uint32_t fa4, fc4;

    fa0 = sfa[0 * warpSize +idx];
    fa1 = sfa[1 * warpSize +idx];
    fa2 = sfa[2 * warpSize +idx];
    fa3 = sfa[3 * warpSize +idx];
    fa4 = sfa[4 * warpSize +idx];


    __syncthreads();
    uint64_t start = clock64();

    fc0 = 1.0f;
    fc1 = 1.0f;
    fc2 = 1.0f;
    fc3 = 1.0f;
    fc4 = 1.0f;

    // code 1

    for(int i = 0; i < ITER; i++){
      fc0 = fa0 * fc0 + fb;
      fc1 = fa1 * fc1 + fb;
      fc2 = fa2 * fc2 + fb;
      fc3 = fa3 * fc3 + fb;
      fc4 = fa4 * fc4 + fb;
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

    uint32_t fa5, fc5;
    uint32_t fa6, fc6;
    uint32_t fa7, fc7;
    uint32_t fa8, fc8;
    uint32_t fa9, fc9;

    fa5 = sfa[5 * warpSize +idx];
    fa6 = sfa[6 * warpSize +idx];
    fa7 = sfa[7 * warpSize +idx];
    fa8 = sfa[8 * warpSize +idx];
    fa9 = sfa[9 * warpSize +idx];


    __syncthreads();
    uint64_t start = clock64();

    fc5 = 1.0f;
    fc6 = 1.0f;
    fc7 = 1.0f;
    fc8 = 1.0f;
    fc9 = 1.0f;

    // code 2

    for(int i = 0; i < ITER; i++){
      fc5 = fa5 * fc5 + fb;
      fc6 = fa6 * fc6 + fb;
      fc7 = fa7 * fc7 + fb;
      fc8 = fa8 * fc8 + fb;
      fc9 = fa9 * fc9 + fb;
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

    uint32_t fa10, fc10;
    uint32_t fa11, fc11;
    uint32_t fa12, fc12;
    uint32_t fa13, fc13;
    uint32_t fa14, fc14;

    fa10 = sfa[10 * warpSize +idx];
    fa11 = sfa[11 * warpSize +idx];
    fa12 = sfa[12 * warpSize +idx];
    fa13 = sfa[13 * warpSize +idx];
    fa14 = sfa[14 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc10 = 1.0f;
    fc11 = 1.0f;
    fc12 = 1.0f;
    fc13 = 1.0f;
    fc14 = 1.0f;

    // code 2

    for(int i = 0; i < ITER; i++){

      fc10 = fa10 * fc10 + fb;
      fc11 = fa11 * fc11 + fb;
      fc12 = fa12 * fc12 + fb;
      fc13 = fa13 * fc13 + fb;
      fc14 = fa14 * fc14 + fb;
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

    uint32_t fa15, fc15;
    uint32_t fa16, fc16;
    uint32_t fa17, fc17;
    uint32_t fa18, fc18;
    uint32_t fa19, fc19;

    fa15 = sfa[15 * warpSize +idx];
    fa16 = sfa[16 * warpSize +idx];
    fa17 = sfa[17 * warpSize +idx];
    fa18 = sfa[18 * warpSize +idx];
    fa19 = sfa[19 * warpSize +idx];


    __syncthreads();
    uint64_t start = clock64();

    fc15 = 1.0f;
    fc16 = 1.0f;
    fc17 = 1.0f;
    fc18 = 1.0f;
    fc19 = 1.0f;

    // code 2
    for(int i = 0; i < ITER; i++){
      fc15 = fa15 * fc15 + fb;
      fc16 = fa16 * fc16 + fb;
      fc17 = fa17 * fc17 + fb;
      fc18 = fa18 * fc18 + fb;
      fc19 = fa19 * fc19 + fb;
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

  const size_t bytes = warpSize * batch * sizeof(uint32_t);


  uint32_t *hA = (uint32_t *)malloc(bytes);
  uint32_t *hB = (uint32_t *)malloc(bytes);
  uint32_t *hC = (uint32_t *)malloc(bytes);

  uint64_t *hS = (uint64_t *)malloc(warpSize * 4 * sizeof(uint64_t));
  uint64_t *hE = (uint64_t *)malloc(warpSize * 4 * sizeof(uint64_t));

  for (int i = 0; i < warpSize * batch; ++i) {
    hA[i] = 1.0f;
    hB[i] = 1.0f;
  }

  uint32_t *dA, *dB, *dC;
  uint64_t *dS, *dE;
  uint32_t* d_warm_result;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaMalloc(&d_warm_result, sizeof(uint32_t));

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
  fma_quad_warp<<<1, 32 * 16>>>(dA, 1.0, dC, dS, dE);
  // 记录结束事件
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);  // 等待事件完成

  // 计算时间差（毫秒）
  float ms = 0;
  cudaEventElapsedTime(&ms, start, stop);
  cudaDeviceSynchronize();

  printf("biwarp kernel: %.3f ms\n", ms);

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

  printf("ret = %d\n",hC[0]);

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
