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

__device__ float expf (float _ZN4maca4expfEf_param_0)
{
    m32 f[18];
    m32 r[3];
    f[1].f32 = _ZN4maca4expfEf_param_0;
    f[2].f32 = 0x1.0000000000000p-1f;                 // 0x3F000000 0.5
    f[3].f32 = 0x1.77313a0000000p-8f;                 // 0x3BBB989D 0.005724980030208826
    f[4].f32 = __builtin_fmaf(f[1].f32, f[3].f32, f[2].f32);
    
    
    f[5].f32 = 0x1.7154760000000p+0f;                 // 0x3FB8AA3B 1.4426950216293335
    f[6].f32 = 0x1.f800000000000p+7f;                 // 0x437C0000 252.0
    asm volatile ("v_add_f32_e64 %0, %1, 0.0 clamp;" : "=v"(f[7].f32) : "v"(f[4].f32));
    f[8].f32 = 0x1.8000020000000p+23f;                // 0x4B400001 12582913.0
    
    
    // printf("%f %x\n", f[4].f32, f[4].u32);
    
    asm volatile("s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 2\n\t"
                 "v_fma_f32 %0, %1, %2, %3\n\t"
                 "s_setreg_imm32_b32 hwreg(HW_REG_MODE, 0, 2), 0\n\t"
                 : "=v"(f[9].f32)
                 : "v"(f[7].f32), "v"(f[6].f32), "v"(f[8].f32));
    
    
    printf("f[9] = %f %x\n", f[9].f32, f[9].u32);
    
    
    f[10].f32 = f[9].f32 + -0x1.8000fe0000000p+23f;   // 0xCB40007F -12583039.0
    
    // return f[10].f32;
    // printf("f[10] = %f %x\n", f[10].f32, f[10].u32);
    
    f[11].f32 = -f[10].f32;
    f[12].f32 = __builtin_fmaf(f[1].f32, f[5].f32, f[11].f32);
    f[13].f32 = 0x1.4ae0c00000000p-26f;               // 0x32A57060 1.925963033500011e-08
    f[14].f32 = __builtin_fmaf(f[1].f32, f[13].f32, f[12].f32);
    r[1] = f[9];
    r[2].u32 = r[1].u32 << 23;
    f[15] = r[2];
    asm volatile ("v_exp_f32_e32 %0, %1;" : "=v"(f[16].f32) : "v"(f[14].f32));
    // printf("m = %f %x\n", f[14].f32, f[14].u32);
    f[17].f32 = f[16].f32 * f[15].f32;
    return f[17].f32;
};


} // namespace hip
