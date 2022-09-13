#include <cmath>
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

__attribute__((noinline)) __device__ double slow_ddiv_rn(double y, double x) {
	double ret = x;
	double x0  = x;
	double y0  = y;
	double r0  = 0.0;

	uint32_t* y0_hi = (uint32_t*)&y0 + 1;
	uint32_t* y0_lo = (uint32_t*)&y0;
	uint32_t* x0_hi = (uint32_t*)&x0 + 1;
	uint32_t* x0_lo = (uint32_t*)&x0;
	uint32_t* r0_hi = (uint32_t*)&r0 + 1;
	uint32_t* r0_lo = (uint32_t*)&r0;

	// return 1.0/x;
	//if (isnan(x0)) { // nan
	//	*x0_hi = *x0_hi | 0x80000;
	//	return x0;
	//}

	//uint32_t x0_hi_no_sign = *x0_hi & 0x7fffffff;

	//if (((uint32_t)(x0_hi_no_sign - 0x1) >= 0x7fefffff)) { // inf denormal
	//	*x0_hi ^= 0x7ff00000;
	//	*x0_lo = 0x0;
	//	return x0;
	//}

	double scale_x;
	double scale_y;
  double scale_q; 
	uint32_t* scale_x_lo = (uint32_t*)&scale_x + 0;
	uint32_t* scale_x_hi = (uint32_t*)&scale_x + 1;
	uint32_t* scale_y_lo = (uint32_t*)&scale_y + 0;
	uint32_t* scale_y_hi = (uint32_t*)&scale_y + 1;
	uint32_t* scale_q_lo = (uint32_t*)&scale_q + 0;
	uint32_t* scale_q_hi = (uint32_t*)&scale_q + 1;

  if( (*x0_hi & 0x40000000) >= 0x40000000 ){
    *scale_x_hi = 0x1ff00000;// 2^-52
  }else {
    *scale_x_hi = 0x5ff00000;// 2^52
  }
  *scale_x_lo = 0x0;
  if( (*y0_hi & 0x7f800000) >= 0x3e800000 ){
    *scale_y_hi = 0x1ff00000;
  }else{
    *scale_y_hi = 0x5ff00000;
  }
  *scale_y_lo = 0x0;

  if( (*y0_hi & 0x7f800000) >= 0x3e800000 ){
    *scale_q_hi = 0x5ff00000; // 2^512
  }else{
    *scale_q_hi = 0x1ff00000; // 2^(-512)
  }
  *scale_q_lo = 0x0;

  double x1 = x0 * scale_x;
  double y1 = y0 * scale_y;
  r0 = __builtin_amdgcn_rcp(x1);
  *r0_lo = 0x1;

  double d1  = __builtin_fma(-x1, r0, 1.0);
  double dd1 = __builtin_fma(d1, d1, d1);
  double r1  = __builtin_fma(r0, dd1, r0);
  double d2  = __builtin_fma(-x1, r1, 1.0);
  double r2  = __builtin_fma(r1, d2, r1);
  double q1  = y1 * r2;
  double d3  = __builtin_fma(-x1, q1, y1);
  double q2  = __builtin_fma( r2, d3, q1);
  
  if( abs(q2) > 0.0){
    double q3_1 = q2 * scale_x * scale_q;
    double q3_2 = q2 * scale_q * scale_x;

    double dq1 = __builtin_fma(q3_1, x0, y0);
    double dq2 = __builtin_fma(q3_2, x0, y0);

    double q4;
    uint32_t* q4_lo = (uint32_t*)&q4 + 0;
    uint32_t* q4_hi = (uint32_t*)&q4 + 1;
    if (fabs(dq1) > fabs(dq2)) {
      q4 = q3_2;
    }else{
      q4 = q3_1;
    }
    uint32_t twon126 = 0x00100000;
    if( !(fabs(*(float*)q4_hi) <= *(float*)&twon126)){
      return q4;
    }
   
    /////////////////////////////////
    uint32_t twon119 = 0x04000000;
    if( !( fabs(*(float *)y0_hi) < *(float*)&twon119)){
      *scale_q_hi = 0x3ff00000;
    }else{
      *scale_q_hi = 0x58500000;
    }
    *scale_q_lo = 0x0;
    
    double q5_1 = q4; 
    uint32_t* q5_1_lo = (uint32_t*)&q5_1 + 0;
    uint32_t* q5_1_hi = (uint32_t*)&q5_1 + 1;
    *q5_1_lo = *q5_1_lo | 0x1;

    double q5_2 = q4; 
    uint32_t* q5_2_lo = (uint32_t*)&q5_2 + 0;
    uint32_t* q5_2_hi = (uint32_t*)&q5_2 + 1;
    *q5_2_lo = *q5_2_lo & 0xfffffffe;
    
    //*q4_lo = *q4_lo & 0xfffffffe;
    double x2 = x0 * scale_q;
    double y2 = y0 * scale_q;

    double dq2_1 = q5_1 * x2 - y2;
    double dq2_2 = q5_2 * x2 - y2;

    double q6; 
    uint32_t* q6_lo = (uint32_t*)&q6 + 0;
    uint32_t* q6_hi = (uint32_t*)&q6 + 1;
    if(fabs(dq2_1) > fabs(dq2_2)){
      q6 = q5_2;
    }else{
      q6 = q5_1;
    }

    uint32_t R10 = *q6_lo + 0x1;
    //uint32_t R2  = *q6_lo & 0x1;
    uint32_t R4  = *q6_lo - 0x1;
    uint32_t R3  = *q4_hi - 0x1;

    double q7_1; 
    uint32_t* q7_1_lo = (uint32_t*)&q7_1 + 0;
    uint32_t* q7_1_hi = (uint32_t*)&q7_1 + 1;
    double q7_2; 
    uint32_t* q7_2_lo = (uint32_t*)&q7_2 + 0;
    uint32_t* q7_2_hi = (uint32_t*)&q7_2 + 1;
    if((*q6_lo & 0x1) != 0x1){
      //
      *q7_1_lo = *q6_lo;
      *q7_1_hi = *q6_hi;
      //
      *q7_2_lo = *q6_lo - 0x1;
      *q7_2_hi = *q6_hi - 0x1;
    }else {
      *q7_1_lo = *q6_lo + 0x1;
      *q7_1_hi = *q6_hi;
      //
      *q7_2_lo = *q6_lo;
      *q7_2_hi = *q6_hi;
    }

    double dq3_1 = x2 * q7_1 - y2;
    double dq3_2 = x2 * q7_2 - y2;
    
    double q8;
    if (fabs(dq3_1) > fabs(dq3_2) ) {
      q8 = q7_2;
    }else{
      q8 = q7_1;
    }
    return q8;
  }else
  {
    ;
  }
	
	return 0.0;
}

__device__ double ___ddiv_rn(double y, double x) {

  double r0 = 0.0;
  double ret = x;
  double y0 = y;
  double x0 = x;
  uint32_t *y0_hi = (uint32_t *)&y0 + 1;
  uint32_t *y0_lo = (uint32_t *)&y0;
  uint32_t *x0_hi = (uint32_t *)&x0 + 1;
  uint32_t *x0_lo = (uint32_t *)&x0;
  uint32_t *r0_hi = (uint32_t *)&r0 + 1;
  uint32_t *r0_lo = (uint32_t *)&r0;

	// double x0_mantissa = __builtin_amdgcn_frexp_mant(x0);
	// int32_t x0_exp = __builtin_amdgcn_frexp_exp(x0);
	// float x0_mantissa_f32 = (float) x0_mantissa;
	// float r0_mantissa_f32 = __builtin_amdgcn_rcpf(x0_mantissa_f32);
	// double r0_mantiss = (double)r0_mantissa_f32;
	// r0 = __builtin_amdgcn_ldexp(r0_mantiss, -x0_exp);

	r0 = __builtin_amdgcn_rcp(x0);
	*r0_lo = 0x1;

  //if (!(abs(*(float *)r0_lo) < (float)5.878909486335835e-39)) {

  // iteration
  double d1  = __builtin_fma(r0, -x0, 1.0);
  double dd1 = __builtin_fma(d1, d1, d1);
  double r1  = __builtin_fma(r0, dd1, r0);
  double d2  = __builtin_fma(r1, -x0, 1.0);
  double r2  = __builtin_fma(r1, d2, r1);
  double q1  = r2 * y0;
  double d3  = __builtin_fma(q1, -x0, y0);
  double q2  = __builtin_fma(r2,  d3, q1);


  uint32_t *q2_hi = (uint32_t *)&q2 + 1;
  uint32_t *q2_lo = (uint32_t *)&q2;

  uint32_t toosmall = 0x00055555;
  if( *(float *)q2_hi > *(float *)&toosmall){
    return q2;
  }
  //}
  //return 0.0;
  return slow_ddiv_rn(y, x);
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
