#include <cstdint>
#include <cmath>
#include <hip/hip_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
using namespace std;

namespace hip {
__device__ float tgamma(float x) {

  float x0_f32       = x;

  float qnan_f32     = 0;
  uint32_t &qnan_u32 = *(uint32_t *)&qnan_f32;
  qnan_u32           = 0x7fffffff;

  if(isnan(x))
      return qnan_f32;

  if (x0_f32 >= 0.0) {

    float x1_f32        = 0;
    float x2_f32        = 0;
    float x3_f32        = 0;
    float x4_f32        = 0;
    float x5_f32        = 0;
    float x6_f32        = 0;
    float factorial_f32 = 1.0;
    float x8_f32        = 0;
    float x9_f32        = 0;
    float x10_f32       = 0;

    /*0030*/
    uint32_t c1_u32  = 0x3a8aa19e; // 0.00105767301283776760101318359375
    float    &c1_f32 = *(float *)&c1_u32;
    uint32_t c2_u32  = 0x3f800000;
    uint32_t c3_u32  = 0x42081eb8; // 34.029998779296875
    float    &c3_f32 = *(float *)&c3_u32;

    /*0060*/
    if (x0_f32 > 36.0) {
      x1_f32 = 36.0;
    } else {
      x1_f32 = x0_f32;
    }

    /*0090*/
    x2_f32   = x1_f32 - 1.0;

    /*0080*/
    if (x1_f32 > c3_f32) {
        /*00b0*/
      x3_f32 = x2_f32;
    } else {
      x3_f32 = x1_f32;
    }

    /*00d0*/
    x4_f32 = x3_f32 - 1.0;

    /*00c0*/
    while (x4_f32 > 0.5) {
      /*0100*/
        factorial_f32 = factorial_f32 * x4_f32;
        x4_f32        = x4_f32 - 1.0;
    }
    /*0160*/
    if (x1_f32 >= 0.5) {
        //x9_f32 = x8_f32 = x4_f32 - 1.0;
        x9_f32 = x4_f32;
    } else {
        //x9_f32 = x6_f32 = x4_f32;
        x9_f32 = x3_f32;
    }

    uint32_t  c4_u32  = 0x3be86aa4; // 0.00709279067814350128173828125
    float    &c4_f32  = *(float *)&c4_u32;
    float     y0_f32  = 0.0;
    y0_f32 = __builtin_fmaf(x9_f32, -c1_f32, c4_f32);

    uint32_t  c5_u32  = 0xbc1e2998;
    float    &c5_f32  = *(float *)&c5_u32;
    float     y1_f32  = 0.0;
    y1_f32 = __builtin_fmaf(x9_f32, y0_f32, c5_f32);

    uint32_t  c6_u32  = 0xbd2cbe4a;
    float    &c6_f32  = *(float *)&c6_u32;
    float     y2_f32  = 0.0;
    y2_f32 = __builtin_fmaf(x9_f32, y1_f32, c6_f32);

    uint32_t  c7_u32  = 0x3e2a8a17;
    float    &c7_f32  = *(float *)&c7_u32;
    float     y3_f32  = 0.0;
    y3_f32 = __builtin_fmaf(x9_f32, y2_f32, c7_f32);

    uint32_t  c8_u32  = 0xbd2c0cbb;
    float    &c8_f32  = *(float *)&c8_u32;
    float     y4_f32  = 0.0;
    y4_f32 = __builtin_fmaf(x9_f32, y3_f32, c8_f32);

    uint32_t  c9_u32  = 0xbf27e7a3;
    float    &c9_f32  = *(float *)&c9_u32;
    float     y5_f32  = 0.0;
    y5_f32 = __builtin_fmaf(x9_f32, y4_f32, c9_f32);

    uint32_t  c10_u32 = 0x3f13c468;
    float    &c10_f32 = *(float *)&c10_u32;
    float     y6_f32  = 0.0;
    y6_f32 = __builtin_fmaf(x9_f32, y5_f32, c10_f32);

    uint32_t  c11_u32 = 0x3f800000;
    float    &c11_f32 = *(float *)&c11_u32;
    float     y7_f32  = 0.0;
    y7_f32 = __builtin_fmaf(x9_f32, y6_f32, c11_f32);

    float     y8_f32  = y7_f32;
    if(x1_f32 < 0.5){
        /*0200*/
        y8_f32 = y7_f32 * x1_f32;
    }

    /*0210*/
    //y8 is denormal
    uint32_t  c12_u32 = 0x00800000; // 2^-126, the most small float except denormal
    float    &c12_f32 = *(float *)&c12_u32;
    uint32_t  c13_u32 = 0x4b800000; // 2^24
    float    &c13_f32 = *(float *)&c13_u32;
    float     y10_f32 = 0.0;

    if(fabs(y8_f32) < c12_f32){
        /*0220*/
        y8_f32        = y8_f32 * c13_f32;
        factorial_f32 = factorial_f32 * c13_f32;
    }

    //y10_f32 = __builtin_amdgcn_rcpf(y8_f32) * factorial_f32;
    y10_f32 = __frcp_rn(y8_f32) * factorial_f32;

    /*0080*/
    if (x1_f32 > c3_f32) {
        /*0260*/
      y10_f32 = y10_f32 * x2_f32;
    }

    return y10_f32;

  } else {
    /*0280*/
    // $L__BB0_5:
    float x1_f32        = 0;
    float x2_f32        = 0;
    float x3_f32        = 0;
    float x4_f32        = 0;
    float x5_f32        = 0;
    float x6_f32        = 0;
    float x7_f32        = 0;
    float x8_f32        = 0;
    float factorial_f32 = 1.0;

    uint32_t  c1_u32 = 0xc2246666;// -41.09999847412109375
    float    &c1_f32 = *(float *)&c1_u32;

    uint32_t  c2_u32 = 0xc2081eb8;// -34.029998779296875
    float    &c2_f32 = *(float *)&c2_u32;

    uint32_t c3_u32  = 0x3a8aa19e; // 0.00105767301283776760101318359375
    float    &c3_f32 = *(float *)&c3_u32;

    x1_f32 = __builtin_floorf(x0_f32);

    if(x0_f32 == x1_f32)         // x is integer
        x1_f32 = qnan_f32;
    else
        x1_f32 = x0_f32;

    if(x1_f32 < c1_f32)          // x < -41.09999847412109375
        x1_f32 = c1_f32;

    if(x1_f32 < c2_f32)          // x < -34.029998779296875
        x2_f32 = x1_f32 + 6.0;
    else
        x2_f32 = x1_f32;

    factorial_f32 = x2_f32;

    if(x2_f32 < -0.5){
        do{
            //$L__BB0_7:
           x2_f32        = x2_f32 + 1.0;
           factorial_f32 = factorial_f32 * x2_f32;
        }while(x2_f32 < -0.5);
    }

//$L__BB0_8:
    uint32_t  c4_u32 = 0x3be86aa4; // 0.00709279067814350128173828125
    float    &c4_f32 = *(float *)&c4_u32;
    float     y0_f32 = 0.0;
    y0_f32           = __builtin_fmaf(x2_f32, -c3_f32, c4_f32);

    uint32_t  c5_u32 = 0xbc1e2998;
    float    &c5_f32 = *(float *)&c5_u32;
    float     y1_f32 = 0.0;
    y1_f32           = __builtin_fmaf(x2_f32, y0_f32, c5_f32);

    uint32_t  c6_u32 = 0xbd2cbe4a;
    float    &c6_f32 = *(float *)&c6_u32;
    float     y2_f32 = 0.0;
    y2_f32           = __builtin_fmaf(x2_f32, y1_f32, c6_f32);

    uint32_t  c7_u32 = 0x3e2a8a17;
    float    &c7_f32 = *(float *)&c7_u32;
    float     y3_f32 = 0.0;
    y3_f32           = __builtin_fmaf(x2_f32, y2_f32, c7_f32);

    uint32_t  c8_u32 = 0xbd2c0cbb;
    float    &c8_f32  = *(float *)&c8_u32;
    float     y4_f32 = 0.0;
    y4_f32           = __builtin_fmaf(x2_f32, y3_f32, c8_f32);

    uint32_t  c9_u32 = 0xbf27e7a3;
    float    &c9_f32 = *(float *)&c9_u32;
    float     y5_f32 = 0.0;
    y5_f32           = __builtin_fmaf(x2_f32, y4_f32, c9_f32);

    uint32_t  c10_u32 = 0x3f13c468;
    float    &c10_f32 = *(float *)&c10_u32;
    float     y6_f32  = 0.0;
    y6_f32            = __builtin_fmaf(x2_f32, y5_f32, c10_f32);

    uint32_t  c11_u32 = 0x3f800000;
    float    &c11_f32 = *(float *)&c11_u32;
    float     y7_f32  = 0.0;
    y7_f32            = __builtin_fmaf(x2_f32, y6_f32, c11_f32);

    y7_f32 = y7_f32 * factorial_f32;
    y7_f32 = __frcp_rn(y7_f32);

    if(x1_f32 < c2_f32){          // x < -34.029998779296875
        factorial_f32 = x1_f32        * (x1_f32 + 1.0);
        factorial_f32 = factorial_f32 * (x1_f32 + 2.0);
        factorial_f32 = factorial_f32 * (x1_f32 + 3.0);
        factorial_f32 = factorial_f32 * (x1_f32 + 4.0);
        factorial_f32 = factorial_f32 * (x1_f32 + 5.0);
        y7_f32        = y7_f32 * __frcp_rn(factorial_f32);

        if(x0_f32 < -42.0){
            uint32_t &y7_u32 = *(uint32_t *)&y7_f32;
            asm volatile("V_CVT_FLR_I32_F32 %0, %1 "
                         : "=v"(y7_u32)
                         : "v"(x0_f32));
            if(!((y7_u32 & 0x1) == 1))
                y7_u32   = 0x80000000;
            else
                y7_u32   = 0x0;
        }
    }
    return y7_f32;
  }
}
} // namespace hip

__global__ void test_tgamma(float *out, float *x) {
    int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
    float ret = hip::tgamma(x[idx]);
    //float ret = tgamma(x[idx]);
    //printf("ret = %f %x", ret, *(uint32_t*)&ret);
    out[idx] = ret;
}

int main(int argc, char* argv[]) {
	float           tCpu, tGpu, tSharedMemGpu;
	clock_t         cpuStart, cpuEnd;
	hipEvent_t      gpuStart, gpuEnd, gpuSharedMemStart, gpuSharedMemEnd;
	hipDeviceProp_t devProp;
	hipGetDeviceProperties(&devProp, 0);
	// time_t c_start, c_end;
	/* Initial input,output for the host and create memory objects for the
	 * kernel*/
	size_t griddim = 102400;
	size_t blockdim = 1024;
	size_t batch = 100;
	size_t batchlength = griddim * blockdim;
	float* output = (float*)malloc(batchlength * sizeof(float));
	float* input_x = (float*)malloc(batchlength * sizeof(float));
	float* input_y = (float*)malloc(batchlength * sizeof(float));
	memset(input_x, 0, batchlength * sizeof(float));
	memset(input_y, 0, batchlength * sizeof(float));
	memset(output, 0, batchlength * sizeof(float));

	// Allocate device memory
	float* inputBuffer_x;
	float* inputBuffer_y;
	float* outputBuffer;
	hipMalloc((void**)&inputBuffer_x, (batchlength) * sizeof(float));
	hipMalloc((void**)&inputBuffer_y, (batchlength) * sizeof(float));
	hipMalloc((void**)&outputBuffer, (batchlength) * sizeof(float));

    FILE *fp_random = fopen("/home/xwu/float.random.unary.txt", "r");
    FILE *fp_ret    = fopen("/home/xwu/maca_tgamma.txt", "w");

	hipEventCreate(&gpuStart);
	hipEventCreate(&gpuEnd);
    for (int j = 0; j < batch; j++) {
        for (int i = 0; i < batchlength; i++) {
            fscanf(fp_random, "%x", (uint32_t *)&input_x[i]);
            //input_x[i] = -fabs(input_x[i]);
        }
    
        //*(uint32_t*)&input_x[0] = 0x420d999a;
        //input_x[0]              = 2.0;

        hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
                  hipMemcpyHostToDevice);
        hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
                  hipMemcpyHostToDevice);
        hipEventRecord(gpuStart, 0);
        hipLaunchKernelGGL(test_tgamma, dim3(griddim), dim3(blockdim), 0, 0, outputBuffer, inputBuffer_x);
        hipEventRecord(gpuEnd, 0);
        hipEventSynchronize(gpuStart);
        hipEventSynchronize(gpuEnd);
        hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
        printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
        hipMemcpy(output, outputBuffer, (batchlength) *   sizeof(float),
                  hipMemcpyDeviceToHost);
        hipDeviceSynchronize();
        for (int i = 0; i < batchlength; i++) {
            fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
        }
    }

	//Cleanup after kernel execution
	//fclose(fp_random);
	//fclose(fp_ret);
    hipFree(inputBuffer_x);
    hipFree(inputBuffer_y);
	hipFree(outputBuffer);
	free(input_x);
	free(input_y);
	free(output);

	return 0;
}
