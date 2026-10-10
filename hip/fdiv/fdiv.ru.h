#include <cmath>
#include <cstdint>
#include <hip/hip_runtime.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
using namespace std;


union m32{
    uint32_t u32;
    int32_t  s32;
    float    f32;
};

__device__ float __fdiv_ru(float _y, float _x) {

  m32 x0;
  m32 y0;
  m32 x1;
  m32 y1;
  m32 q, q1,q2,q3_rd,q3_ru,q3_rz,q4;
  m32 d1,d2;
  m32 x_rcp;
  uint32_t exp_fixup     = 0;
  uint32_t x0_biased_exp = 0;
  uint32_t y0_biased_exp = 0;

  x0.f32        = _x;
  y0.f32        = _y;
  x1.f32        = _x;
  y1.f32        = _y;
  x0_biased_exp = x0.u32 << 1 >> 24;
  y0_biased_exp = y0.u32 << 1 >> 24;

#ifdef DEBUG
  printf("y0 = %x\n", y0.u32);
  printf("x0 = %x\n", x0.u32);
#endif

  /*00e0*/
  if (x0_biased_exp - 1 > 0xfd || y0_biased_exp - 1 > 0xfd) {
    // x0 is nan or inf (biased_exp = 0xff)
    // x0 is 0 or denormal (biased_exp = 0x0)
    // y0 is nan or inf (biased_exp = 0xff)
    // y0 is 0 or denormal (biased_exp = 0x0)

    /*0110*  ->   *0150*/
    if (isnan(x0.f32) || isnan(y0.f32)) {
      q.u32 = 0x7fffffff;
      return q.f32; // return qnan
    }
    /*0160*  ->   *01a0*/
    if (x0.f32 == 0.0 && y0.f32 == 0.0) { // 0.0 / 0.0
      q.u32 = 0x7fffffff;
      return q.f32; // return qnan
    } else {
      /*01c0*  ->   *01e0*/
      if (isinf(x0.f32) && isinf(y0.f32)) { // inf / inf
        q.u32 = 0x7fffffff;
        return q.f32; // return qnan
      } else {

        /*0220*  ->   *0260*/
        if (isinf(x0.f32) || y0.f32 == 0.0) { // 0 / inf
          q.u32 = (x0.u32 ^ y0.u32) & 0x80000000;
          return q.f32; // return 0
        }

        /*0270*  ->   *02c0*/
        if (isinf(y0.f32) || x0.f32 == 0.0) { // inf / 0
          q.u32 = ((x0.u32 ^ y0.u32) & 0x80000000) | 0x7f800000;
          return q.f32; // return inf
        }
      }
    }

#ifdef DEBUG
    printf("/*02d0*  ->   *0320*/\n");
    printf("y0_biased_exp = %d\n",y0_biased_exp - 1);
#endif

    /*02d0*  ->   *0320*/
    if ((int32_t)y0_biased_exp - 1 >= 0) {
      y1.f32 = y0.f32;
    } else { // y0 is denormal
#ifdef DEBUG
      printf("y0 is denormal\n");
#endif
      m32 denormal_fixup;
      denormal_fixup.u32 = 0x5f800000; // 2^64
      exp_fixup = -0x40;               // -64
      y1.f32 = y0.f32 * denormal_fixup.f32;
    }

    /*0320*  ->   *0360*/
    if ((int32_t)x0_biased_exp - 1 >= 0) {
      x1.f32 = x0.f32;
    } else { // x0 is denormal
#ifdef DEBUG
      printf("x0 is denormal\n");
#endif
      m32 denormal_fixup;
      denormal_fixup.u32 = 0x5f800000; // 2^64
      exp_fixup          = exp_fixup + 0x40; // 64
      x1.f32             = x0.f32 * denormal_fixup.f32;
    }
  }

#ifdef DEBUG
  printf("x1 = %x\n", x1.u32);
  printf("y1 = %x\n", y1.u32);
#endif

  /*0380*/
  // set the true exp of x1.f32 to 0
  // in other words, set the biased exp of x1.f32 to 0x7f
  x1.u32 = x1.u32 - ((x0_biased_exp - 0x7f) * 0x800000);

  /*03b0*/
  // set the true exp of y1.f32 to 0
  // in other words, set the biased exp of y1.f32 to 0x7f
  y1.u32 = y1.u32 - ((y0_biased_exp - 0x7f) * 0x800000);

  /*03a0*/
  x_rcp.f32 = __builtin_amdgcn_rcpf(x1.f32);

#ifdef DEBUG
  printf("x1 = %x\n", x1.u32);
  printf("y1 = %x\n", y1.u32);
#endif

  /*03a0   -> 0410*/
  q1.f32       = __builtin_fma(y1.f32, x_rcp.f32, 0.0);
  d1.f32       = __builtin_fma(-x1.f32, q1.f32, y1.f32);
  q2.f32       = __builtin_fma(x_rcp.f32, d1.f32, q1.f32);
  d2.f32       = __builtin_fma(-x1.f32, q2.f32, y1.f32);

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 3\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q3_rz.f32)
               : "v"(x_rcp), "v"(d2.f32), "v"(q2.f32));

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 2\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q3_rd.f32)
               : "v"(x_rcp), "v"(d2.f32), "v"(q2.f32));

  asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 1\n\t"
               "v_fma_f32 %0, %1, %2, %3"
               : "=v"(q3_ru.f32)
               : "v"(x_rcp), "v"(d2.f32), "v"(q2.f32));
#ifdef DEBUG
  printf("q3_rd = %x\n", q3_rd.u32);
  printf("q3_ru = %x\n", q3_ru.u32);
  printf("q3_rz = %x\n", q3_rz.u32);
#endif

  uint32_t q3_ru_biased_exp = q3_ru.u32 << 1 >> 0x18;
  uint32_t q4_ru_biased_exp = q3_ru_biased_exp + y0_biased_exp - x0_biased_exp + exp_fixup;

#ifdef DEBUG
  printf("q3_ru_exp = %d\n", q3_ru_exp);
  printf("exp_fixup = %d\n", exp_fixup);
  printf("y0_biased_exp = %d\n", y0_biased_exp);
  printf("x0_biased_exp = %d\n", x0_biased_exp);
  printf("q5_rd_exp = %d\n", q5_rd_exp);
#endif

  if (!(q4_ru_biased_exp - 0x1 > 0xfd)) { // q is normal float number
#ifdef DEBUG
    printf("q is normal float number\n");
#endif
    q.u32 = q3_ru.u32 + ((y0_biased_exp - x0_biased_exp + exp_fixup) << 23);
    return q.f32;
  }

  uint32_t q_sign = q3_rd.u32 & 0x80000000;

#ifdef DEBUG
  printf("q_sign = %d\n", q_sign);
#endif

  if ((int32_t)q4_ru_biased_exp > 0xfe) {                // q is inf
    // round up
#ifdef DEBUG
    printf("q is inf\n");
#endif
    if ((q3_rd.u32 & 0x80000000) != 0x0) // q is negative ?
      q.u32 = 0x7f7fffff; // the float with the largest absolute value
    else
      q.u32 = 0x7f800000; // inf
    q.u32 = q.u32 | q_sign;
    return q.f32;
  }

  if((int32_t)q4_ru_biased_exp > 0x0){  // q is normal
      q.u32 = q3_ru.u32;
      return q.f32;
  }

  if ((int32_t)q4_ru_biased_exp < -0x18) { // q is infinitesimals
    // round up
    if ((q3_ru.u32 & 0x80000000) == 0x0) // q is positive
      q.u32 = 0x1; // the float with the lowest absolute value
    else
      q.u32 = 0x0; // 0
    q.u32 = q.u32 | q_sign;
    return q.f32;
  }

  uint32_t q3_rz_mantissa = q3_rz.u32 & 0x7fffff;

  bool     hardware_rounding;
  bool     software_rounding;
  uint32_t rounding_fixup;

  //is mantissa drkopped by hardware
  if (q3_rd.u32 != q3_ru.u32) {
    hardware_rounding = true;
  } else {
    hardware_rounding = false;
  }

  q4.u32 = q3_rz_mantissa | 0x800000;

  uint32_t mantissa_dropped_software = q4.u32 << (q4_ru_biased_exp + 0x1f);

  if (mantissa_dropped_software == 0){
    software_rounding = false;
  }else{
    software_rounding = true;
  }

  /*0680*  -> *06f0*/
  if ((software_rounding|hardware_rounding) && q_sign == 0){
    rounding_fixup = 0x1;
  }else{
    rounding_fixup = 0x0;
  }

  q.u32 = q4.u32 >> (0x1 - q4_ru_biased_exp);
  q.u32 = q.u32 + rounding_fixup;
  q.u32 = q.u32 | q_sign;

  return q.f32;
}
