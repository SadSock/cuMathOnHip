#include <cuda_runtime.h>
#include <stdio.h>
#include <stdint.h>
#include <set>


#define warpSize 32
#define warpNum 1
#define batchSize 10
#define batchNum 2
#define WARMUP_ITER 2000000    // 预热迭代次数，确保进入稳定频率
#define ITER 10240 // 每个线程的迭代次数

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

__global__ void fma_imad_uni_warp(const float *fa, const float fb, float *fc, const uint32_t *ia, const uint32_t ib, uint32_t *ic,  uint64_t *ts, uint64_t *te) {


  int idx = blockIdx.x * blockDim.x + threadIdx.x;

  __shared__ float sfa[warpSize * batchSize];
  __shared__ uint32_t sia[warpSize * batchSize];

  for (int i = 0; i < batchSize; i++){
    sfa[i * warpSize + idx] = fa[i * warpSize + idx];
    sia[i * warpSize + idx] = ia[i * warpSize + idx];
  }

  __syncthreads();


  float fa0, fc0;
  float fa1, fc1;
  float fa2, fc2;
  float fa3, fc3;
  float fa4, fc4;
  float fa5, fc5;
  float fa6, fc6;
  float fa7, fc7;
  float fa8, fc8;
  float fa9, fc9;

  uint32_t ia0, ic0;
  uint32_t ia1, ic1;
  uint32_t ia2, ic2;
  uint32_t ia3, ic3;
  uint32_t ia4, ic4;
  uint32_t ia5, ic5;
  uint32_t ia6, ic6;
  uint32_t ia7, ic7;
  uint32_t ia8, ic8;
  uint32_t ia9, ic9;

  fa0  = sfa[0  * warpSize +idx];
  fa1  = sfa[1  * warpSize +idx];
  fa2  = sfa[2  * warpSize +idx];
  fa3  = sfa[3  * warpSize +idx];
  fa4  = sfa[4  * warpSize +idx];
  fa5  = sfa[5  * warpSize +idx];
  fa6  = sfa[6  * warpSize +idx];
  fa7  = sfa[7  * warpSize +idx];
  fa8  = sfa[8  * warpSize +idx];
  fa9  = sfa[9  * warpSize +idx];

  ia0  = sia[0 * warpSize +idx];
  ia1  = sia[1 * warpSize +idx];
  ia2  = sia[2 * warpSize +idx];
  ia3  = sia[3 * warpSize +idx];
  ia4  = sia[4 * warpSize +idx];
  ia5  = sia[5 * warpSize +idx];
  ia6  = sia[6 * warpSize +idx];
  ia7  = sia[7 * warpSize +idx];
  ia8  = sia[8 * warpSize +idx];
  ia9  = sia[9 * warpSize +idx];

  __syncthreads();

  uint64_t start = clock64();

  fc0  = 1.0f;
  fc1  = 1.0f;
  fc2  = 1.0f;
  fc3  = 1.0f;
  fc4  = 1.0f;
  fc5  = 1.0f;
  fc6  = 1.0f;
  fc7  = 1.0f;
  fc8  = 1.0f;
  fc9  = 1.0f;

  ic0 = 1;
  ic1 = 1;
  ic2 = 1;
  ic3 = 1;
  ic4 = 1;
  ic5 = 1;
  ic6 = 1;
  ic7 = 1;
  ic8 = 1;
  ic9 = 1;

  // code 1

  for(int i = 0; i < ITER; i++){

    fc0 = fa0  * fc0  + fb;
    fc1 = fa1  * fc1  + fb;
    fc2 = fa2  * fc2  + fb;
    fc3 = fa3  * fc3  + fb;
    fc4 = fa4  * fc4  + fb;
    fc5 = fa5  * fc5  + fb;
    fc6 = fa6  * fc6  + fb;
    fc7 = fa7  * fc7  + fb;
    fc8 = fa8  * fc8  + fb;
    fc9 = fa9  * fc9  + fb;

    ic0 = ia0 * ic0 + ib;
    ic1 = ia1 * ic1 + ib;
    ic2 = ia2 * ic2 + ib;
    ic3 = ia3 * ic3 + ib;
    ic4 = ia4 * ic4 + ib;
    ic5 = ia5 * ic5 + ib;
    ic6 = ia6 * ic6 + ib;
    ic7 = ia7 * ic7 + ib;
    ic8 = ia8 * ic8 + ib;
    ic9 = ia9 * ic9 + ib;
  }

  uint64_t end = clock64();

  fc[0 * warpSize + idx] = fc0;
  ic[0 * warpSize + idx] = ic0;

  fc[1 * warpSize + idx] = fc1;
  ic[1 * warpSize + idx] = ic1;

  fc[2 * warpSize + idx] = fc2;
  ic[2 * warpSize + idx] = ic2;

  fc[3 * warpSize + idx] = fc3;
  ic[3 * warpSize + idx] = ic3;

  fc[4 * warpSize + idx] = fc4;
  ic[4 * warpSize + idx] = ic4;

  fc[5 * warpSize + idx] = fc5;
  ic[5 * warpSize + idx] = ic5;

  fc[6 * warpSize + idx] = fc6;
  ic[6 * warpSize + idx] = ic6;

  fc[7 * warpSize + idx] = fc7;
  ic[7 * warpSize + idx] = ic7;

  fc[8 * warpSize + idx] = fc8;
  ic[8 * warpSize + idx] = ic8;

  fc[9 * warpSize + idx] = fc9;
  ic[9 * warpSize + idx] = ic9;

  ts[idx] = start;
  te[idx] = end;
}


int main() {

  const size_t bytes = warpSize * batchSize * sizeof(float);


  float *hFa = (float *)malloc(bytes);
  float *hFc = (float *)malloc(bytes);

  uint32_t *hIa = (uint32_t *)malloc(bytes);
  uint32_t *hIc = (uint32_t *)malloc(bytes);

  uint64_t *hS = (uint64_t *)malloc(warpSize * warpNum * sizeof(uint64_t));
  uint64_t *hE = (uint64_t *)malloc(warpSize * warpNum * sizeof(uint64_t));

  for (int i = 0; i < warpSize * batchSize; ++i) {
    hFa[i] = 1.0f;
    hIa[i] = 1;
  }

  float *dFA, *dFC;
  uint32_t *dIA, *dIC;

  uint64_t *dS, *dE;
  float* d_warm_result;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaMalloc(&d_warm_result, sizeof(float));

  cudaMalloc(&dFA, bytes);
  cudaMalloc(&dFC, bytes);
  cudaMalloc(&dIA, bytes);
  cudaMalloc(&dIC, bytes);

  cudaMalloc(&dS, warpSize * warpNum * sizeof(uint64_t));
  cudaMalloc(&dE, warpSize * warpNum * sizeof(uint64_t));

  cudaMemcpy(dFA, hFa, bytes, cudaMemcpyHostToDevice);
  cudaMemcpy(dIA, hIa, bytes, cudaMemcpyHostToDevice);

  // 预热 GPU，尽量让 SM 时钟进入稳定状态
  cudaDeviceProp prop;
  cudaGetDeviceProperties(&prop, 0);
  int warm_blocks = prop.multiProcessorCount * 4;

  for(uint64_t i = 0; i < 100; i++){
    warmup<<<warm_blocks, 1024>>>(1.0, 1.0, d_warm_result);
  }
  cudaDeviceSynchronize();

  // 一个warp
  // 输出 dFC 是 20 batch * 32 threads 的二维数组
  //
  memset(hFc, 0, bytes);
  memset(hIc, 0, bytes);
  memset(hS, 0, warpSize * warpNum * sizeof(uint64_t));
  memset(hE, 0, warpSize * warpNum * sizeof(uint64_t));

  // 记录开始事件
  cudaEventRecord(start);
  fma_imad_uni_warp<<<1, 32 * 1>>>(dFA, 1.0f, dFC, dIA, 1, dIC ,dS, dE);
  // 记录结束事件
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);  // 等待事件完成

  // 计算时间差（毫秒）
  float ms = 0;
  cudaEventElapsedTime(&ms, start, stop);
  cudaDeviceSynchronize();


  cudaMemcpy(hFc, dFC, bytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(hIc, dIC, bytes, cudaMemcpyDeviceToHost);
  cudaMemcpy(hS, dS, warpSize * warpNum * sizeof(uint64_t), cudaMemcpyDeviceToHost);
  cudaMemcpy(hE, dE, warpSize * warpNum * sizeof(uint64_t), cudaMemcpyDeviceToHost);


  printf("ret = %f\n", hFc[0]);
  printf("ret = %d\n", hIc[0]);

  std::set<float>   rfSet;
  std::set<int32_t> rISet;

  for(int i = 0; i < warpSize * batchSize; i++){
    rfSet.insert(hFc[i]);
    rISet.insert(hIc[i]);
  }

  if(rfSet.size() != 1){
    printf("reselt error\n");
  }

  if(rISet.size() != 1){
    printf("reselt error\n");
  }

  std::set<uint64_t> tsSet;
  std::set<uint64_t> teSet;

  tsSet.clear();
  teSet.clear();

  for(int i = 0; i < warpSize; i++){

    tsSet.insert(hS[i]);
    teSet.insert(hE[i]);

  }

  uint64_t S = 0;
  uint64_t E = 0;

  S = *tsSet.begin();
  E = *teSet.rbegin();

  printf("uniwarp total cycles %lu\n", E - S);
  printf("fma + mad avg lantency: %f\n", (double)(E - S) / (double)(batchSize * ITER));
  cudaDeviceSynchronize();
  cudaFree(dFA);
  cudaFree(dIA);
  cudaFree(dFC);
  cudaFree(dS);
  cudaFree(dE);
  free(hFa);
  free(hIa);
  free(hFc);
  free(hS);
  free(hE);

  return 0;
}
