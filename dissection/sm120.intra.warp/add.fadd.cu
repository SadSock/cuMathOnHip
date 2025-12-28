#include <cuda.h>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <vector>

int main() {
    constexpr unsigned lanes = 32;
    constexpr unsigned loops = 4096;
    constexpr unsigned iadd3_insns = 4096;

    cuInit(0);

    CUdevice dev;
    cuDeviceGet(&dev, 0);

    CUcontext ctx;
    cuDevicePrimaryCtxRetain(&ctx, dev);
    cuCtxSetCurrent(ctx);

    CUdeviceptr d_cycles;
    cuMemAlloc(&d_cycles, sizeof(unsigned long long) * lanes);

    const size_t sum_bytes = sizeof(int) * lanes;
    const size_t fsum_bytes = sizeof(float) * lanes;
    CUdeviceptr d_sum;
    CUdeviceptr d_fsum;
    cuMemAlloc(&d_sum, sum_bytes);
    cuMemAlloc(&d_fsum, fsum_bytes);

    std::vector<int> host_a0(lanes);
    std::vector<int> host_a1(lanes);
    std::vector<float> host_a2(lanes);
    for (unsigned lane = 0; lane < lanes; ++lane) {
        int value = static_cast<int>(lane);
        host_a0[lane] = value;
        host_a1[lane] = value;
        host_a2[lane] = static_cast<float>(lane);
    }

    CUdeviceptr d_a0;
    CUdeviceptr d_a1;
    CUdeviceptr d_a2;
    cuMemAlloc(&d_a0, sum_bytes);
    cuMemAlloc(&d_a1, sum_bytes);
    cuMemAlloc(&d_a2, fsum_bytes);
    cuMemcpyHtoD(d_a0, host_a0.data(), sum_bytes);
    cuMemcpyHtoD(d_a1, host_a1.data(), sum_bytes);
    cuMemcpyHtoD(d_a2, host_a2.data(), fsum_bytes);

    CUmodule mod;
    cuModuleLoad(&mod, "add.fadd.cubin");

    CUfunction fn;
    cuModuleGetFunction(&fn, mod, "add_fadd");

    void *args[] = {&d_cycles, &d_sum, &d_fsum, &d_a0, &d_a1, &d_a2};
    cuLaunchKernel(fn, 1, 1, 1, lanes, 1, 1, 0, nullptr, args, nullptr);
    cuCtxSynchronize();

    std::vector<unsigned long long> cycles(lanes);
    cuMemcpyDtoH(cycles.data(), d_cycles, sizeof(unsigned long long) * lanes);

    std::vector<int> sum_out(lanes);
    cuMemcpyDtoH(sum_out.data(), d_sum, sum_bytes);

    std::vector<float> fsum_out(lanes);
    cuMemcpyDtoH(fsum_out.data(), d_fsum, fsum_bytes);

    unsigned long long total_cycles = 0;
    for (auto c : cycles) {
        total_cycles += c;
    }
    double avg_cycles = static_cast<double>(total_cycles) / lanes;
    double avg_iadd3 = avg_cycles / static_cast<double>(iadd3_insns);
    std::printf("Add/Fadd latency: %.2f cycles/lane (sum %llu cycles across %u lanes)\n",
                avg_cycles, total_cycles, lanes);
    std::printf("Approximate latency per IADD3: %.2f cycles over %u ops.\n",
                avg_iadd3, iadd3_insns);

    bool ok = true;
    const int sum_factor = static_cast<int>(loops);
    for (unsigned lane = 0; lane < lanes; ++lane) {
        int expected_sum = sum_factor * (host_a0[lane] + host_a1[lane]);
        if (sum_out[lane] != expected_sum) {
            std::printf("Mismatch lane %u sum: got %d expected %d\n", lane,
                        sum_out[lane], expected_sum);
            ok = false;
        }
        const float expected_fsum = sum_factor * host_a2[lane];
        if (std::fabs(fsum_out[lane] - expected_fsum) > 1e-3f) {
            std::printf("Mismatch lane %u fsum: got %f expected %f\n", lane,
                        fsum_out[lane], expected_fsum);
            ok = false;
        }
    }
    if (ok) {
        std::printf("Sum/fsum outputs match expected values across all lanes.\n");
    }

    cuMemFree(d_a2);
    cuMemFree(d_a1);
    cuMemFree(d_a0);
    cuMemFree(d_fsum);
    cuMemFree(d_sum);
    cuMemFree(d_cycles);
    cuModuleUnload(mod);
    cuCtxSetCurrent(nullptr);
    cuDevicePrimaryCtxRelease(dev);

    return 0;
}
