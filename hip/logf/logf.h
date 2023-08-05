
#include <math.h>
#include <stdint.h>
#include <hip/hip_runtime.h>

union m32 {
    uint32_t u32;
    int32_t  s32;
    float    f32;
};

union m64 {
    uint64_t   u64;
    int64_t    s64;
    double     f64;
    struct
    {
        m32 lo;
        m32 hi;
    };
    void* ptr;
};


__device__ float _ZN4maca4logfEf (float _ZN4maca4logfEf_param_0)
{
    bool p[4];
    m32 f[36];
    m32 r[5];
    f[5].f32 = _ZN4maca4logfEf_param_0;
    p[1] = f[5].f32 < 0x1.0000000000000p-126f && !isnan(f[5].f32) && !isnan(0x1.0000000000000p-126f);
    f[6].f32 = f[5].f32 * 0x1.0000000000000p+23f;
    f[1].f32 = p[1]? f[6].f32: f[5].f32;
    f[7].f32 = p[1]? -0x1.7000000000000p+4f: 0x0.0p+0f;
    r[1] = f[1];
    r[2].s32 = r[1].s32 + -1059760811;
    r[3].u32 = r[2].u32 & -8388608;
    r[4].s32 = r[1].s32 - r[3].s32;
    f[8] = r[4];
    asm volatile ("v_cvt_f32_i32 %0, %1;" : "=v"(f[9].f32) : "v"(r[3].s32));
    f[10].f32 = 0x1.0000000000000p-23f;               // 0x34000000 1.1920928955078125e-07
    f[11].f32 = __builtin_fmaf(f[9].f32, f[10].f32, f[7].f32);
    f[12].f32 = f[8].f32 + -0x1.0000000000000p+0f;    // 0xBF800000 -1.0
    f[13].f32 = 0x1.2073ec0000000p-3f;                // 0x3E1039F6 0.1408461034297943
    f[14].f32 = -0x1.0aa04e0000000p-3f;               // 0xBE055027 -0.13018856942653656
    f[15].f32 = __builtin_fmaf(f[14].f32, f[12].f32, f[13].f32);
    f[16].f32 = -0x1.f19b980000000p-4f;               // 0xBDF8CDCC -0.12148627638816833
    f[17].f32 = __builtin_fmaf(f[15].f32, f[12].f32, f[16].f32);
    f[18].f32 = 0x1.1e52aa0000000p-3f;                // 0x3E0F2955 0.1398061066865921
    f[19].f32 = __builtin_fmaf(f[17].f32, f[12].f32, f[18].f32);
    f[20].f32 = -0x1.55b1720000000p-3f;               // 0xBE2AD8B9 -0.16684235632419586
    f[21].f32 = __builtin_fmaf(f[19].f32, f[12].f32, f[20].f32);
    f[22].f32 = 0x1.99da160000000p-3f;                // 0x3E4CED0B 0.20012299716472626
    f[23].f32 = __builtin_fmaf(f[21].f32, f[12].f32, f[22].f32);
    f[24].f32 = -0x1.fffe440000000p-3f;               // 0xBE7FFF22 -0.24999669194221497
    f[25].f32 = __builtin_fmaf(f[23].f32, f[12].f32, f[24].f32);
    f[26].f32 = 0x1.5554f00000000p-2f;                // 0x3EAAAA78 0.333331823348999
    f[27].f32 = __builtin_fmaf(f[25].f32, f[12].f32, f[26].f32);
    f[28].f32 = -0x1.0000000000000p-1f;               // 0xBF000000 -0.5
    f[29].f32 = __builtin_fmaf(f[27].f32, f[12].f32, f[28].f32);
    f[30].f32 = f[12].f32 * f[29].f32;
    f[31].f32 = __builtin_fmaf(f[30].f32, f[12].f32, f[12].f32);
    f[32].f32 = 0x1.62e4300000000p-1f;                // 0x3F317218 0.6931471824645996
    f[35].f32 = __builtin_fmaf(f[11].f32, f[32].f32, f[31].f32);
    p[2] = r[1].u32 < 2139095040;
    if(p[2])
        goto $L__BB1_2;

    f[33].f32 = INFINITY;                             // 0x7F800000 inf
    f[35].f32 = __builtin_fmaf(f[1].f32, f[33].f32, f[33].f32);

$L__BB1_2:
    p[3] = f[1].f32 == 0x0.0p+0f && !isnan(f[1].f32) && !isnan(0x0.0p+0f);
    f[34].f32 = p[3]? -INFINITY: f[35].f32;
    return f[34].f32;
}
