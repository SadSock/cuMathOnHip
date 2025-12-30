#include <cuda_runtime.h>
#include <stdio.h>
#include <stdint.h>
#include <set>


#define warpSize 32
#define batch 20
#define WARMUP_ITER 20000    // 预热迭代次数，确保进入稳定频率
#define ITER 1024 * 1000 * 100LL // 每个线程的迭代次数

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


__global__ void imul_quad_warp(const uint32_t *fa, const uint32_t *fb, uint32_t *fc, uint64_t *ts, uint64_t *te, uint64_t iter) {


  int idx = blockIdx.x * blockDim.x + threadIdx.x;
  unsigned int warpId = idx / warpSize;

  __shared__ uint32_t sfb[warpSize * 20];

  if(warpId == 0){
    for (int i = 0; i < batch; i++){
      sfb[i * warpSize + idx] = fb[i * warpSize + idx];
    }
  }

  __syncthreads();

  if(warpId == 0){

    uint32_t fb0, fc0;
    uint32_t fb1, fc1;
    uint32_t fb2, fc2;
    uint32_t fb3, fc3;
    uint32_t fb4, fc4;


    fb0 = sfb[0 * warpSize +idx];
    fb1 = sfb[1 * warpSize +idx];
    fb2 = sfb[2 * warpSize +idx];
    fb3 = sfb[3 * warpSize +idx];
    fb4 = sfb[4 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc0 = fb0;
    fc1 = fb1;
    fc2 = fb2;
    fc3 = fb3;
    fc4 = fb4;

    // code 1

    for(int i = 0; i < iter; i++){
      fc0 = fc0 * fb0;
      fc1 = fc1 * fb1;
      fc2 = fc2 * fb2;
      fc3 = fc3 * fb3;
      fc4 = fc4 * fb4;
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

    uint32_t fb5, fc5;
    uint32_t fb6, fc6;
    uint32_t fb7, fc7;
    uint32_t fb8, fc8;
    uint32_t fb9, fc9;


    fb5 = sfb[5 * warpSize +idx];
    fb6 = sfb[6 * warpSize +idx];
    fb7 = sfb[7 * warpSize +idx];
    fb8 = sfb[8 * warpSize +idx];
    fb9 = sfb[9 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc5 = fb5;
    fc6 = fb6;
    fc7 = fb7;
    fc8 = fb8;
    fc9 = fb9;

    // code 2

    for(int i = 0; i < iter; i++){
      fc5 = fc5 * fb5;
      fc6 = fc6 * fb6;
      fc7 = fc7 * fb7;
      fc8 = fc8 * fb8;
      fc9 = fc9 * fb9;
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

    uint32_t fb10, fc10;
    uint32_t fb11, fc11;
    uint32_t fb12, fc12;
    uint32_t fb13, fc13;
    uint32_t fb14, fc14;

    fb10 = sfb[10 * warpSize +idx];
    fb11 = sfb[11 * warpSize +idx];
    fb12 = sfb[12 * warpSize +idx];
    fb13 = sfb[13 * warpSize +idx];
    fb14 = sfb[14 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc10 = fb10;
    fc11 = fb11;
    fc12 = fb12;
    fc13 = fb13;
    fc14 = fb14;

    // code 2

    for(int i = 0; i < iter; i++){

      fc10 = fc10 * fb10;
      fc11 = fc11 * fb11;
      fc12 = fc12 * fb12;
      fc13 = fc13 * fb13;
      fc14 = fc14 * fb14;
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

    uint32_t fb15, fc15;
    uint32_t fb16, fc16;
    uint32_t fb17, fc17;
    uint32_t fb18, fc18;
    uint32_t fb19, fc19;

    fb15 = sfb[15 * warpSize +idx];
    fb16 = sfb[16 * warpSize +idx];
    fb17 = sfb[17 * warpSize +idx];
    fb18 = sfb[18 * warpSize +idx];
    fb19 = sfb[19 * warpSize +idx];

    __syncthreads();
    uint64_t start = clock64();

    fc15 = fb15;
    fc16 = fb16;
    fc17 = fb17;
    fc18 = fb18;
    fc19 = fb19;

    // code 2
    for(int i = 0; i < iter; i++){
      fc15 = fc15 * fb15;
      fc16 = fc16 * fb16;
      fc17 = fc17 * fb17;
      fc18 = fc18 * fb18;
      fc19 = fc19 * fb19;
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

  for(uint64_t i = 0; i < 1; i++){
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
  imul_quad_warp<<<1, 32 * 16>>>(dA, dB, dC, dS, dE, ITER);
  // 记录结束事件
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);  // 等待事件完成

  // 计算时间差（毫秒）
  float ms = 0;
  cudaEventElapsedTime(&ms, start, stop);
  cudaDeviceSynchronize();

  printf("quad kernel: %.3f ms\n", ms);

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

  printf("imul avg lantency: %f\n", (double)(E - S) / (double)(batch * ITER));

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
