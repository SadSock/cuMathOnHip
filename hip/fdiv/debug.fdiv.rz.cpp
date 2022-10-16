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

// Class mask bits

#define CLASS_SNAN 0x001
#define CLASS_QNAN 0x002
#define CLASS_NINF 0x004
#define CLASS_NNOR 0x008
#define CLASS_NSUB 0x010
#define CLASS_NZER 0x020
#define CLASS_PZER 0x040
#define CLASS_PSUB 0x080
#define CLASS_PNOR 0x100
#define CLASS_PINF 0x200

__device__ float __fdiv_rz(float y, float x) {
  
  uint32_t rounding_mode = __builtin_amdgcn_s_getreg(2049);

  uint32_t y_u32     = *(uint32_t *)&y;
  uint32_t x_u32     = *(uint32_t *)&x;
  uint32_t y_exp     = (y_u32 << 1 >> 24);
  uint32_t x_exp     = (x_u32 << 1 >> 24);
  uint32_t fixup_exp = 0;

  printf("y = %x\n", y_u32);
  printf("y_exp = %x\n", y_exp);
  printf("x = %x\n", x_u32);
  printf("x_exp = %x\n", x_exp);
 
  float x0 = x;
  float y0 = y;
  float r0;
  uint32_t &x0_u32 = *(uint32_t *)&x0;
  uint32_t &y0_u32 = *(uint32_t *)&y0;
  uint32_t &r0_u32 = *(uint32_t *)&r0;
  
  // y_exp == 0 or y_exp == 0xff x_exp == 0 or x_exp == 0xff 
  // x0 is zero, nan, inf, denormal or y0 is zero, nan, inf, denormal
  /*00e0*/
  if (y_exp - 1 > 0xfd || x_exp - 1 > 0xfd) {
    printf("hello /*00e0*/\n");
    /*0110*/
    if(isnan(x)||isnan(y)){
      /*0140*/
      printf("hello /*0140*/\n");
      //input_y = 0xff8e8144;
      //input_x = 0x6164c441;   
      float ret = 0;
      uint32_t &ret_u32 = *(uint32_t *)&ret;
      ret_u32 = 0x7fffffff; //TODO: FADD.FTZ R5, R9, c[0x0][0x16c] ???
      return ret;
    }
    
    /*0160*/  
    bool x_is_zero = false;
    bool y_is_zero = false;
    
    if((y_u32 << 1) != 0){// y is nan/inf/denormal
      y_is_zero = false;
    }else{// y is zero
      y_is_zero = true;
    }
    if((x_u32 << 1) != 0){// x is nan/inf/denormal
      x_is_zero = false;
    }else{// x is zero
      x_is_zero = true;
    }
    
    // 0.0 / 0.0 ??
    /*01f0*/
    if(!(x_is_zero && y_is_zero)){
      bool x_not_inf = false;
      bool y_not_inf = false;
      /*01c0*/
      x_not_inf = fabs(x) != INFINITY;
      y_not_inf = fabs(y) != INFINITY;

      if(x_not_inf || y_not_inf){
        /*0220*/
        printf("hello /*0220*/\n");
        uint32_t R8 = 0x1;
        if(x_not_inf)
          R8 = 0x0;
        if(R8 || y_is_zero){// x is inf or y is zero
          //input_y = 0xc81aab7f;
          //input_x = 0x7f800000;
          float ret = 0;
          uint32_t &ret_u32 = *(uint32_t *)&ret;
          ret_u32 = ((x_u32 ^ y_u32) & 0x80000000);// return 0.0;
          return ret;
        }
        /*0270*/                      
        printf("hello /*0270*/\n");
        uint32_t R5 = 0x1;
        if(y_not_inf){
          R5 = 0x0;
        }
        if(R5 || x_is_zero){// x is zero or y is inf
          //input_y = 0x7f800000;
          //input_x = 0xc81aab7f;
          float ret = 0;
          uint32_t &ret_u32 = *(uint32_t *)&ret;
          ret_u32 = ((x_u32 ^ y_u32) & 0x80000000) | 0x7f800000; //return inf
          return ret;
        }
        /*02d0*/ 
        if((int32_t)y_exp - 1 < 0){
          //input_y = 0x6d37b;
          //input_x = 0xd689a049;
          fixup_exp             = -0x40;
          float scale_y         = 0.0;
          uint32_t& scale_y_u32 = *(uint32_t *)&scale_y;
          scale_y_u32           = 0x5f800000; // 2^64
          printf("y0 = %x\n", y0_u32);
          y0                    = y0 * scale_y;
          printf("y0 = %x\n", y0_u32);
        }
        /*0330*/  
        if((int32_t)x_exp - 1 < 0){
          /*0340*/
          //input_y = 0x2cb5ac;
          //input_x = 0x402fec;

          fixup_exp             = fixup_exp + 0x40;
          float scale_x         = 0.0;
          uint32_t& scale_x_u32 = *(uint32_t *)&scale_x;
          scale_x_u32           = 0x5f800000; // 2^64
          x0                    = x0 * scale_x;
        }
      }else{
        /*0200*/ 
        printf("hello /*0200*/\n");
        //input_y = 0x7f800000;
        //input_x = 0x7f800000;   
        float ret = 0;
        uint32_t &ret_u32 = *(uint32_t *)&ret;
        ret_u32 = 0x7fffffff; //TODO: MUFU.RSQ R0, -QNAN ???
        return ret;
      }

    }else{
      /*0200*/ 
      printf("hello /*0200*/\n");
      //input_y = 0x0;
      //input_x = 0x0;   
      float ret = 0;
      uint32_t &ret_u32 = *(uint32_t *)&ret;
      ret_u32 = 0x7fffffff; //TODO: MUFU.RSQ R0, -QNAN ???
      return ret;
    }
  }
  
  /*0360*/
  /*0370*/
  // 0x7f is the base of float's exp
  // scale the exp of x to 0x7f
  // scale the exp of x to 0x7f
  printf("x0 = %x\n", x0_u32);
  printf("y0 = %x\n", y0_u32);
  printf("x_exp - 0x7f = %x\n", x_exp - 0x7f);
  printf("y_exp - 0x7f = %x\n", y_exp - 0x7f);
  x0_u32 = x0_u32 - ((x_exp - 0x7f) << 23);
  y0_u32 = y0_u32 - ((y_exp - 0x7f) << 23);

  r0 = __builtin_amdgcn_rcpf(x0);
  float x1 = __builtin_amdgcn_classf(x0, CLASS_PSUB|CLASS_NSUB) ? 0.0 : - x0;
  uint32_t &r1_u32 = *(uint32_t *)&x1;
  
  /*03d0*/
  printf("y0 = %x\n", y0_u32);
  printf("x0 = %x\n", x0_u32);
  printf("r0 = %x\n", r0_u32);
  printf("r1 = %x\n", r1_u32);
  float q0  = __builtin_fmaf(y0, r0, 0.0);
  float dd0 = __builtin_fmaf(x1, q0, y0);
  float q1  = __builtin_fmaf(r0, dd0, q0);
  float dd1 = __builtin_fmaf(x1, q1, y0);
  //asm volatile("");                                                  
  //; (mode register ID = 1) | (Offset << 6) | ((Width - 1) << 11)
  //; Offset: fp_round = 0, fp_denorm = 4, dx10_clamp = 8, ieee_mode = 9
  __builtin_amdgcn_s_setreg(2049, 3);
  //asm volatile("");                                                  
  float q2  = __builtin_fmaf(r0, dd1, q1);
  __builtin_amdgcn_s_setreg(2049, rounding_mode);
  uint32_t &q2_u32 = *(uint32_t *)&q2;
  printf("q2 = %x\n", q2_u32);
  uint32_t q2_exp = ((*(uint32_t *)&q2) << 1) >> 24;
  uint32_t dx_exp = q2_exp + y_exp - x_exp + fixup_exp - 1;
  printf("y_exp = %x\n", y_exp);
  printf("x_exp = %x\n", x_exp);
  printf("fixup_exp = %x\n", fixup_exp);
  printf("q2_exp = %x\n", q2_exp);
  printf("dx_exp = %x\n", dx_exp);
  /*0470*/
  if (dx_exp > 0xfd) { // y is too small
    printf("hello 04b0\n");
    /*04b0*/
    float q3 = 0;
    uint32_t &q3_u32 = *(uint32_t *)&q3;
    /*04c0*/
    q3 = q2;
    if((int32_t)(q2_exp + y_exp - x_exp + fixup_exp) > 0xfe){
      /*04d0*/
      printf("hello 04d0\n");
      // y = 0xea4ac567;
      // x = 0xc8e52e7; 
      q3_u32 = 0x7f7fffff;
    }else{
      /*04f0*/
      if((int32_t)(q2_exp + y_exp - x_exp + fixup_exp) > 0){
        ;
      }else {
        /*0510*/
        if ((int32_t)(q2_exp + y_exp - x_exp + fixup_exp) >= -0x18) {
          /*0520*/
          //input_y = 0x20dc8f49;
          //input_x = 0xe7a8f7b8;
          printf("hello 0520\n");
          printf("q2_exp + y_exp - x_exp + fixup_exp = %x\n", q2_exp + y_exp - x_exp + fixup_exp);
          q3_u32 = q2_u32 & 0x7fffff;
          q3_u32 = q3_u32 | 0x800000;
          printf("q3_u32 = %x\n", q3_u32);
          q3_u32 = q3_u32 >> (1 - (q2_exp + y_exp - x_exp + fixup_exp));
          printf("q3_u32 = %x\n", q3_u32);
        }else{
          /*0530*/
          printf("hello 0530\n");
          //input_y = 0x6d37b;
          //input_x = 0xd689a049;
          q3_u32 = 0x0;
        }
      }
    }
    q3_u32 = q3_u32 | ( q2_u32 & 0x80000000);
    return q3;
  }else{
    /*0480*/
    //input_y = 0x63f410f3;   
    //input_x = 0x59d05c18;   
    float q3 = 0;
    uint32_t &q3_u32 = *(uint32_t *)&q3;
    q3_u32 = ((y_exp - x_exp + fixup_exp) << 23) + q2_u32;
    return q3;
  }
}

__global__ void test_fdiv_rz(float* out, float* x, float* y) {
	int idx = hipThreadIdx_x + hipBlockDim_x * hipBlockIdx_x;
	float ret = __fdiv_rz(x[idx], y[idx]);
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
	size_t griddim = 1;
	size_t blockdim = 1;
	size_t batch = 1;
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

	//FILE* fp_random = fopen("/home/centos/xwu/float.random.txt", "r");
  //FILE* fp_ret = fopen("/home/centos/xwu/hip__fdiv_rz.txt", "w");
  //	FILE* fp_ret = fopen("/dev/shm/hip__ddiv_rn.txt", "w");

	hipEventCreate(&gpuStart);
	hipEventCreate(&gpuEnd);
	for (int j = 0; j < batch; j++) {
		for (int i = 0; i < batchlength; i++) {
			//fscanf(fp_random, "%x %x", (uint32_t*)&input_y[i], (uint32_t*)&input_x[i]);
			//printf("%lx %lx\n", *(uint64_t *)&input_x[i], *(uint64_t *)&input_y[i]);
		}
    
    *(uint32_t*)&input_y[0] = 0x7f800000;
    *(uint32_t*)&input_x[0] = 0x7f800000;

    hipMemcpy(inputBuffer_x, input_x, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipMemcpy(inputBuffer_y, input_y, (batchlength) * sizeof(float),
              hipMemcpyHostToDevice);
    hipEventRecord(gpuStart, 0);
    hipLaunchKernelGGL(test_fdiv_rz, dim3(griddim), dim3(blockdim), 0, 0, outputBuffer, inputBuffer_y, inputBuffer_x);
    hipEventRecord(gpuEnd, 0);
    hipEventSynchronize(gpuStart);
    hipEventSynchronize(gpuEnd);
    hipEventElapsedTime(&tGpu, gpuStart, gpuEnd);
    printf(" %d GPU RUN TIME : %f us\n", j, tGpu * 1000);
    hipMemcpy(output, outputBuffer, (batchlength) * sizeof(float),
              hipMemcpyDeviceToHost);
    hipDeviceSynchronize();
		for (int i = 0; i < batchlength; i++) {
			//fprintf(fp_ret, "%x\n", *(uint32_t*)&output[i]);
      printf("%x\n", *(uint32_t*)&output[i]);
		}
	}

	// Cleanup after kernel execution
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
