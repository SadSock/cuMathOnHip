#include <cuda_runtime.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

__global__ void ddiv(double* out, double* x1, double* x2)
{
	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	out[idx] = __ddiv_rn(x1[idx], x2[idx]);
	return;
}

int main()
{
	size_t griddim = 1024;
	size_t blockdim = 1024;
	size_t batch = 100;
	size_t batchlength = griddim * blockdim;
	double* output = (double*)malloc(batchlength * sizeof(double));
	double* input_x = (double*)malloc(batchlength * sizeof(double));
	double* input_y = (double*)malloc(batchlength * sizeof(double));
	memset(input_x, 0, batchlength * sizeof(double));
	memset(input_y, 0, batchlength * sizeof(double));
	memset(output, 0, batchlength * sizeof(double));

	// Allocate device memory
	double* inputBuffer_x;
	double* inputBuffer_y;
	double* outputBuffer;
	cudaMalloc((void**)&inputBuffer_x, (batchlength) * sizeof(double));
	cudaMalloc((void**)&inputBuffer_y, (batchlength) * sizeof(double));
	cudaMalloc((void**)&outputBuffer, (batchlength) * sizeof(double));

	FILE* fp_random = fopen("../../float.random.txt", "r");
	FILE* fp_ret = fopen("../../cuda__ddiv_rn.txt", "w");

	for (int j = 0; j < batch; j++) {
		for (int i = 0; i < batchlength; i++) {
			fscanf(fp_random, "%lx %lx", (uint64_t*)&input_x[i], (uint64_t*)&input_y[i]);
		}

		cudaMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double), cudaMemcpyHostToDevice);
		cudaMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double), cudaMemcpyHostToDevice);

		ddiv << <griddim, blockdim >> > (outputBuffer, inputBuffer_x, inputBuffer_y);

		cudaMemcpy(output, outputBuffer, (batchlength) * sizeof(double), cudaMemcpyDeviceToHost);

		cudaDeviceSynchronize();

		for (int i = 0; i < batchlength; i++) {
			fprintf(fp_ret, "%lx\n", *(uint64_t*)&output[i]);
		}
	}

	// Cleanup after kernel execution
	fclose(fp_random);
	fclose(fp_ret);
	cudaFree(inputBuffer_x);
	cudaFree(inputBuffer_y);
	cudaFree(outputBuffer);
	free(input_x);
	free(input_y);
	free(output);

	return 0;
}
