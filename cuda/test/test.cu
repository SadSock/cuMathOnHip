#include <stdio.h>
#include <cstdint>
#include <cmath>
#include <vector>
#include <random>
#include "cuda_runtime.h"

using namespace std;

// #define RUN_IN_AMD

enum RoundMode {
    MODE_RU,
    MODE_RZ,
    MODE_RD,
    MODE_RN
};

static constexpr uint64_t neg_nan_hex = 0xfff8000000000000;
#define neg_nan (*((double*)(&neg_nan_hex)));

#ifdef RUN_IN_AMD
#define rounding_mode_ru (0x4)
#define rounding_mode_rz (0xc)
#define rounding_mode_rd (0x8)
#endif

// simulate as nvidia inst for fast calc rcp
double getRcpHUFU(double a)
{
    double b = 1.0 / a;
    uint32_t* lo = (uint32_t*)&b;
    *lo = 1;
    return b;
}

__global__ void fma_gpu_kernel(double* d, double a, double b, double c, RoundMode mode)
{
    if (mode == MODE_RU) {
        *d = __fma_ru(a, b, c);
    }
    else if (mode == MODE_RZ) {
        *d = __fma_rz(a, b, c);
    }
    else if (mode == MODE_RD) {
        *d = __fma_rd(a, b, c);
    }
    else if (mode == MODE_RN) {
        *d = __fma_rn(a, b, c);
    }
}

double fma_gpu(double a, double b, double c, RoundMode mode)
{
    double* dev_d = 0;
    size_t size = 1;
    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaError_t cudaStatus = cudaMalloc((void**)&dev_d, size * sizeof(double));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }
    fma_gpu_kernel << <1, 1 >> > (dev_d, a, b, c, mode);

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    double d = 0.0;
    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(&d, dev_d, size * sizeof(double), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_d);

    return d;
}

double __builtin_fma(double a, double b, double c)
{
    return fma_gpu(a, b, c, MODE_RN);
}

double fma_rz(double a, double b, double c)
{
    return fma_gpu(a, b, c, MODE_RZ);
}

double fma_rd(double a, double b, double c)
{
    return fma_gpu(a, b, c, MODE_RD);
}

double fma_rn(double a, double b, double c)
{
    return fma_gpu(a, b, c, MODE_RN);
}

double fma_ru(double a, double b, double c)
{
    return fma_gpu(a, b, c, MODE_RU);
}

#define iszero(a) (a == 0.0)

double ddiv_ru(double y, double x)
{
#ifdef RUN_IN_AMD
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;
    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );
#endif

    double x0 = x;
    double y0 = y;

    uint32_t* x0_lo = (uint32_t*)&x0 + 0;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;

    uint32_t* y0_lo = (uint32_t*)&y0 + 0;
    uint32_t* y0_hi = (uint32_t*)&y0 + 1;

    uint32_t x0_exp_bias = ((*x0_hi) << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;

    uint32_t y0_exp_bias = ((*y0_hi) << 1) >> 21;
    uint32_t y0_exp_true = y0_exp_bias - 0x3ff;
    int32_t y0_exp_scale = 0;

    int32_t exp_diff = y0_exp_bias - x0_exp_bias;

    // process abnormal
    bool x0_abnorm = (x0_exp_bias - 1) > 0x7fd;
    bool y0_abnorm = (y0_exp_bias - 1) > 0x7fd;
    if (x0_abnorm || y0_abnorm) {
        bool x_nan = isnan(x0);
        bool y_nan = isnan(y0);

        if (y_nan) {
            *y0_hi = *y0_hi | 0x80000;
            return y0;
        }
        if (x_nan) {
            *x0_hi = *x0_hi | 0x80000;
            return x0;
        }

        bool x_zero = iszero(x0);
        bool y_zero = iszero(y0);
        if (x_zero && y_zero) {
            return neg_nan;
        }

        bool x_inf = isinf(x0);
        bool y_inf = isinf(y0);
        if (x_inf && y_inf) {
            return neg_nan;
        }

        if (y_zero || x_inf) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_lo = 0;
            return x0; // return signed zero
        }
        if (y_inf || x_zero) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_hi = (*x0_hi) ^ 0x7ff00000; // get inf
            *x0_lo = 0;
            return x0; // return signed inf
        }

        if (y0_exp_bias == 0) // y denormal
        {
            y0 = y0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = -0x36;
        }
        if (x0_exp_bias == 0) // y denormal
        {
            x0 = x0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = y0_exp_scale + 0x36;
        }
    }

    // iter
    *x0_hi = *x0_hi - (x0_exp_true << 20);
    *y0_hi = *y0_hi - (y0_exp_true << 20);

#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;
#else
    double r0 = getRcpHUFU(x0);
#endif

    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;

    double r2 = __builtin_fma(r1, dd1, r1);
    double s1 = r0 * y0;
    double s2 = __builtin_fma(-x0, s1, y0);

    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, s2, s1);
    double d3 = __builtin_fma(-x0, r3, y0);

    double r5_ru = 0.0;
#if RUN_IN_AMD
    rounding_mode = rounding_mode_ru;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4 "
        : "=v"(r5_ru)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
    r5_ru = fma_ru(r4, d3, r3);
#endif

    uint64_t* r5_lh = (uint64_t*)&r5_ru;
    uint32_t* r5_lo = (uint32_t*)&r5_ru + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_ru + 1;
    uint32_t r5_exp_raw = (*r5_hi << 1) >> 21;
    uint32_t r5_exp_true = r5_exp_raw + exp_diff + y0_exp_scale;

    // r5_abnorm
    bool r5_abnorm = (r5_exp_true - 1) > 0x7fd;
    if (r5_abnorm) {
        uint32_t r5_sign = (*r5_hi) & 0x80000000;
        int32_t r5_exp_s = r5_exp_true - 0x3ff;
        double ret;
        if (r5_exp_s > 0x3ff) { // inf

            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0xffefffffffffffff;
            }
            else
            {
                *(uint64_t*)&ret = 0x7ff0000000000000;
            }
            return ret;
        }
        else if (r5_exp_s < -0x434) // -1076
        {
            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0x8000000000000000;
            }
            else
            {
                *(uint64_t*)&ret = 0x0000000000000001;
            }
            return ret;
        }

        double r5_rz = 0.0;
#if RUN_IN_AMD
        rounding_mode = rounding_mode_rz;
        asm volatile(
            "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
            "v_fma_f64 %0, %2, %3, %4 "
            : "=v"(r5_rz)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
        r5_rz = fma_rz(r4, d3, r3);
#endif

        uint64_t r5_rz_temp = *(uint64_t*)&r5_rz;
        uint32_t* r5_rz_lo = (uint32_t*)&r5_rz_temp + 0;
        uint32_t* r5_rz_hi = (uint32_t*)&r5_rz_temp + 1;

        // 恢复尾数中隐含的1
        *r5_rz_hi = *r5_rz_hi & 0x000fffff;
        *r5_rz_hi = *r5_rz_hi | 0x00100000;

        uint64_t r5_rz_mantissa_dropped = r5_rz_temp << (r5_exp_true + 0x3f);

        double r5_rd = 0.0;
#if RUN_IN_AMD
        rounding_mode = rounding_mode_rd;
        asm volatile(
            "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
            "v_fma_f64 %0, %2, %3, %4 "
            : "=v"(r5_rd)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));

        asm volatile(
            "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1"
            : "=s"(rounding_mode)
            : "s"(rounding_mode_backup));
#else
        r5_rd = fma_rd(r4, d3, r3);
#endif

        // rounding
        uint32_t fixup = 0;
        if (r5_sign == 0) {
            if (r5_rd != r5_ru || r5_rz_mantissa_dropped != 0) {
                fixup = 1;
            }
        }
        else {
            if (r5_rz_mantissa_dropped != 0) {
                fixup = 0;
            }
        }
        *r5_lh = r5_rz_temp;

        // 计算结果的mantisa
        *r5_lh = *r5_lh >> (1 - r5_exp_true);

        // rounding
        *r5_lh = *r5_lh + fixup;

        // 恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        return r5_ru;
    }

    *r5_hi = *r5_hi + ((r5_exp_true - r5_exp_raw) << 20);

    return r5_ru;
}

double ddiv_rd(double y, double x)
{
#ifdef RUN_IN_AMD
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;
    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );
#endif

    double x0 = x;
    double y0 = y;

    uint32_t* x0_lo = (uint32_t*)&x0 + 0;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;

    uint32_t* y0_lo = (uint32_t*)&y0 + 0;
    uint32_t* y0_hi = (uint32_t*)&y0 + 1;

    uint32_t x0_exp_bias = ((*x0_hi) << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;

    uint32_t y0_exp_bias = ((*y0_hi) << 1) >> 21;
    uint32_t y0_exp_true = y0_exp_bias - 0x3ff;
    int32_t y0_exp_scale = 0;

    uint32_t exp_diff = y0_exp_bias - x0_exp_bias;

    // process abnormal
    bool x0_abnorm = (x0_exp_bias - 1) > 0x7fd;
    bool y0_abnorm = (y0_exp_bias - 1) > 0x7fd;
    if (x0_abnorm || y0_abnorm) {
        bool x_nan = isnan(x0);
        bool y_nan = isnan(y0);

        if (y_nan) {
            *y0_hi = *y0_hi | 0x80000;
            return y0;
        }
        if (x_nan) {
            *x0_hi = *x0_hi | 0x80000;
            return x0;
        }

        bool x_zero = iszero(x0);
        bool y_zero = iszero(y0);
        if (x_zero && y_zero) {
            return neg_nan;
        }

        bool x_inf = isinf(x0);
        bool y_inf = isinf(y0);
        if (x_inf && y_inf) {
            return neg_nan;
        }

        if (y_zero || x_inf) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_lo = 0;
            return x0; // return signed zero
        }
        if (y_inf || x_zero) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_hi = (*x0_hi) ^ 0x7ff00000; // get inf
            *x0_lo = 0;
            return x0; // return signed inf
        }

        if (y0_exp_bias == 0) // y denormal
        {
            y0 = y0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = -0x36;
        }
        if (x0_exp_bias == 0) // y denormal
        {
            x0 = x0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = y0_exp_scale + 0x36;
        }
    }

    // iter
    *x0_hi = *x0_hi - (x0_exp_true << 20);
    *y0_hi = *y0_hi - (y0_exp_true << 20);

#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;
#else
    double r0 = getRcpHUFU(x0);
#endif

    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;

    double r2 = __builtin_fma(r1, dd1, r1);
    double s1 = r0 * y0;
    double s2 = __builtin_fma(-x0, s1, y0);

    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, s2, s1);
    double d3 = __builtin_fma(-x0, r3, y0);

    double r5_rd = 0.0;
#if RUN_IN_AMD
    rounding_mode = rounding_mode_rd;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4 "
        : "=v"(r5_rd)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
    r5_rd = fma_rd(r4, d3, r3);
#endif

    uint64_t* r5_lh = (uint64_t*)&r5_rd;
    uint32_t* r5_lo = (uint32_t*)&r5_rd + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_rd + 1;
    uint32_t r5_exp_raw = (*r5_hi << 1) >> 21;
    uint32_t r5_exp_true = r5_exp_raw + exp_diff + y0_exp_scale;

    // r5_abnorm
    bool r5_abnorm = (r5_exp_true - 1) > 0x7fd;
    if (r5_abnorm) {
        uint32_t r5_sign = (*r5_hi) & 0x80000000;
        int32_t r5_exp_s = r5_exp_true - 0x3ff;

        double ret;
        if (r5_exp_s > 0x3ff) { // inf

            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0xfff0000000000000;
            }
            else
            {
                *(uint64_t*)&ret = 0x7fefffffffffffff;
            }
            return ret;
        }
        else if (r5_exp_s < -0x434) // -1076
        {
            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0x8000000000000001;
            }
            else
            {
                *(uint64_t*)&ret = 0x0000000000000000;
            }
            return ret;
        }

        double r5_rz = 0.0;
#if RUN_IN_AMD
        rounding_mode = rounding_mode_rz;
        asm volatile(
            "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
            "v_fma_f64 %0, %2, %3, %4 "
            : "=v"(r5_rz)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
        r5_rz = fma_rz(r4, d3, r3);
#endif
        uint64_t r5_rz_temp = *(uint64_t*)&r5_rz; // copy r5_rz hex val
        uint32_t* r5_rz_lo = (uint32_t*)&r5_rz_temp + 0;
        uint32_t* r5_rz_hi = (uint32_t*)&r5_rz_temp + 1;

        // 恢复尾数中隐含的1
        *r5_rz_hi = *r5_rz_hi & 0x000fffff;
        *r5_rz_hi = *r5_rz_hi | 0x00100000;

        uint64_t r5_rz_mantissa_dropped = r5_rz_temp << (r5_exp_true + 0x3f);

        double r5_ru = 0.0;
#if RUN_IN_AMD
        rounding_mode = rounding_mode_ru;
        asm volatile(
            "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
            "v_fma_f64 %0, %2, %3, %4 "
            : "=v"(r5_ru)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));

        asm volatile(
            "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1"
            : "=s"(rounding_mode)
            : "s"(rounding_mode_backup));
#else
        r5_ru = fma_ru(r4, d3, r3);
#endif

        // rounding
        uint32_t fixup = 0;
        if (r5_sign != 0) {
            if (r5_rd != r5_ru || r5_rz_mantissa_dropped != 0) {
                fixup = 1;
            }
        }
        else {
            if (r5_rz_mantissa_dropped != 0) {
                fixup = 0;
            }
        }

        *r5_lh = r5_rz_temp;

        // 计算结果的mantisa
        *r5_lh = *r5_lh >> (1 - r5_exp_true);

        // rounding
        *r5_lh = *r5_lh + fixup;

        // 恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        return r5_rd;
    }

    *r5_hi = *r5_hi + ((r5_exp_true - r5_exp_raw) << 20);

    return r5_rd;
}

double ddiv_rz(double y, double x)
{
#ifdef RUN_IN_AMD
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;
    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );
#endif

    double x0 = x;
    double y0 = y;

    uint32_t* x0_lo = (uint32_t*)&x0 + 0;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;

    uint32_t* y0_lo = (uint32_t*)&y0 + 0;
    uint32_t* y0_hi = (uint32_t*)&y0 + 1;

    uint32_t x0_exp_bias = ((*x0_hi) << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;

    uint32_t y0_exp_bias = ((*y0_hi) << 1) >> 21;
    uint32_t y0_exp_true = y0_exp_bias - 0x3ff;
    int32_t y0_exp_scale = 0;

    uint32_t exp_diff = y0_exp_bias - x0_exp_bias;

    // process abnormal
    bool x0_abnorm = (x0_exp_bias - 1) > 0x7fd;
    bool y0_abnorm = (y0_exp_bias - 1) > 0x7fd;
    if (x0_abnorm || y0_abnorm) {
        bool x_nan = isnan(x0);
        bool y_nan = isnan(y0);

        if (y_nan) {
            *y0_hi = *y0_hi | 0x80000;
            return y0;
        }
        if (x_nan) {
            *x0_hi = *x0_hi | 0x80000;
            return x0;
        }

        bool x_zero = iszero(x0);
        bool y_zero = iszero(y0);
        if (x_zero && y_zero) {
            return neg_nan;
        }

        bool x_inf = isinf(x0);
        bool y_inf = isinf(y0);
        if (x_inf && y_inf) {
            return neg_nan;
        }

        if (y_zero || x_inf) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_lo = 0;
            return x0; // return signed zero
        }
        if (y_inf || x_zero) {
            *x0_hi = ((*x0_hi) ^ (*y0_hi)); // consider x and y sign
            *x0_hi = (*x0_hi) & 0x80000000; // keep sign
            *x0_hi = (*x0_hi) ^ 0x7ff00000; // get inf
            *x0_lo = 0;
            return x0; // return signed inf
        }

        if (y0_exp_bias == 0) // y denormal
        {
            y0 = y0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = -0x36;
        }
        if (x0_exp_bias == 0) // y denormal
        {
            x0 = x0 * 1.80143985094819840000e+16; /* 2^54 */
            y0_exp_scale = y0_exp_scale + 0x36;
        }
    }

    // iter
    *x0_hi = *x0_hi - (x0_exp_true << 20);
    *y0_hi = *y0_hi - (y0_exp_true << 20);

#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;
#else
    double r0 = getRcpHUFU(x0);
#endif

    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;

    double r2 = __builtin_fma(r1, dd1, r1);
    double s1 = r0 * y0;
    double s2 = __builtin_fma(-x0, s1, y0);

    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, s2, s1);
    double d3 = __builtin_fma(-x0, r3, y0);

    double r5_rz = 0.0;
#if RUN_IN_AMD
    rounding_mode = rounding_mode_rz;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4 "
        : "=v"(r5_rz)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
    r5_rz = fma_rz(r4, d3, r3);
#endif

    uint64_t* r5_lh = (uint64_t*)&r5_rz;
    uint32_t* r5_lo = (uint32_t*)&r5_rz + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_rz + 1;
    uint32_t r5_exp_raw = (*r5_hi << 1) >> 21;
    uint32_t r5_exp_true = r5_exp_raw + exp_diff + y0_exp_scale;

    // r5_abnorm
    bool r5_abnorm = (r5_exp_true - 1) > 0x7fd;
    if (r5_abnorm) {
        uint32_t r5_sign = (*r5_hi) & 0x80000000;
        int32_t r5_exp_s = r5_exp_true - 0x3ff;

        double ret;
        if (r5_exp_s > 0x3ff) { // inf

            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0xffefffffffffffff;
            }
            else
            {
                *(uint64_t*)&ret = 0x7fefffffffffffff;
            }
            return ret;
        }
        else if (r5_exp_s < -0x434) // -1076
        {
            if (r5_sign != 0) // neg
            {
                *(uint64_t*)&ret = 0x8000000000000000;
            }
            else
            {
                *(uint64_t*)&ret = 0;
            }
            return ret;
        }

        // 恢复尾数中隐含的1
        *r5_hi = *r5_hi & 0x000fffff;
        *r5_hi = *r5_hi | 0x00100000;

        // 计算结果的mantisa
        *r5_lh = *r5_lh >> (1 - r5_exp_true);

        // 恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        return r5_rz;
    }

    *r5_hi = *r5_hi + ((r5_exp_true - r5_exp_raw) << 20);

    return r5_rz;
}

void ddiv(double* c, double x1, double x0, RoundMode mode)
{
    if (mode == MODE_RU) {
        *c = ddiv_ru(x1, x0);
    }
    else if (mode == MODE_RZ) {
        *c = ddiv_rz(x1, x0);
    }
    else if (mode == MODE_RD) {
        *c = ddiv_rd(x1, x0);
    }
    return;
}


double drcp_ru(double x) {
#ifdef RUN_IN_AMD
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;

    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );
#endif
    double ret = 0.0;
    double x0 = x;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;
    uint32_t* x0_lo = (uint32_t*)&x0;

    uint32_t x0_exp_bias = (*x0_hi << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;
    uint32_t x0_exp_scale = 0;

    if (x0_exp_bias - 0x1 >
        0x7fd) { // exp - 1 > 2045  => inf, nan, denormal, zero
        if (isnan(x0)) {             // nan
            *x0_hi = *x0_hi | 0x80000; // qnan
            return x0;
        }
        if (isinf(x0)) {                // inf
            *x0_hi = *x0_hi & 0x80000000; // zero
            *x0_lo = 0x0;
            return x0;
        }
        if (x0 == 0.0) {
            *x0_hi = *x0_hi & 0x80000000; // inf
            *x0_hi = *x0_hi ^ 0x7ff00000;
            *x0_lo = 0x0;
            return x0;
        }

        if (x0_exp_bias == 0x0) {               // denormal
            x0 = x0 * 1.80143985094819840000e+16; // 2^54
            x0_exp_scale = 0x36;
        }
        else {
            x0_exp_scale = 0x0;
        }
    }

    //normalize x0 to 1.xxxxxx * 2^0
    //*x0_hi = (*x0_hi & 0x800fffff) ^ 0x3ff00000;
    *x0_hi = *x0_hi - (x0_exp_true << 20);

    // double d1 = -x0 * r0 + 1.0;
    // double r1 = r0 * d1 + r0;
    // double dd1 = d1 * d1;
    // double r2 = r1 * dd1 + r1;

    // double d2 = -x0 * r2 + 1.0;
    // double r4 = r2 * d2 + r2;

    // double r3 = r2 * d1 + r0;
    // double d3 = -x0 * r3 + 1.0;
    // double r5 = r4 * d3 + r3;

    //get the initial rcp(x0)
#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;
#else
    double r0 = getRcpHUFU(x0);
#endif

    // iteration
    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;
    double r2 = __builtin_fma(r1, dd1, r1);
    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, d1, r0);
    double d3 = __builtin_fma(-x0, r3, 1.0);
    double r5_ru = 0;

#if RUN_IN_AMD
    rounding_mode = 0x4;
    //uint32_t rounding_mode_backup = 0;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4"
        : "=v"(r5_ru)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
    r5_ru = fma_ru(r4, d3, r3);
#endif

    uint64_t* r5_lh = (uint64_t*)&r5_ru;
    uint32_t* r5_lo = (uint32_t*)&r5_ru + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_ru + 1;
    uint32_t r5_mantissa = (*r5_hi << 1) >> 21;
    uint32_t r5_sign = *r5_hi & 0x80000000;

    int32_t r5_exp_true = r5_mantissa + x0_exp_scale - x0_exp_bias;
    uint32_t r5_exp_bias = r5_mantissa + x0_exp_scale - x0_exp_true;

    if (r5_exp_bias - 0x1 > 0x7fd) { // 2045
        if (r5_exp_true > 0x3ff) {     // inf
            if (r5_sign != 0) {          // negative number
                *(uint64_t*)&ret = 0xffefffffffffffff;
            }
            else { // positive number
                *(uint64_t*)&ret = 0x7ff0000000000000;
            }
            return ret;
        }

        if (r5_exp_true < -0x434) { //-1076
            if (r5_sign != 0) { // negative number
                *(uint64_t*)&ret = 0x8000000000000000;
            }
            else { // positive number
                *(uint64_t*)&ret = 0x0000000000000001;
            }
            return ret;
        }

        double r5_rz = 0.0;
#if RUN_IN_AMD
        rounding_mode = 0xc;
        asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, "
            "%2, %3, %4 "
            : "=v"(r5_rz)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
        r5_rz = fma_rz(r4, d3, r3);
#endif
        uint32_t* r5_rz_lo = (uint32_t*)&r5_rz + 0;
        uint32_t* r5_rz_hi = (uint32_t*)&r5_rz + 1;

        uint32_t r5_rz_mantissa_droped = *r5_rz_lo << (r5_exp_true + 1022 + 64);

        double r5_rd = 0.0;
#if RUN_IN_AMD
        rounding_mode = 0x8;
        asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, "
            "%2, %3, %4 "
            : "=v"(r5_rd)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));


        asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4) %1"
            : "=s"(rounding_mode)
            : "s"(rounding_mode_backup));
#else
        r5_rd = fma_rd(r4, d3, r3);
#endif
        //rounding
        uint32_t fixup = 0x0;
        if (r5_sign == 0) {
            if (r5_rd != r5_ru || r5_rz_mantissa_droped != 0)
                fixup = 0x1;
        }
        else {
            if (r5_rz_mantissa_droped != 0)
                fixup = 0x0;
        }

        //恢复尾数中隐含的1
        *r5_hi = *r5_hi & 0x000fffff;
        *r5_hi = *r5_hi | 0x00100000;
        *r5_lo = *r5_rz_lo;

        //计算结果的mantissa
        *r5_lh = *r5_lh >> (-r5_exp_true - 0x3fe);

        //rounding
        *r5_lo = *r5_lo + fixup;

        //恢复结果的exp
        *r5_hi = *r5_hi & 0x800fffff;
        //恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        //__builtin_amdgcn_s_setreg(6145, rounding_mode_backup);
        return r5_ru;
    }

    *r5_hi = *r5_hi - ((x0_exp_true - x0_exp_scale) << 20);

    return r5_ru;
}

double drcp_rz(double x) {
#ifdef RUN_IN_AMD
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;

    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );
#endif
    double ret = 0.0;
    double x0 = x;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;
    uint32_t* x0_lo = (uint32_t*)&x0;

    uint32_t x0_exp_bias = (*x0_hi << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;
    uint32_t x0_exp_scale = 0;

    if (x0_exp_bias - 0x1 >
        0x7fd) { // exp - 1 > 2045  => inf, nan, denormal, zero
        if (isnan(x0)) {             // nan
            *x0_hi = *x0_hi | 0x80000; // qnan
            return x0;
        }
        if (isinf(x0)) {                // inf
            *x0_hi = *x0_hi & 0x80000000; // zero
            *x0_lo = 0x0;
            return x0;
        }
        if (x0 == 0.0) {
            *x0_hi = *x0_hi & 0x80000000; // inf
            *x0_hi = *x0_hi ^ 0x7ff00000;
            *x0_lo = 0;
            return x0;
        }

        if (x0_exp_bias == 0x0) {               // denormal
            x0 = x0 * 1.80143985094819840000e+16; // 2^54
            x0_exp_scale = 0x36;
        }
        else {
            x0_exp_scale = 0x0;
        }
    }

    *x0_hi = *x0_hi - (x0_exp_true << 20);

    //get the initial rcp(x0)
#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;
#else
    double r0 = getRcpHUFU(x0);
#endif

    // iteration
    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;
    double r2 = __builtin_fma(r1, dd1, r1);
    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, d1, r0);
    double d3 = __builtin_fma(-x0, r3, 1.0);
    double r5_rz = 0;

#if RUN_IN_AMD
    rounding_mode = 0xc;
    //uint32_t rounding_mode_backup = 0;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4\n\t"
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %5\n\t"
        : "=v"(r5_rz)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3), "s"(rounding_mode_backup));
#else
    r5_rz = fma_rz(r4, d3, r3);
#endif

    uint64_t* r5_lh = (uint64_t*)&r5_rz;
    uint32_t* r5_lo = (uint32_t*)&r5_rz + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_rz + 1;
    uint32_t r5_exp_raw = (*r5_hi << 1) >> 21;

    int32_t r5_exp_true = r5_exp_raw + x0_exp_scale - x0_exp_bias;
    uint32_t r5_exp_bias = r5_exp_raw + x0_exp_scale - x0_exp_true;

    if (r5_exp_bias - 0x1 > 0x7fd) { // 2045
        uint32_t r5_sign = *r5_hi & 0x80000000;
        if (r5_exp_true > 0x3ff) {     // inf
            if (r5_sign != 0) {          // negative number
                *(uint64_t*)&ret = 0xffefffffffffffff;
            }
            else { // positive number
                *(uint64_t*)&ret = 0x7fefffffffffffff;
            }
            return ret;
        }

        if (r5_exp_true < -0x434) { //-1076
            if (r5_sign != 0) { // negative number
                *(uint64_t*)&ret = 0x8000000000000000;
            }
            else { // positive number
                *(uint64_t*)&ret = 0x0000000000000001;
            }
            return ret;
        }

        //恢复尾数中隐含的1
        *r5_hi = *r5_hi & 0x000fffff;
        *r5_hi = *r5_hi | 0x00100000;

        //计算结果的mantissa
        *r5_lh = *r5_lh >> (-r5_exp_true - 0x3fe);

        //恢复结果的exp
        *r5_hi = *r5_hi & 0x800fffff;
        //恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        return r5_rz;
    }

    *r5_hi = *r5_hi - ((x0_exp_true - x0_exp_scale) << 20);

    return r5_rz;
}

double drcp_rd(double x) {
#ifdef RUN_IN_AMD
    uint32_t rounding_mode = 0;
    uint32_t rounding_mode_backup = 0;

    asm volatile("s_getreg_b32 %0 hwreg(HW_REG_MODE, 0, 4)"
        : "=s"(rounding_mode_backup), "=s"(rounding_mode)
        : );
#endif
    double ret = 0.0;
    double x0 = x;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;
    uint32_t* x0_lo = (uint32_t*)&x0;

    uint32_t x0_exp_bias = (*x0_hi << 1) >> 21;
    uint32_t x0_exp_true = x0_exp_bias - 0x3ff;
    uint32_t x0_exp_scale = 0;

    if (x0_exp_bias - 0x1 >
        0x7fd) { // exp - 1 > 2045  => inf, nan, denormal, zero
        if (isnan(x0)) {             // nan
            *x0_hi = *x0_hi | 0x80000; // qnan
            return x0;
        }
        if (isinf(x0)) {                // inf
            *x0_hi = *x0_hi & 0x80000000; // zero
            *x0_lo = 0x0;
            return x0;
        }
        if (x0 == 0.0) {
            *x0_hi = *x0_hi & 0x80000000; // inf
            *x0_hi = *x0_hi ^ 0x7ff00000;
            *x0_lo = 0x0;
            return x0;
        }

        if (x0_exp_bias == 0x0) {               // denormal
            x0 = x0 * 1.80143985094819840000e+16; // 2^54
            x0_exp_scale = 0x36;
        }
        else {
            x0_exp_scale = 0x0;
        }
    }

    //normalize x0 to 1.xxxxxx * 2^0
    //*x0_hi = (*x0_hi & 0x800fffff) ^ 0x3ff00000;
    *x0_hi = *x0_hi - (x0_exp_true << 20);

    // double d1 = -x0 * r0 + 1.0;
    // double r1 = r0 * d1 + r0;
    // double dd1 = d1 * d1;
    // double r2 = r1 * dd1 + r1;

    // double d2 = -x0 * r2 + 1.0;
    // double r4 = r2 * d2 + r2;

    // double r3 = r2 * d1 + r0;
    // double d3 = -x0 * r3 + 1.0;
    // double r5 = r4 * d3 + r3;

    //get the initial rcp(x0)
#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    double r0 = (double)r0_f32;
#else
    double r0 = getRcpHUFU(x0);
#endif

    // iteration
    double d1 = __builtin_fma(-x0, r0, 1.0);
    double r1 = __builtin_fma(r0, d1, r0);
    double dd1 = d1 * d1;
    double r2 = __builtin_fma(r1, dd1, r1);
    double d2 = __builtin_fma(-x0, r2, 1.0);
    double r4 = __builtin_fma(r2, d2, r2);
    double r3 = __builtin_fma(r2, d1, r0);
    double d3 = __builtin_fma(-x0, r3, 1.0);
    double r5_rd = 0.0;

#if RUN_IN_AMD
    rounding_mode = 0x8;
    //uint32_t rounding_mode_backup = 0;
    asm volatile(
        "s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t"
        "v_fma_f64 %0, %2, %3, %4"
        : "=v"(r5_rd)
        : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
    r5_rd = fma_rd(r4, d3, r3);
#endif

    uint64_t* r5_lh = (uint64_t*)&r5_rd;
    uint32_t* r5_lo = (uint32_t*)&r5_rd + 0;
    uint32_t* r5_hi = (uint32_t*)&r5_rd + 1;
    uint32_t r5_mantissa = (*r5_hi << 1) >> 21;

    uint32_t r5_exp_bias = r5_mantissa + x0_exp_scale - x0_exp_true;

    if (r5_exp_bias - 0x1 > 0x7fd) { // 2045

        int32_t r5_exp_true = r5_mantissa + x0_exp_scale - x0_exp_bias;
        uint32_t r5_sign = *r5_hi & 0x80000000;

        if (r5_exp_true > 0x3ff) {     // inf
            if (r5_sign != 0) {          // negative number
                *(uint64_t*)&ret = 0xfff0000000000000;
            }
            else { // positive number
                *(uint64_t*)&ret = 0x7fefffffffffffff;
            }
            return ret;
        }

        if (r5_exp_true < -0x434) { //-1076
            if (r5_sign != 0) { // negative number
                *(uint64_t*)&ret = 0x8000000000000001;
            }
            else { // positive number
                *(uint64_t*)&ret = 0x0000000000000000;
            }
            return ret;
        }

        double r5_rz = 0.0;
#if RUN_IN_AMD
        rounding_mode = 0xc;
        asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, "
            "%2, %3, %4 "
            : "=v"(r5_rz)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));
#else
        r5_rz = fma_rz(r4, d3, r3);
#endif
        uint32_t* r5_rz_lo = (uint32_t*)&r5_rz + 0;
        uint32_t* r5_rz_hi = (uint32_t*)&r5_rz + 1;

        uint32_t r5_rz_mantissa_droped = *r5_rz_lo << (r5_exp_true + 1022 + 64);

        double r5_ru = 0.0;
#if RUN_IN_AMD
        rounding_mode = 0x4;
        asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4), %1\n\t v_fma_f64 %0, "
            "%2, %3, %4 "
            : "=v"(r5_ru)
            : "s"(rounding_mode), "v"(r4), "v"(d3), "v"(r3));


        asm volatile("s_setreg_b32 hwreg(HW_REG_MODE, 0, 4) %1"
            : "=s"(rounding_mode)
            : "s"(rounding_mode_backup));
#else
        r5_rd = fma_ru(r4, d3, r3);
#endif
        //rounding
        uint32_t fixup = 0x0;
        if (r5_sign != 0 && (r5_ru != r5_rd || r5_rz_mantissa_droped != 0)) {
            fixup = 0x1;
        }

        //恢复尾数中隐含的1
        *r5_hi = *r5_hi & 0x000fffff;
        *r5_hi = *r5_hi | 0x00100000;
        *r5_lo = *r5_rz_lo;

        //计算结果的mantissa
        *r5_lh = *r5_lh >> (-r5_exp_true - 0x3fe);

        //rounding
        *r5_lo = *r5_lo + fixup;

        //恢复结果的exp
        *r5_hi = *r5_hi & 0x800fffff;
        //恢复结果的sign
        *r5_hi = *r5_hi | r5_sign;

        //__builtin_amdgcn_s_setreg(6145, rounding_mode_backup);
        return r5_rd;
    }

    *r5_hi = *r5_hi - ((x0_exp_true - x0_exp_scale) << 20);

    return r5_rd;
}

double slow_drcp_rn(double x) {

    double r0 = 0.0;
    double ret = x;
    double x0 = x;

    uint32_t* x0_hi = (uint32_t*)&x0 + 1;
    uint32_t* x0_lo = (uint32_t*)&x0;
    uint32_t* r0_hi = (uint32_t*)&r0 + 1;
    uint32_t* r0_lo = (uint32_t*)&r0;

    //return 1.0/x;
    if (isnan(x0)) { // nan
        *x0_hi = *x0_hi | 0x80000;
        return x0;
    }

    uint32_t x0_hi_no_sign = *x0_hi & 0x7fffffff;

    if (((uint32_t)(x0_hi_no_sign - 0x1) >= 0x7fefffff)) { //inf denormal
        *x0_hi ^= 0x7ff00000;
        *x0_lo = 0x0;
        return x0;
    }

    double fixup;
    uint32_t* fixup_lo = (uint32_t*)&fixup + 0;
    uint32_t* fixup_hi = (uint32_t*)&fixup + 1;
    *fixup_hi = 0x0;

    if (x0_hi_no_sign >= 0x1000001) {

        uint32_t r0_lo_tmp = (*x0_hi | 0x7fffffff) - 0x100000;
        *x0_hi = *x0_hi - 0x3fe00000;

#if RUN_IN_AMD
        float x0_f32 = (float)x0;
        float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
        r0 = (double)r0_f32;
#else
        r0 = getRcpHUFU(x0);
#endif
        *r0_lo = r0_lo_tmp;
        *fixup_hi = 0x00100000;
        //*(uint64_t*)&fixup = 0x0010000006067828;
        //*(uint64_t*)&fixup = 0x0010000000000000;

        //double d1  = -x0 * r0 + 1.0
        //double dd1 = d1 * d1 + d1
        //double r1  = r0 * dd1 + r0
        //double d2  = -x0 * r1 + 1.0
        //double r2  = r1 * d2 + r1
        //double r3 = r2 * (double)0x0010000006067828
        //double d3  = r3 * -x + 1.0;
        //double dd3 = d3 * d3 + d3
        //double r4  = r3 * dd3 + r3

        double d1 = __builtin_fma(r0, -x0, 1.0);
        double dd1 = __builtin_fma(d1, d1, d1);
        double r1 = __builtin_fma(r0, dd1, r0);
        double d2 = __builtin_fma(-x0, r1, 1.0);
        double r2 = __builtin_fma(r1, d2, r1);
        double r3 = r2 * fixup;
        double d3 = __builtin_fma(r3, -x, 1.0);
        double dd3 = __builtin_fma(d3, d3, d3);
        double r4 = __builtin_fma(r3, dd3, r3);
        return r4;
    }
    else {
        *fixup_hi = 0x46900000;
        //*(uint64_t*)&fixup = 0x4690000000000000;// 2^106
        uint32_t r0_lo_tmp = (*x0_hi | 0x7fffffff) - 0x100000;

        x0 = x0 * fixup;

#if RUN_IN_AMD
        float x0_f32 = (float)x0;
        float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
        r0 = (double)r0_f32;
#else
        r0 = getRcpHUFU(x0);
#endif
        *r0_lo = r0_lo_tmp;

        double d1 = __builtin_fma(-x0, r0, 1.0);
        double dd1 = __builtin_fma(d1, d1, d1);
        double r1 = __builtin_fma(r0, dd1, r0);
        double d2 = __builtin_fma(-x0, r1, 1.0);
        double r2 = __builtin_fma(r1, d2, r1);

        return r2 * fixup;
    }

    return 0.0;
}

double drcp_rn(double x) {

    double r0 = 0.0;
    double ret = x;
    double x0 = x;
    uint32_t* x0_hi = (uint32_t*)&x0 + 1;
    uint32_t* x0_lo = (uint32_t*)&x0;
    uint32_t* r0_hi = (uint32_t*)&r0 + 1;
    uint32_t* r0_lo = (uint32_t*)&r0;

    //double x0_mantissa = __builtin_amdgcn_frexp_mant(x0);
    //int32_t x0_exp = __builtin_amdgcn_frexp_exp(x0);
    //float x0_mantissa_f32 = (float) x0_mantissa;
    //float r0_mantissa_f32 = __builtin_amdgcn_rcpf(x0_mantissa_f32);
    //double r0_mantiss = (double)r0_mantissa_f32;
    //r0 = __builtin_amdgcn_ldexp(r0_mantiss, -x0_exp);

#if RUN_IN_AMD
    float x0_f32 = (float)x0;
    float r0_f32 = __builtin_amdgcn_rcpf(x0_f32);
    r0 = (double)r0_f32;
#else
    r0 = getRcpHUFU(x0);
#endif

    *r0_lo = *x0_hi + 0x00300402;
    if (!(abs(*(float*)r0_lo) < (float)5.878909486335835e-39)) {

        // iteration
        double d1 = __builtin_fma(r0, -x0, 1.0);
        double dd = __builtin_fma(d1, d1, d1);
        double r1 = __builtin_fma(r0, dd, r0);
        double d2 = __builtin_fma(r1, -x0, 1.0);
        double r2 = __builtin_fma(r1, d2, r1);

        return r2;
    }
    return  slow_drcp_rn(x);
}

void drcp(double* c, double x, RoundMode mode)
{
    if (mode == MODE_RU) {
        *c = drcp_ru(x);
    }
    else if (mode == MODE_RZ) {
        *c = drcp_rz(x);
    }
    else if (mode == MODE_RD) {
        *c = drcp_rd(x);
    }
    else if (mode == MODE_RN) {
        *c = drcp_rn(x);
    }
    return;
}


__global__ void ddiv_ru_kernel(double* c, double x1, double x0)
{
    *c = __ddiv_ru(x1, x0);
}

__global__ void ddiv_rz_kernel(double* c, double x1, double x0)
{
    *c = __ddiv_rz(x1, x0);
}

__global__ void ddiv_rd_kernel(double* c, double x1, double x0)
{
    *c = __ddiv_rd(x1, x0);
}

__global__ void ddiv_rn_kernel(double* c, double x1, double x0)
{
    *c = __ddiv_rn(x1, x0);
}

void ddiv_gpu(double* z, double x, double y, RoundMode mode)
{
    double* dev_z = 0;
    size_t size = 1;
    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaError_t cudaStatus = cudaMalloc((void**)&dev_z, size * sizeof(double));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    if (mode == MODE_RU) {
        ddiv_ru_kernel << <1, 1 >> > (dev_z, x, y);
    }
    else if (mode == MODE_RZ) {
        ddiv_rz_kernel << <1, 1 >> > (dev_z, x, y);
    }
    else if (mode == MODE_RD) {
        ddiv_rd_kernel << <1, 1 >> > (dev_z, x, y);
    }
    else if (mode == MODE_RN) {
        ddiv_rn_kernel << <1, 1 >> > (dev_z, x, y);
    }

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(z, dev_z, size * sizeof(double), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_z);

    return;
}

__global__ void drcp_ru_kernel(double* c, double x)
{
    *c = __drcp_ru(x);
}

__global__ void drcp_rz_kernel(double* c, double x)
{
    *c = __drcp_rz(x);
}

__global__ void drcp_rd_kernel(double* c, double x)
{
    *c = __drcp_rd(x);
}

__global__ void drcp_rn_kernel(double* c, double x)
{
    *c = __drcp_rn(x);
}

void drcp_gpu(double* z, double x, RoundMode mode)
{
    double* dev_z = 0;
    size_t size = 1;
    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaError_t cudaStatus = cudaMalloc((void**)&dev_z, size * sizeof(double));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    if (mode == MODE_RU) {
        drcp_ru_kernel << <1, 1 >> > (dev_z, x);
    }
    else if (mode == MODE_RZ) {
        drcp_rz_kernel << <1, 1 >> > (dev_z, x);
    }
    else if (mode == MODE_RD) {
        drcp_rd_kernel << <1, 1 >> > (dev_z, x);
    }
    else if (mode == MODE_RN) {
        drcp_rn_kernel << <1, 1 >> > (dev_z, x);
    }

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }

    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(z, dev_z, size * sizeof(double), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_z);

    return;
}


bool run(double a1, double a2)
{
#if 0
    for (int i = MODE_RU; i < MODE_RN; ++i) {
        RoundMode mode = RoundMode(i);
        double rcpu, rgpu;
        ddiv_gpu(&rgpu, a1, a2, mode);
        ddiv(&rcpu, a1, a2, mode);
#else
    for (int i = MODE_RU; i <= MODE_RN; ++i) {
        RoundMode mode = RoundMode(i);
        double rcpu, rgpu;
        double a1 = 1.0f;
        drcp_gpu(&rgpu, a2, mode);
        drcp(&rcpu, a2,  mode);
#endif
        uint64_t rcpu_hex = *((uint64_t*)&rcpu);
        uint64_t rgpu_hex = *((uint64_t*)&rgpu);
        if (rcpu_hex != rgpu_hex)
        {
            double a3 = a1 / a2;
            double* a11 = &a1;
            double* a31 = &a3;
            uint64_t a3_hex = *((uint64_t*)a31);
            printf("==============================\n");
            printf("mode: %d\n", i);
            printf("err: a1[%f] / a2[%f]\n\n", a1, a2);
            printf("     a1[%llx]\n\n", (uint64_t&)a1);
            printf("     a2[%llx]\n\n", (uint64_t&)a2);
            printf("     cpu %f, %llx\n\n", a3, a3_hex);
            printf("self-cpu %f, %llx\n\n", rcpu, rcpu_hex);
            printf("     gpu %f, %llx\n\n", rgpu, rgpu_hex);
            return false;
        }
    }
    return true;
}

inline double HexToDouble(uint64_t hex)
{
    double d = *(double*)&(hex);
    return d;
}

int main()
{
    cudaSetDevice(0);
    uint64_t nans_hex = 0x7FF0000000000001;
    uint64_t nanq_hex = 0x7FF8000000000001;
    uint64_t nan_allf_hex = 0x7FFFFFFFFFFFFFFF;
    double nans = HexToDouble(nans_hex);
    double nanq = HexToDouble(nanq_hex);
    double nanallf = HexToDouble(nan_allf_hex);

    uint64_t inf_pos_hex = 0x7FF0000000000000;
    uint64_t inf_neg_hex = 0xFFF0000000000000;
    double inf_pos = HexToDouble(inf_pos_hex);
    double inf_neg = HexToDouble(inf_neg_hex);

    uint64_t subnorm_min_hex = 1;
    double subnorm_min = HexToDouble(subnorm_min_hex);

    uint64_t subnorm_max_hex = 0x000FFFFFFFFFFFFF;
    double subnorm_max = HexToDouble(subnorm_max_hex);

    uint64_t one_hex = 0x3FF0000000000000;
    double one = HexToDouble(one_hex);

    uint64_t onep1_hex = 0x3FF0000000000001;
    double one_p1 = HexToDouble(onep1_hex);

    uint64_t onep2_hex = 0x3FF0000000000002;
    double one_p2 = HexToDouble(onep2_hex);

    uint64_t two_hex = 0x4000000000000000;
    double two = HexToDouble(two_hex);

    uint64_t min_pos_hex = 0x0010000000000000;
    double min_pos = HexToDouble(min_pos_hex);

    uint64_t max_double_hex = 0x7FEFFFFFFFFFFFFF;
    double max_double = HexToDouble(max_double_hex);

    uint64_t oneDivThree_hex = 0x3FD5555555555555;
    double oneDivThree = HexToDouble(oneDivThree_hex);

    uint64_t pi_hex = 0x400921FB54442D18;
    double pi = HexToDouble(pi_hex);

    std::mt19937_64 num((unsigned)time(NULL));
    std::uniform_int_distribution<uint64_t> distribution(0, UINT64_MAX);
    enum {
        D_NANS = 0,
        D_NANQ = 1,
        D_NAN_ALL_F = 2,

        D_INF_POS = 3,
        D_INF_NEG = 4,

        D_ZERO_POS = 5,
        D_ZERO_NEG = 6,

        D_DENORM_MIN = 7,
        D_DENORM_MAX = 8,

        D_one = 9,
        D_one_p1 = 10,
        D_one_p2 = 11,
        D_two,
        D_min_pos,
        D_max_double,
        D_1d3,
        D_pi,

        D_NORM_1,
        D_NORM_2,
        D_NORM_3,
        D_NORM_4,
        D_NORM_5,
        D_NORM_6,

        D_RD_0,
        D_RD_1,

        D_MAX_NUM
    };
    std::vector<double> double_vals = {
        nans, nanq, nanallf,
        inf_pos, inf_neg,
        /*pos-zero*/0.0, /*neg-zero*/-0.0,

        /*denorm*/subnorm_min,
        /*denorm*/subnorm_max,

        one,
        one_p1,
        one_p2,
        two,

        min_pos,
        max_double,

        pi,
        oneDivThree,

        /*norm1*/0.0000000099901230001231,
        /*norm2*/1.0,
        /*norm3*/99551599999999999999999.551241455,
        /*norm4*/2.1,
        /*norm5*/-1.0,
        /*norm6*/-1111.1,
        HexToDouble(distribution(num)),
        HexToDouble(distribution(num)),
    };

    int loop = 10;
    while (loop--)
    {
        double_vals[D_RD_0] = HexToDouble(distribution(num));
        double_vals[D_RD_1] = HexToDouble(distribution(num));

        for (size_t i = 0; i < double_vals.size(); ++i)
        {
            for (size_t j = 0; j < double_vals.size(); ++j)
            {
                double a1 = double_vals[i];
                double a2 = double_vals[j];
                if (!run(a1, a2)) {
					printf("1 i,j:%d,%d\n", i, j);
					printf("a1 %f, %llx\n", a1, *(uint64_t*)&a1);
					printf("a2 %f, %llx\n", a2, *(uint64_t*)&a2);
					getchar();
				}
				if (!run(-a1, -a2)) {
					printf("2 i,j:%d,%d\n", i, j);
					getchar();
				}
				if (!run(-a1, a2)) {
					printf("3 i,j:%d,%d\n", i, j);
					getchar();
				}

				if (!run(a1, -a2)) {
					printf("4 i,j:%d,%d\n", i, j);
					getchar();
				}
			}
        }
    }
    return 0;
}
