
#include <math.h>
#include <stdint.h>
#include <stdio.h>
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
};

namespace maca{
__device__ double cyl_bessel_i1 (double in)
{
    bool p[5];
    m32 f[3];
    m32 r[23];
    m64 fd[134];
    m64 rd[3];
    fd[10].f64 = in;
    fd[1].f64 = fabs(fd[10].f64);
    {
        m32 temp;
        temp = fd[1].lo;
        r[4] = fd[1].hi;
    }
    r[5].s32 = r[4].s32 + -1076232192;
    p[1] = r[5].u32 < 127533056;
    if(p[1])
        goto $L__BB0_2;

#ifdef DEBUG
    printf("$L__BB0_1\n");
#endif
    goto $L__BB0_1;


$L__BB0_2:

#ifdef DEBUG
    printf("$L__BB0_2\n");
#endif
    fd[3].f64 = fd[1].f64 * 0x1.0000000000000p-1;
    fd[45].f64 = 0x1.8000000000000p+52;
    fd[46].f64 = 0x1.71547652b82fep+0;
    fd[47].f64 = __builtin_fma(fd[3].f64, fd[46].f64, fd[45].f64);
    {
        m32 temp;
        r[1] = fd[47].lo;
        temp = fd[47].hi;
    }
    fd[48].f64 = -0x1.8000000000000p+52;
    fd[49].f64 = fd[47].f64 + fd[48].f64;
    fd[50].f64 = -0x1.62e42fefa39efp-1;
    fd[51].f64 = __builtin_fma(fd[49].f64, fd[50].f64, fd[3].f64);
    fd[52].f64 = -0x1.abc9e3b39803fp-56;
    fd[53].f64 = __builtin_fma(fd[49].f64, fd[52].f64, fd[51].f64);
    fd[54].f64 = 0x1.28af3fca213eap-22;
    fd[55].f64 = 0x1.ade1569ce2bdfp-26;
    fd[56].f64 = __builtin_fma(fd[55].f64, fd[53].f64, fd[54].f64);
    fd[57].f64 = 0x1.71dee62401315p-19;
    fd[58].f64 = __builtin_fma(fd[56].f64, fd[53].f64, fd[57].f64);
    fd[59].f64 = 0x1.a01997c89eb71p-16;
    fd[60].f64 = __builtin_fma(fd[58].f64, fd[53].f64, fd[59].f64);
    fd[61].f64 = 0x1.a01a014761f65p-13;
    fd[62].f64 = __builtin_fma(fd[60].f64, fd[53].f64, fd[61].f64);
    fd[63].f64 = 0x1.6c16c1852b7afp-10;
    fd[64].f64 = __builtin_fma(fd[62].f64, fd[53].f64, fd[63].f64);
    fd[65].f64 = 0x1.1111111122322p-7;
    fd[66].f64 = __builtin_fma(fd[64].f64, fd[53].f64, fd[65].f64);
    fd[67].f64 = 0x1.55555555502a1p-5;
    fd[68].f64 = __builtin_fma(fd[66].f64, fd[53].f64, fd[67].f64);
    fd[69].f64 = 0x1.5555555555511p-3;
    fd[70].f64 = __builtin_fma(fd[68].f64, fd[53].f64, fd[69].f64);
    fd[71].f64 = 0x1.000000000000bp-1;
    fd[72].f64 = __builtin_fma(fd[70].f64, fd[53].f64, fd[71].f64);
    fd[73].f64 = 0x1.0000000000000p+0;
    fd[74].f64 = __builtin_fma(fd[72].f64, fd[53].f64, fd[73].f64);
    fd[75].f64 = __builtin_fma(fd[74].f64, fd[53].f64, fd[73].f64);


#ifdef DEBUG
    printf("lf fd[74] = %lf\n", fd[74].f64);
    printf("la fd[74] = %la\n", fd[74].f64);
    printf("lx fd[74] = %lx\n", fd[74].u64);
    printf("lf fd[75] = %lf\n", fd[75].f64);
    printf("la fd[75] = %la\n", fd[75].f64);
    printf("lx fd[75] = %lx\n", fd[75].u64);
#endif
    {
        m32 temp;
        r[2] = fd[75].lo;
        temp = fd[75].hi;
    }
#ifdef DEBUG
    printf("lf r[2] = %f\n", r[2].f32);
    printf("la r[2] = %a\n", r[2].f32);
    printf("lx r[2] = %x\n", r[2].u32);
#endif
    {
        m32 temp;
        temp = fd[75].lo;
        r[3] = fd[75].hi;
    }
#ifdef DEBUG
    printf("lf r[3] = %f\n", r[3].f32);
    printf("la r[3] = %a\n", r[3].f32);
    printf("lx r[3] = %x\n", r[3].u32);
#endif
    r[6].u32 = r[1].u32 << 20;
    r[7].s32 = r[3].s32 + r[6].s32;
    fd[132].lo = r[2];
    fd[132].hi = r[7];
#ifdef DEBUG
    printf("lf fd[132] = %lf\n", fd[132].f64);
    printf("la fd[132] = %la\n", fd[132].f64);
    printf("lx fd[132] = %lx\n", fd[132].u64);
#endif
    {
        m32 temp;
        temp = fd[3].lo;
        r[8] = fd[3].hi;
    }
    f[2] = r[8];
    f[1].f32 = fabs(f[2].f32);
    p[2] = f[1].f32 < 0x1.0c46560000000p+2 && !isnan(f[1].f32) && !isnan(0x1.0c46560000000p+2);
    if(p[2])
        goto $L__BB0_5;

#ifdef DEBUG
    printf("115\n");
    printf("115\n");
#endif
    p[3] = fd[3].f64 < 0x0.0p+0 && !isnan(fd[3].f64) && !isnan(0x0.0p+0);
    fd[76].f64 = fd[3].f64 + INFINITY;
    fd[132].f64 = p[3]? 0x0.0p+0: fd[76].f64;
    p[4] = f[1].f32 >= 0x1.0e90000000000p+2 || isnan(f[1].f32) || isnan(0x1.0e90000000000p+2);
    if(p[4])
        goto $L__BB0_5;

    r[9].u32 = r[1].u32 >> 31;
    r[10].s32 = r[1].s32 + r[9].s32;
    r[11].s32 = r[10].s32 >> 1;
    r[12].u32 = r[11].u32 << 20;
    r[13].s32 = r[3].s32 + r[12].s32;
    fd[77].lo = r[2];
    fd[77].hi = r[13];
    r[14].s32 = r[1].s32 - r[11].s32;
    r[15].u32 = r[14].u32 << 20;
    r[16].s32 = r[15].s32 + 1072693248;
    r[17].u32 = 0;
    fd[78].lo = r[17];
    fd[78].hi = r[16];
    fd[132].f64 = fd[77].f64 * fd[78].f64;

$L__BB0_5:
#ifdef DEBUG
    printf("$L__BB0_5\n");
#endif
    fd[79].f64 = __builtin_amdgcn_rcp(fd[1].f64);
    printf("lf r[79] = %lf\n", fd[79].f64);
    printf("la r[79] = %la\n", fd[79].f64);
    printf("lx r[79] = %lx\n", fd[79].u64);
    fd[80].f64 = -fd[1].f64;
    fd[82].f64 = __builtin_fma(fd[80].f64, fd[79].f64, fd[73].f64);
    fd[83].f64 = __builtin_fma(fd[82].f64, fd[82].f64, fd[82].f64);
    fd[84].f64 = __builtin_fma(fd[83].f64, fd[79].f64, fd[79].f64);
    fd[85].f64 = __builtin_amdgcn_rsq(fd[1].f64);
    fd[86].f64 = fd[85].f64 * fd[85].f64;
    fd[87].f64 = -fd[86].f64;
    fd[88].f64 = __builtin_fma(fd[1].f64, fd[87].f64, fd[73].f64);
    fd[89].f64 = fd[88].f64 * fd[85].f64;
    fd[90].f64 = 0x1.0000000000000p-1;
    fd[91].f64 = 0x1.8000000000000p-2;
    fd[92].f64 = __builtin_fma(fd[91].f64, fd[88].f64, fd[90].f64);
    fd[93].f64 = __builtin_fma(fd[92].f64, fd[89].f64, fd[85].f64);
    fd[94].f64 = -0x1.a9923a6810426p+33;
    fd[95].f64 = 0x1.8729da7e5a092p+30;
    fd[96].f64 = __builtin_fma(fd[95].f64, fd[84].f64, fd[94].f64);
    fd[97].f64 = 0x1.15d3db3c5ffe0p+33;
    fd[98].f64 = __builtin_fma(fd[96].f64, fd[84].f64, fd[97].f64);
    fd[99].f64 = -0x1.4d2d89a3913c1p+31;
    fd[100].f64 = __builtin_fma(fd[98].f64, fd[84].f64, fd[99].f64);
    fd[101].f64 = 0x1.dcdff9b080398p+28;
    fd[102].f64 = __builtin_fma(fd[100].f64, fd[84].f64, fd[101].f64);
    fd[103].f64 = -0x1.c5f2e01fb2ff9p+25;
    fd[104].f64 = __builtin_fma(fd[102].f64, fd[84].f64, fd[103].f64);
    fd[105].f64 = 0x1.2fcfb5fd54150p+22;
    fd[106].f64 = __builtin_fma(fd[104].f64, fd[84].f64, fd[105].f64);
    fd[107].f64 = -0x1.26d4cd831fc06p+18;
    fd[108].f64 = __builtin_fma(fd[106].f64, fd[84].f64, fd[107].f64);
    fd[109].f64 = 0x1.a49abc2cad407p+13;
    fd[110].f64 = __builtin_fma(fd[108].f64, fd[84].f64, fd[109].f64);
    fd[111].f64 = -0x1.bf09a8d0b4bcfp+8;
    fd[112].f64 = __builtin_fma(fd[110].f64, fd[84].f64, fd[111].f64);
    fd[113].f64 = 0x1.3f8f8f6f26890p+3;
    fd[114].f64 = __builtin_fma(fd[112].f64, fd[84].f64, fd[113].f64);
    fd[115].f64 = -0x1.d6e31961ece73p-2;
    fd[116].f64 = __builtin_fma(fd[114].f64, fd[84].f64, fd[115].f64);
    fd[117].f64 = -0x1.bbdc121c5123bp-4;
    fd[118].f64 = __builtin_fma(fd[116].f64, fd[84].f64, fd[117].f64);
    fd[119].f64 = -0x1.d76aacf55fc53p-5;
    fd[120].f64 = __builtin_fma(fd[118].f64, fd[84].f64, fd[119].f64);
    fd[121].f64 = -0x1.4f1c4ff86494bp-5;
    fd[122].f64 = __builtin_fma(fd[120].f64, fd[84].f64, fd[121].f64);
    fd[123].f64 = -0x1.7efc0e3c7167ep-5;
    fd[124].f64 = __builtin_fma(fd[122].f64, fd[84].f64, fd[123].f64);
    fd[125].f64 = -0x1.32633e6decf48p-3;
    fd[126].f64 = __builtin_fma(fd[124].f64, fd[84].f64, fd[125].f64);
    fd[127].f64 = 0x1.9884533d43649p-2;
    fd[128].f64 = __builtin_fma(fd[126].f64, fd[84].f64, fd[127].f64);
    fd[129].f64 = fd[128].f64 * fd[93].f64;
    fd[130].f64 = fd[129].f64 * fd[132].f64;
    fd[131].f64 = fd[130].f64 * fd[132].f64;
    {
        m32 temp;
        r[18] = fd[131].lo;
        temp = fd[131].hi;
    }
    {
        m32 temp;
        temp = fd[131].lo;
        r[19] = fd[131].hi;
    }
    {
        m32 temp;
        temp = fd[10].lo;
        r[20] = fd[10].hi;
    }
    r[21].u32 = r[20].u32 & -2147483648;
    r[22].u32 = r[19].u32 | r[21].u32;
    fd[133].lo = r[18];
    fd[133].hi = r[22];
    goto $L__BB0_6;


$L__BB0_1:
    fd[11].f64 = fd[10].f64 * fd[10].f64;
    fd[12].f64 = 0x1.76b71c28918b0p-117;
    fd[13].f64 = 0x1.68d52e367973fp-125;
    fd[14].f64 = __builtin_fma(fd[13].f64, fd[11].f64, fd[12].f64);
    fd[15].f64 = 0x1.8082fe6606acbp-106;
    fd[16].f64 = __builtin_fma(fd[14].f64, fd[11].f64, fd[15].f64);
    fd[17].f64 = 0x1.0ec04908e2753p-96;
    fd[18].f64 = __builtin_fma(fd[16].f64, fd[11].f64, fd[17].f64);
    fd[19].f64 = 0x1.8d983808a730dp-87;
    fd[20].f64 = __builtin_fma(fd[18].f64, fd[11].f64, fd[19].f64);
    fd[21].f64 = 0x1.e21624af0555ap-78;
    fd[22].f64 = __builtin_fma(fd[20].f64, fd[11].f64, fd[21].f64);
    fd[23].f64 = 0x1.f18024073231ep-69;
    fd[24].f64 = __builtin_fma(fd[22].f64, fd[11].f64, fd[23].f64);
    fd[25].f64 = 0x1.ab810d07c53a4p-60;
    fd[26].f64 = __builtin_fma(fd[24].f64, fd[11].f64, fd[25].f64);
    fd[27].f64 = 0x1.2c97677fab629p-51;
    fd[28].f64 = __builtin_fma(fd[26].f64, fd[11].f64, fd[27].f64);
    fd[29].f64 = 0x1.522a42918d8a1p-43;
    fd[30].f64 = __builtin_fma(fd[28].f64, fd[11].f64, fd[29].f64);
    fd[31].f64 = 0x1.27e4fb8f617fcp-35;
    fd[32].f64 = __builtin_fma(fd[30].f64, fd[11].f64, fd[31].f64);
    fd[33].f64 = 0x1.845c8a0abd799p-28;
    fd[34].f64 = __builtin_fma(fd[32].f64, fd[11].f64, fd[33].f64);
    fd[35].f64 = 0x1.6c16c16c369a2p-21;
    fd[36].f64 = __builtin_fma(fd[34].f64, fd[11].f64, fd[35].f64);
    fd[37].f64 = 0x1.c71c71c71a4b2p-15;
    fd[38].f64 = __builtin_fma(fd[36].f64, fd[11].f64, fd[37].f64);
    fd[39].f64 = 0x1.5555555555681p-9;
    fd[40].f64 = __builtin_fma(fd[38].f64, fd[11].f64, fd[39].f64);
    fd[41].f64 = 0x1.ffffffffffff1p-5;
    fd[42].f64 = __builtin_fma(fd[40].f64, fd[11].f64, fd[41].f64);
    fd[43].f64 = fd[42].f64 * fd[11].f64;
    fd[44].f64 = fd[10].f64 * 0x1.0000000000000p-1;
    fd[133].f64 = __builtin_fma(fd[10].f64, fd[43].f64, fd[44].f64);

$L__BB0_6:
    return fd[133].f64;
}
}
