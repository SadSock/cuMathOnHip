#include <hip/hip_runtime.h>
#include <hip/math_functions.h>
#include <hip/hip_runtime_api.h>


__device__ double amd_rsq_f64(double x){

  double root_f64;
  double mant_f64 = __builtin_amdgcn_frexp_mant(x);
  int exp = __builtin_amdgcn_frexp_exp(x);
  int old = exp & 1;
  exp = exp - old;

  mant_f64 = __builtin_amdgcn_ldexp(mant_f64, old);
  root_f64 = __builtin_amdgcn_rsqf(mant_f64);
  exp      = exp * 0.5;
  root_f64 = __builtin_amdgcn_ldexp(root_f64, -exp);
  return root_f64;
}

__global__ void __dsqrt_rd(double* out, double in) {

  uint64_t NaN = 0xFFF8000000000000;
  double two54 = 1.80143985094819840000e+16;  /* 43500000 00000000 */

  printf("input = %a\n", in);

  //if(in <  0.0 || isnan(in)){
  //  printf("%lf\n", *(double *)&NaN);
    //printf("%lf\n", nan(0));
  //  return;
  //}

  if(in == 0.0 || isinf(in)){
    printf("%lf\n", in);
    return;
  }

  bool scaled = false;
  uint64_t _in = *(uint64_t *)&in;

  _in = (_in << 1) >> 53;

  //printf("_in = %lu", _in);
  if(_in <= 1024){
    in = in * two54;
    scaled = true;
  }

  //printf("_in exp = %ld\n", _in);

  double a = in;
	//printf("%a %0.25f %lx\n", in, in, *(unsigned long*)&in);
  //printf("input = %0.30lf\n", a);
  //r0 = in;
	//double r0 = __builtin_amdgcn_rsq(a);
  double x = in;
  double root_f64;
  double mant_f64 = __builtin_amdgcn_frexp_mant(x);
  int exp = __builtin_amdgcn_frexp_exp(x);

  int old = exp & 1;
  exp = exp - old;

  mant_f64 = __builtin_amdgcn_ldexp(mant_f64, old);


  root_f64 = __builtin_amdgcn_rsqf(mant_f64);
  exp      = exp * 0.5;


  root_f64 = __builtin_amdgcn_ldexp(root_f64, -exp);


  //printf("exp = %d\n", exp);
  //if(exp <= -511){
    //exp = exp + 54;
  //  root_f64 = __builtin_amdgcn_ldexp(root_f64, -27);
  //  scaled = true;
  //}

  double r0 = root_f64;
  //double r0 = amd_rsq_f64(a);
	//printf("%a %0.25f %lx\n", r0, r0, *(unsigned long*)&r0);

  //rsq iter = 1
	double r0_1 = r0 * r0;
	//printf("%a %0.25f %lx\n", r0_1, r0_1, *(unsigned long*)&r0_1);
	double r0_2 = __builtin_fma(-a * 0.5, r0_1, 0.5);
	//printf("%a %0.25f %lx\n", r0_2, r0_2, *(unsigned long*)&r0_2);
	double r1   = __builtin_fma(r0, r0_2, r0);
	//printf("%a %0.25f %lx\n", r1, r1, *(unsigned long*)&r1);


  double s0 = r1 * a;
  double d0 = __builtin_fma(-s0, s0, a);
  double s1 = __builtin_fma( d0, r1 * 0.5, s0);

	double r1_1 = r1 * r1;
	//out[0] = r1_1;
	//printf("r1_1 = %a %0.25f %lx\n", r1_1 ,r1_1, *(unsigned long*)&r1_1);
  //double aa = -a * 0.5;
  //printf("-a * 0.5 = %a %0.25f %lx\n", aa, aa, *(unsigned long*)&aa);
	double r1_2 = __builtin_fma(-a * 0.5, r1_1, 0.5);
	double r2   = __builtin_fma(r1, r1_2, r1);
	//printf("%a %0.25f %lx\n", r2 ,r2, *(unsigned long*)&r2);

  double d1 = __builtin_fma(-s1, s1, a);

  uint32_t rounding_mode = 0;

  rounding_mode = 0x0;
  double rn = 0.0;
  asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, %2, %3, %4 ":"=v"(rn) : "s"(rounding_mode), "v"(d1), "v"(r2*0.5), "v"(s1) );
  //double rn = __builtin_fma(d1, r2 * 0.5, s1);

  if(scaled){
    rn = __builtin_amdgcn_ldexp(rn, -27);
  }

  printf("rn = %a %lx\n", rn , *(unsigned long*)&rn);
  //out[0] = rn;

  rounding_mode = 0x4;
  double ru = 0.0;
  asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, %2, %3, %4 ":"=v"(ru) : "s"(rounding_mode), "v"(d1), "v"(r2*0.5), "v"(s1) );
  //double rn = __builtin_fma(d1, r2 * 0.5, s1);
  if(scaled){
    ru = __builtin_amdgcn_ldexp(ru, -27);
  }
	printf("ru = %a %lx\n", ru , *(unsigned long*)&ru);

  rounding_mode = 0x8;
  double rd = 0.0;
  asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, %2, %3, %4 ":"=v"(rd) : "s"(rounding_mode), "v"(d1), "v"(r2*0.5), "v"(s1) );
  //double rn = __builtin_fma(d1, r2 * 0.5, s1);
  if(scaled){
    rd = __builtin_amdgcn_ldexp(rd, -27);
  }
	printf("rd = %a %lx\n", rd ,*(unsigned long*)&rd);

  rounding_mode = 0xc;
  double rz = 0.0;
  asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, %2, %3, %4 ":"=v"(rz) : "s"(rounding_mode), "v"(d1), "v"(r2*0.5), "v"(s1) );
  //double rn = __builtin_fma(d1, r2 * 0.5, s1);

  if(scaled){
    rz = __builtin_amdgcn_ldexp(rz, -27);
  }
  printf("rz = %a %lx\n", rz , *(unsigned long*)&rz);

  //rounding_mode = 0xc;
  //asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %0": : "s"(rounding_mode));
  //double rz = __builtin_fma(d1, r2 * 0.5, s1);
  //out[1] = rz;

  //printf("rz = %a %0.25f %lx\n", rz , rz, *(unsigned long*)&rz);
  //double r2_1 = r2 * r2;
	//double r2_2 = __builtin_fma(-a * 0.5, r2_1, 0.5);
	//double r3   = __builtin_fma(r2, r2_2, r2);
	//printf("%a %0.25f %lx\n", r3 ,r3, *(unsigned long *)&r3);

	//double _s0  = a * r0;
	//double _h0  = 0.5 * r0;
	//double _r0  = __builtin_fma(-_h0, _s0, 0.5);
	//double _rsq = __builtin_fma(r0, _r0, r0);
	//printf("%a %0.25f %lx\n", _rsq , _rsq, *(unsigned long *) &_rsq);

	//out[1] = r3;
}


int main(int argc, char* argv[]){

  //printf("%a\n", 0.0000000000001);

  //double input = 0x1.7ba0041886991p-2;
  //double input = 0x1.1p-1021;
  //double input = 0x0.0000000000001p-1022;
  //double input = 0x1.864080050c81p-1021;
  double input = 0x1.c50620078a0c4p-1020;
  //double input = 0x0.1p-1022;

  //hipLaunchKernelGGL(__dsqrt_rd,
  //                   dim3(1),
  //                   dim3(1),
  //                   0, 0,
  //                   0 , input);
  //hipDeviceSynchronize();

  freopen("../random/float.random.txt", "r", stdin);
  for(int i = 1; i < 5000000; i++){
    scanf("%la", &input);
    //printf("%a", input);
    hipLaunchKernelGGL(__dsqrt_rd,
                       dim3(1),
                       dim3(1),
                       0, 0,
                       0 , input );
    hipDeviceSynchronize();
    }
}
