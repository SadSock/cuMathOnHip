
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


__device__ double _ZN4maca3logEd (double _ZN4maca3logEd_param_0)
{
    bool p[5];
    m32 f[2];
    m32 r[28];
    m64 fd[59];
    fd[56].f64 = _ZN4maca3logEd_param_0;
    {
        m32 temp;
        temp = fd[56].lo;
        r[24] = fd[56].hi;
    }
    {
        m32 temp;
        r[25] = fd[56].lo;
        temp = fd[56].hi;
    }
    p[1] = r[24].s32 > 1048575;
    r[26].u32 = -1023;
    if(p[1])
        goto $L__BB1_2;

    fd[56].f64 = fd[56].f64 * 0x1.0000000000000p+54;
    {
        m32 temp;
        temp = fd[56].lo;
        r[24] = fd[56].hi;
    }
    {
        m32 temp;
        r[25] = fd[56].lo;
        temp = fd[56].hi;
    }
    r[26].u32 = -1077;

$L__BB1_2:
    r[13].s32 = r[24].s32 + -1;
    p[2] = r[13].u32 < 2146435071;
    if(p[2])
        goto $L__BB1_4;

    goto $L__BB1_3;


$L__BB1_4:
    r[15].u32 = r[24].u32 >> 20;
    r[27].s32 = r[26].s32 + r[15].s32;
    r[16].u32 = r[24].u32 & -2146435073;
    r[17].u32 = r[16].u32 | 1072693248;
    fd[57].lo = r[25];
    fd[57].hi = r[17];
    p[4] = r[17].s32 < 1073127583;
    if(p[4])
        goto $L__BB1_6;

    {
        m32 temp;
        r[18] = fd[57].lo;
        temp = fd[57].hi;
    }
    {
        m32 temp;
        temp = fd[57].lo;
        r[19] = fd[57].hi;
    }
    r[20].s32 = r[19].s32 + -1048576;
    fd[57].lo = r[18];
    fd[57].hi = r[20];
    r[27].s32 = r[27].s32 + 1;

$L__BB1_6:
    fd[12].f64 = fd[57].f64 + 0x1.0000000000000p+0;   // 0x3FF0000000000000 1.0
    fd[13].f64 = 0x1.0000000000000p+0;                // 0x3FF0000000000000 1.0
    fd[14].f64 = __builtin_amdgcn_rcp(fd[12].f64);
    fd[15].f64 = -fd[12].f64;
    fd[16].f64 = __builtin_fma(fd[15].f64, fd[14].f64, fd[13].f64);
    fd[17].f64 = __builtin_fma(fd[16].f64, fd[16].f64, fd[16].f64);
    fd[18].f64 = __builtin_fma(fd[17].f64, fd[14].f64, fd[14].f64);
    fd[19].f64 = fd[57].f64 + -0x1.0000000000000p+0;  // 0xBFF0000000000000 -1.0
    fd[20].f64 = fd[19].f64 * fd[18].f64;
    fd[21].f64 = __builtin_fma(fd[19].f64, fd[18].f64, fd[20].f64);
    fd[22].f64 = fd[21].f64 * fd[21].f64;
    fd[23].f64 = 0x1.0ee258b7a8b04p-18;               // 0x3ED0EE258B7A8B04 4.036488625710656e-06
    fd[24].f64 = 0x1.1380b3ae80f1ep-20;               // 0x3EB1380B3AE80F1E 1.0263276909458365e-06
    fd[25].f64 = __builtin_fma(fd[24].f64, fd[22].f64, fd[23].f64);
    fd[26].f64 = 0x1.3b2669f02676fp-16;               // 0x3EF3B2669F02676F 1.8784407018835667e-05
    fd[27].f64 = __builtin_fma(fd[25].f64, fd[22].f64, fd[26].f64);
    fd[28].f64 = 0x1.745cba9ab0956p-14;               // 0x3F1745CBA9AB0956 8.877807196497797e-05
    fd[29].f64 = __builtin_fma(fd[27].f64, fd[22].f64, fd[28].f64);
    fd[30].f64 = 0x1.c71c72d1b5154p-12;               // 0x3F3C71C72D1B5154 0.00043402779293201976
    fd[31].f64 = __builtin_fma(fd[29].f64, fd[22].f64, fd[30].f64);
    fd[32].f64 = 0x1.24924923be72dp-9;                // 0x3F624924923BE72D 0.0022321428567665586
    fd[33].f64 = __builtin_fma(fd[31].f64, fd[22].f64, fd[32].f64);
    fd[34].f64 = 0x1.999999999a3c4p-7;                // 0x3F8999999999A3C4 0.012500000000004514
    fd[35].f64 = __builtin_fma(fd[33].f64, fd[22].f64, fd[34].f64);
    fd[36].f64 = 0x1.5555555555554p-4;                // 0x3FB5555555555554 0.08333333333333331
    fd[37].f64 = __builtin_fma(fd[35].f64, fd[22].f64, fd[36].f64);
    fd[38].f64 = fd[19].f64 - fd[21].f64;
    fd[39].f64 = fd[38].f64 + fd[38].f64;
    fd[40].f64 = -fd[21].f64;
    fd[41].f64 = __builtin_fma(fd[40].f64, fd[19].f64, fd[39].f64);
    fd[42].f64 = fd[18].f64 * fd[41].f64;
    fd[43].f64 = fd[22].f64 * fd[37].f64;
    fd[44].f64 = __builtin_fma(fd[43].f64, fd[21].f64, fd[42].f64);
    r[21].u32 = r[27].u32 ^ -2147483648;
    r[22].u32 = -2147483648;
    r[23].u32 = 1127219200;
    fd[45].lo = r[21];
    fd[45].hi = r[23];
    fd[46].lo = r[22];
    fd[46].hi = r[23];
    fd[47].f64 = fd[45].f64 - fd[46].f64;
    fd[48].f64 = 0x1.62e42fefa39efp-1;                // 0x3FE62E42FEFA39EF 0.6931471805599453
    fd[49].f64 = __builtin_fma(fd[47].f64, fd[48].f64, fd[21].f64);
    fd[50].f64 = -fd[47].f64;
    fd[51].f64 = __builtin_fma(fd[50].f64, fd[48].f64, fd[49].f64);
    fd[52].f64 = fd[51].f64 - fd[21].f64;
    fd[53].f64 = fd[44].f64 - fd[52].f64;
    fd[54].f64 = 0x1.abc9e3b39803fp-56;               // 0x3C7ABC9E3B39803F 2.3190468138462996e-17
    fd[55].f64 = __builtin_fma(fd[47].f64, fd[54].f64, fd[53].f64);
    fd[58].f64 = fd[49].f64 + fd[55].f64;
    goto $L__BB1_7;


$L__BB1_3:
    fd[10].f64 = INFINITY;                            // 0x7FF0000000000000 inf
    fd[11].f64 = __builtin_fma(fd[56].f64, fd[10].f64, fd[10].f64);
    {
        m32 temp;
        temp = fd[56].lo;
        r[14] = fd[56].hi;
    }
    f[1] = r[14];
    p[3] = f[1].f32 == 0x0.0p+0f && !isnan(f[1].f32) && !isnan(0x0.0p+0f);
    fd[58].f64 = p[3]? -INFINITY: fd[11].f64;

$L__BB1_7:
    return fd[58].f64;
}
