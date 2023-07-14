#include <stdio.h>
#include "cuda_runtime.h"
//using namespace nvcuda;

// CUDA kernel to compute dot product of two vectors
extern "C" __global__ void test_tanhf(float *ret,  float  x){

    *ret = tanhf(x);
    return;
}

int main(){
    int n = 1;
    int size = n * sizeof(float);
    float *a;

    // Allocate memory on host
    a = (float*) malloc(size);

    float x = 1.0;
    //int n = 1;

    // Allocate memory on device
    float *d_a;
    cudaMalloc((void**)&d_a, size);

    // Launch kernel on device
    int threads_per_block = 1;
    int num_blocks = (n + threads_per_block - 1) / threads_per_block;
    test_tanhf<<<num_blocks, threads_per_block>>>(d_a, x);

    // Copy output vector from device to host
    cudaMemcpy(a, d_a, size, cudaMemcpyDeviceToHost);


    printf("tanhf: %f\n", a[0]);

    // Free memory on device
    cudaFree(d_a);

    // Free memory on host
    free(a);


    return 0;
}
