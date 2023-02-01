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

__device__ float __frcp_rn(float _x) {

  m32 x0;
  m32 x1;
  m32 q, q1,q2,q3_rd,q3_ru,q3_rz,q4;
  m32 d1,d2;
  m32 x_rcp;
  uint32_t exp_fixup     = 0;
  uint32_t x0_biased_exp = 0;

  x0.f32        = _x;
  x0_biased_exp = x0.u32 << 1 >> 24;

#ifdef DEBUG
  printf("x0 = %x\n", x0.u32);
  printf("x0_biased_exp = %x\n", x0_biased_exp);
#endif

  if (x0_biased_exp + 0x11 > 0x11) {
      // x0 is normal number
      // x0_biased_exp is [0x01 ,0xee]
      /*0090 -> 00f0*/
#ifdef DEBUG
      printf("x0 is normal number\n");
#endif
  }else{
#ifdef DEBUG
      printf("x0 is denormal or close to +/-inf\n");
#endif
      // x0 is denormal or close to +/-inf
      // x0_biased_exp is 0x00 or (0xee ,0xff]
  }
}
