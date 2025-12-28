#include <cuda.h>
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

    CUdeviceptr d_sum;
    CUdeviceptr d_prod;
    size_t bytes = sizeof(int) * lanes;
    cuMemAlloc(&d_sum, bytes);
    cuMemAlloc(&d_prod, bytes);

    std::vector<int> host_a0(lanes);
    std::vector<int> host_a1(lanes);
    std::vector<int> host_a2(lanes);
    for (unsigned lane = 0; lane < lanes; ++lane) {
        int value = static_cast<int>(lane);
        host_a0[lane] = value;
        host_a1[lane] = value;
        host_a2[lane] = 1;
    }
    CUdeviceptr d_a0, d_a1, d_a2;
    cuMemAlloc(&d_a0, bytes);
    cuMemAlloc(&d_a1, bytes);
    cuMemAlloc(&d_a2, bytes);
    cuMemcpyHtoD(d_a0, host_a0.data(), bytes);
    cuMemcpyHtoD(d_a1, host_a1.data(), bytes);
    cuMemcpyHtoD(d_a2, host_a2.data(), bytes);

    CUmodule mod;
    cuModuleLoad(&mod, "add.mul.cubin");

    CUfunction fn;
    cuModuleGetFunction(&fn, mod, "add_mul");

    void *args[] = {&d_cycles, &d_sum, &d_prod, &d_a0, &d_a1, &d_a2};
    cuLaunchKernel(fn, 1, 1, 1, lanes, 1, 1, 0, nullptr, args, nullptr);
    cuCtxSynchronize();

    std::vector<unsigned long long> cycles(lanes);
    cuMemcpyDtoH(cycles.data(), d_cycles, sizeof(unsigned long long) * lanes);

    std::vector<int> sum_out(lanes);
    std::vector<int> prod_out(lanes);
    cuMemcpyDtoH(sum_out.data(), d_sum, bytes);
    cuMemcpyDtoH(prod_out.data(), d_prod, bytes);

    unsigned long long total_cycles = 0;
    for (auto c : cycles) {
        total_cycles += c;
    }
    double avg_cycles = static_cast<double>(total_cycles) / lanes;
    double avg_iadd3 = avg_cycles / static_cast<double>(iadd3_insns);
    std::printf("Add/Mul latency: %.2f cycles/lane (sum %llu cycles across %u lanes)\n",
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
        if (prod_out[lane] != 1) {
            std::printf("Mismatch lane %u prod: got %d expected 1\n", lane,
                        prod_out[lane]);
            ok = false;
        }
    }
    if (ok) {
        std::printf("Sum/prod outputs match expected values across all lanes.\n");
    }

    cuMemFree(d_a2);
    cuMemFree(d_a1);
    cuMemFree(d_a0);
    cuMemFree(d_prod);
    cuMemFree(d_sum);
    cuMemFree(d_cycles);
    cuModuleUnload(mod);
    cuCtxSetCurrent(nullptr);
    cuDevicePrimaryCtxRelease(dev);

    return 0;
}
