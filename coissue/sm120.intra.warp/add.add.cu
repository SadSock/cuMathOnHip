#include <cuda.h>
#include <cstddef>
#include <cstdio>
#include <vector>

// Host-side driver that launches the hand-written PTX kernel and reports IADD3 latency.
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

    CUdeviceptr d_out;
    size_t bytes = sizeof(int) * lanes;
    cuMemAlloc(&d_out, bytes);

    std::vector<int> host_a0(lanes);
    std::vector<int> host_a1(lanes);
    for (unsigned lane = 0; lane < lanes; ++lane) {
        int value = static_cast<int>(lane);
        host_a0[lane] = value;
        host_a1[lane] = value;
    }

    CUdeviceptr d_a0, d_a1;
    cuMemAlloc(&d_a0, bytes);
    cuMemAlloc(&d_a1, bytes);
    cuMemcpyHtoD(d_a0, host_a0.data(), bytes);
    cuMemcpyHtoD(d_a1, host_a1.data(), bytes);

    CUmodule mod;
    cuModuleLoad(&mod, "add.add.cubin");

    CUfunction fn;
    cuModuleGetFunction(&fn, mod, "add_add");

    void *args[] = {&d_cycles, &d_out, &d_a0, &d_a1};

    cuLaunchKernel(fn, 1, 1, 1, lanes, 1, 1, 0, nullptr, args, nullptr);
    cuCtxSynchronize();

    std::vector<unsigned long long> cycles(lanes);
    cuMemcpyDtoH(cycles.data(), d_cycles,
                 sizeof(unsigned long long) * lanes);

    std::vector<int> out(lanes);
    cuMemcpyDtoH(out.data(), d_out, bytes);

    unsigned long long sum_cycles = 0;
    for (unsigned long long c : cycles) {
        sum_cycles += c;
    }
    double avg_cycles = static_cast<double>(sum_cycles) / lanes;
    double avg_iadd3 = avg_cycles / static_cast<double>(iadd3_insns);
    std::printf(
        "Vector IADD3 latency: %.2f cycles/lane (sum %llu cycles across %u lanes)\n",
        avg_cycles, sum_cycles, lanes);
    std::printf("Approximate latency per IADD3: %.2f cycles over %u ops.\n",
                avg_iadd3, iadd3_insns);

    bool all_match = true;
    for (unsigned lane = 0; lane < lanes; ++lane) {
        int expected = static_cast<int>(loops * (host_a0[lane] + host_a1[lane]));
        if (out[lane] != expected) {
            std::printf("Mismatch lane %u sum: got %d expected %d\n", lane,
                        out[lane], expected);
            all_match = false;
        }
    }
    if (all_match) {
        std::printf("All %u outputs match expected loops * sum of inputs per lane.\n",
                    lanes);
    }

    cuMemFree(d_a1);
    cuMemFree(d_a0);
    cuMemFree(d_out);
    cuMemFree(d_cycles);
    cuModuleUnload(mod);
    cuCtxSetCurrent(nullptr);
    cuDevicePrimaryCtxRelease(dev);

    return 0;
}
