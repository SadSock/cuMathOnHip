#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <hip/hip_runtime.h>

namespace hip {

union m32 {
  uint32_t u32;
  int32_t s32;
  float f32;
};

union m64 {
  uint64_t u64;
  int64_t s64;
  double f64;
  struct {
    m32 lo;
    m32 hi;
  };
  void *ptr;
};

__device__ float tanhf(float x) {
  bool p[3];
  m32 f[25];
  m32 r[5];
  f[5].f32 = x;
  f[1].f32 = fabs(f[5].f32);
  if(isnan(f[1].f32)){
      m32 ret;
      ret.u32 = 0x7fffffff;
      return ret.f32;
  }
  if (f[1].f32 < 0x1.3333340000000p-1f){

      f[14].f32 = f[5].f32 * f[5].f32;
      f[15].f32 = -0x1.ac795c0000000p-5f;
      f[16].f32 = 0x1.01e1040000000p-6f;
      f[17].f32 = __builtin_fmaf(f[16].f32, f[14].f32, f[15].f32);
      f[18].f32 = 0x1.10b2820000000p-3f;
      f[19].f32 = __builtin_fmaf(f[17].f32, f[14].f32, f[18].f32);
      f[20].f32 = -0x1.5553da0000000p-2f;
      f[21].f32 = __builtin_fmaf(f[19].f32, f[14].f32, f[20].f32);
      f[22].f32 = 0x0.0p+0f;
      f[23].f32 = __builtin_fmaf(f[21].f32, f[14].f32, f[22].f32);
      f[24].f32 = __builtin_fmaf(f[23].f32, f[5].f32, f[5].f32);
  } else {

      f[6].f32 = f[1].f32 * 0x1.7154760000000p+1f;
      f[7].f32 = exp2f(f[6].f32);
      f[8].f32 = f[7].f32 + 0x1.0000000000000p+0f;
      f[9].f32 = 0x1.0000000000000p+0f;
      f[10].f32 = __builtin_amdgcn_rcpf(f[8].f32);
      f[11].f32 = -0x1.0000000000000p+1f;
      f[12].f32 = __builtin_fmaf(f[10].f32, f[11].f32, f[9].f32);
      f[13].f32 = (f[1].f32 >= 0x1.2059680000000p+3f) ? 0x1.0000000000000p+0f
                                                      : f[12].f32;
      r[1] = f[13];
      r[2] = f[5];
      r[3].u32 = r[2].u32 & -2147483648;
      r[4].u32 = r[3].u32 | r[1].u32;
      f[24] = r[4];
  }

  return f[24].f32;
}
} // namespace hip
