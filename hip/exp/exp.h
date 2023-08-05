
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


__device__ double _ZN4maca3expEd (double _ZN4maca3expEd_param_0)
{
    bool p[4];
    m32 f[3];
    m32 r[16];
    m64 fd[41];
    fd[5].f64 = _ZN4maca3expEd_param_0;
    fd[6].f64 = 0x1.8000000000000p+52;                // 0x4338000000000000 6755399441055744.0
    fd[7].f64 = 0x1.71547652b82fep+0;                 // 0x3FF71547652B82FE 1.4426950408889634
    fd[8].f64 = __builtin_fma(fd[5].f64, fd[7].f64, fd[6].f64);
    {
        m32 temp;
        r[1] = fd[8].lo;
        temp = fd[8].hi;
    }
    fd[9].f64 = -0x1.8000000000000p+52;               // 0xC338000000000000 -6755399441055744.0
    fd[10].f64 = fd[8].f64 + fd[9].f64;
    fd[11].f64 = -0x1.62e42fefa39efp-1;               // 0xBFE62E42FEFA39EF -0.6931471805599453
    fd[12].f64 = __builtin_fma(fd[10].f64, fd[11].f64, fd[5].f64);
    fd[13].f64 = -0x1.abc9e3b39803fp-56;              // 0xBC7ABC9E3B39803F -2.3190468138462996e-17
    fd[14].f64 = __builtin_fma(fd[10].f64, fd[13].f64, fd[12].f64);
    fd[15].f64 = 0x1.28af3fca213eap-22;               // 0x3E928AF3FCA213EA 2.763090348817311e-07
    fd[16].f64 = 0x1.ade1569ce2bdfp-26;               // 0x3E5ADE1569CE2BDF 2.502232253650299e-08
    fd[17].f64 = __builtin_fma(fd[16].f64, fd[14].f64, fd[15].f64);
    fd[18].f64 = 0x1.71dee62401315p-19;               // 0x3EC71DEE62401315 2.755751454588244e-06
    fd[19].f64 = __builtin_fma(fd[17].f64, fd[14].f64, fd[18].f64);
    fd[20].f64 = 0x1.a01997c89eb71p-16;               // 0x3EFA01997C89EB71 2.4801491039099165e-05
    fd[21].f64 = __builtin_fma(fd[19].f64, fd[14].f64, fd[20].f64);
    fd[22].f64 = 0x1.a01a014761f65p-13;               // 0x3F2A01A014761F65 0.00019841269589115497
    fd[23].f64 = __builtin_fma(fd[21].f64, fd[14].f64, fd[22].f64);
    fd[24].f64 = 0x1.6c16c1852b7afp-10;               // 0x3F56C16C1852B7AF 0.001388888894591638
    fd[25].f64 = __builtin_fma(fd[23].f64, fd[14].f64, fd[24].f64);
    fd[26].f64 = 0x1.1111111122322p-7;                // 0x3F81111111122322 0.008333333333455043
    fd[27].f64 = __builtin_fma(fd[25].f64, fd[14].f64, fd[26].f64);
    fd[28].f64 = 0x1.55555555502a1p-5;                // 0x3FA55555555502A1 0.041666666666519754
    fd[29].f64 = __builtin_fma(fd[27].f64, fd[14].f64, fd[28].f64);
    fd[30].f64 = 0x1.5555555555511p-3;                // 0x3FC5555555555511 0.16666666666666477
    fd[31].f64 = __builtin_fma(fd[29].f64, fd[14].f64, fd[30].f64);
    fd[32].f64 = 0x1.000000000000bp-1;                // 0x3FE000000000000B 0.5000000000000012
    fd[33].f64 = __builtin_fma(fd[31].f64, fd[14].f64, fd[32].f64);
    fd[34].f64 = 0x1.0000000000000p+0;                // 0x3FF0000000000000 1.0
    fd[35].f64 = __builtin_fma(fd[33].f64, fd[14].f64, fd[34].f64);
    fd[36].f64 = __builtin_fma(fd[35].f64, fd[14].f64, fd[34].f64);
    {
        m32 temp;
        r[2] = fd[36].lo;
        temp = fd[36].hi;
    }
    {
        m32 temp;
        temp = fd[36].lo;
        r[3] = fd[36].hi;
    }
    r[4].u32 = r[1].u32 << 20;
    r[5].s32 = r[3].s32 + r[4].s32;
    fd[40].lo = r[2];
    fd[40].hi = r[5];
    {
        m32 temp;
        temp = fd[5].lo;
        r[6] = fd[5].hi;
    }
    f[2] = r[6];
    f[1].f32 = fabs(f[2].f32);
    p[1] = f[1].f32 < 0x1.0c46560000000p+2f && !isnan(f[1].f32) && !isnan(0x1.0c46560000000p+2f);
    if(p[1])
        goto $L__BB1_3;

    p[2] = fd[5].f64 < 0x0.0p+0 && !isnan(fd[5].f64) && !isnan(0x0.0p+0);
    fd[37].f64 = fd[5].f64 + INFINITY;                // 0x7FF0000000000000 inf
    fd[40].f64 = p[2]? 0x0.0p+0: fd[37].f64;
    p[3] = f[1].f32 >= 0x1.0e90000000000p+2f || isnan(f[1].f32) || isnan(0x1.0e90000000000p+2f);
    if(p[3])
        goto $L__BB1_3;

    r[7].u32 = r[1].u32 >> 31;
    r[8].s32 = r[1].s32 + r[7].s32;
    r[9].s32 = r[8].s32 >> 1;
    r[10].u32 = r[9].u32 << 20;
    r[11].s32 = r[3].s32 + r[10].s32;
    fd[38].lo = r[2];
    fd[38].hi = r[11];
    r[12].s32 = r[1].s32 - r[9].s32;
    r[13].u32 = r[12].u32 << 20;
    r[14].s32 = r[13].s32 + 1072693248;
    r[15].u32 = 0;
    fd[39].lo = r[15];
    fd[39].hi = r[14];
    fd[40].f64 = fd[38].f64 * fd[39].f64;

$L__BB1_3:
    return fd[40].f64;
}
