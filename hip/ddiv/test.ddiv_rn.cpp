#include <cstdint>
#include <fstream>
#include <hip/hip_runtime.h>
#include <iostream>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
//#include <hip/rocrand.h>
using namespace std;

__attribute__((noinline)) __device__ double slow_drcp_rn(double x) {

	double r0 = 0.0;
	double ret = x;
	double x0 = x;

	uint32_t* x0_hi = (uint32_t*)&x0 + 1;
	uint32_t* x0_lo = (uint32_t*)&x0;
	uint32_t* r0_hi = (uint32_t*)&r0 + 1;
	uint32_t* r0_lo = (uint32_t*)&r0;

	// return 1.0/x;
	if (isnan(x0)) { // nan
		*x0_hi = *x0_hi | 0x80000;
		return x0;
	}

	uint32_t x0_hi_no_sign = *x0_hi & 0x7fffffff;

	if (((uint32_t)(x0_hi_no_sign - 0x1) >= 0x7fefffff)) { // inf denormal
		*x0_hi ^= 0x7ff00000;
		*x0_lo = 0x0;
		return x0;
	}

	double fixup;
	uint32_t* fixup_lo = (uint32_t*)&fixup + 0;
	uint32_t* fixup_hi = (uint32_t*)&fixup + 1;
	*fixup_hi = 0x0;

	if (x0_hi_no_sign >= 0x1000001) {

		uint32_t r0_lo_tmp = (*x0_hi | 0x7fffffff) - 0x100000;
		*x0_hi = *x0_hi - 0x3fe00000;
		r0 = __builtin_amdgcn_rcp(x0);
		*r0_lo = r0_lo_tmp;
		*fixup_hi = 0x00100000;
		//*(uint64_t*)&fixup = 0x0010000006067828;
		//*(uint64_t*)&fixup = 0x0010000000000000;

		// double d1  = -x0 * r0 + 1.0
		// double dd1 = d1 * d1 + d1
		// double r1  = r0 * dd1 + r0
		// double d2  = -x0 * r1 + 1.0
		// double r2  = r1 * d2 + r1
		// double r3 = r2 * (double)0x0010000006067828
		// double d3  = r3 * -x + 1.0;
		// double dd3 = d3 * d3 + d3
		// double r4  = r3 * dd3 + r3

		double d1 = __builtin_fma(r0, -x0, 1.0);
		double dd1 = __builtin_fma(d1, d1, d1);
		double r1 = __builtin_fma(r0, dd1, r0);
		double d2 = __builtin_fma(-x0, r1, 1.0);
		double r2 = __builtin_fma(r1, d2, r1);
		double r3 = r2 * fixup;
		double d3 = __builtin_fma(r3, -x, 1.0);
		double dd3 = __builtin_fma(d3, d3, d3);
		double r4 = __builtin_fma(r3, dd3, r3);
		return r4;
	}
	else {
		*fixup_hi = 0x46900000;
		//*(uint64_t*)&fixup = 0x4690000000000000;// 2^106
		uint32_t r0_lo_tmp = (*x0_hi | 0x7fffffff) - 0x100000;

		x0 = x0 * fixup;
		r0 = __builtin_amdgcn_rcp(x0);
		*r0_lo = r0_lo_tmp;

		double d1 = __builtin_fma(-x0, r0, 1.0);
		double dd1 = __builtin_fma(d1, d1, d1);
		double r1 = __builtin_fma(r0, dd1, r0);
		double d2 = __builtin_fma(-x0, r1, 1.0);
		double r2 = __builtin_fma(r1, d2, r1);

		return r2 * fixup;
	}

	return 0.0;
}

__device__ double ___ddiv_rn(double x, double y) {

	double r0 = 0.0;
	double ret = x;
	double x0 = x;
	double y0 = y;
	uint32_t* x0_hi = (uint32_t*)&x0 + 1;
	uint32_t* x0_lo = (uint32_t*)&x0;
	uint32_t* y0_hi = (uint32_t*)&y0 + 1;
	uint32_t* y0_lo = (uint32_t*)&y0;
	uint32_t* r0_hi = (uint32_t*)&r0 + 1;
	uint32_t* r0_lo = (uint32_t*)&r0;

	// double x0_mantissa = __builtin_amdgcn_frexp_mant(x0);
	// int32_t x0_exp = __builtin_amdgcn_frexp_exp(x0);
	// float x0_mantissa_f32 = (float) x0_mantissa;
	// float r0_mantissa_f32 = __builtin_amdgcn_rcpf(x0_mantissa_f32);
	// double r0_mantiss = (double)r0_mantissa_f32;
	// r0 = __builtin_amdgcn_ldexp(r0_mantiss, -x0_exp);

	r0 = __builtin_amdgcn_rcp(x0);
	*r0_lo = 0x1;

	if (!(abs(*(float*)r0_lo) < (float)5.878909486335835e-39)) {

		// iteration
		double d1 = __builtin_fma(r0, -y0, 1.0);
		double dd1 = __builtin_fma(d1, d1, d1);
		double r1 = __builtin_fma(r0, dd1, r0);
		double d2 = __builtin_fma(r1, -y0, 1.0);
		double r2 = __builtin_fma(r1, d2, r1);
		double q1 = r2 * x0;
		double d3 = __builtin_fma(q1, -y0, x0);
		double q2 = __builtin_fma(r2, d3, q1);
		return q2;
	}
	return 0.0;
	//return slow_drcp_rn(x);
}

__global__ void test_ddiv(double* out, double* x, double* y) {
	int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
	double ret = ___ddiv_rn(x[idx], y[idx]);
	out[idx] = ret;
}

int main(int argc, char* argv[]) {
	float tCpu, tGpu, tSharedMemGpu;
	clock_t cpuStart, cpuEnd;
	hipEvent_t gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
	hipDeviceProp_t devProp;
	hipGetDeviceProperties(&devProp, 0);
	// time_t c_start, c_end;
	/* Initial input,output for the host and create memory objects for the
	 * kernel*/
	size_t griddim = 1024;
	size_t blockdim = 1024;
	size_t batch = 1;
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
	hipMalloc((void**)&inputBuffer_x, (batchlength) * sizeof(double));
	hipMalloc((void**)&inputBuffer_y, (batchlength) * sizeof(double));
	hipMalloc((void**)&outputBuffer, (batchlength) * sizeof(double));

	FILE* fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
	FILE* fp_ret = fopen("/home/centos/xwu/hip__ddiv_rn.txt", "w");

	hipEventCreate(&gpuStart);
	hipEventCreate(&gpuEnd);
	for (int j = 0; j < batch; j++) {
		for (int i = 0; i < batchlength; i++) {
			fscanf(fp_random, "%lx %lx", (uint64_t*)&input_x[i], (uint64_t*)&input_y[i]);
			//printf("%lx %lx\n", *(uint64_t *)&input_x[i], *(uint64_t *)&input_y[i]);
		}
		// input[0] = -0x0.0248f0000491cp-1022;
		//  input[0] = 0x1.947c0ffd28f8p+1023;
		// input[0] = 0x0.98e1600131c2cp-1022;
		//*(uint64_t *)&input[0] = 0xfff8000000000000;
		hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(double),
			hipMemcpyHostToDevice);
		hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(double),
			hipMemcpyHostToDevice);
		hipEventRecord(gpuStart, 0);
		hipLaunchKernelGGL(test_ddiv, dim3(griddim), dim3(blockdim), 0, 0,
			outputBuffer, inputBuffer_x, inputBuffer_y);
		hipEventRecord(gpuEnd, 0);
		hipEventSynchronize(gpuStart);
		hipEventSynchronize(gpuEnd);
		hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
		printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
		// std::cout << "GPU RUN TIME : " << tGpu * 1000 << " us" << std::endl;
		hipMemcpy(output, outputBuffer, (batchlength) * sizeof(double),
			hipMemcpyDeviceToHost);
		hipDeviceSynchronize();
		// printf("The pause used %f ms by clock()\n",difftime(c_end,c_start));
		for (int i = 0; i < batchlength; i++) {
			fprintf(fp_ret, "%lx\n", *(uint64_t*)&output[i]);
			// printf("%la, %lx\n", output[i], *(uint64_t *)&output[i]);
			// fprintf(fp_ret, "%la, %lx\n", output[i], *(uint64_t *)&output[i]);
		}
	}

	// Cleanup after kernel execution
	fclose(fp_random);
	fclose(fp_ret);
	hipFree(inputBuffer_x);
	hipFree(inputBuffer_y);
	hipFree(outputBuffer);
	free(input_x);
	free(input_y);
	free(output);

	return 0;
}
