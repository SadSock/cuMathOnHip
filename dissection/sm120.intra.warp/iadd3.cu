#include <cuda.h>
#include <cstddef>
#include <cstdio>
#include <vector>

// Host-side driver that launches the hand-written PTX kernel and reports IADD3 latency.
int main() {
    constexpr unsigned warp_size = 32;
    constexpr unsigned add_ops = 1024;
    constexpr unsigned iadd3_insns = add_ops / 2; // each IADD3 consumes two PTX add.s32

    cuInit(0);

    CUdevice dev;
    cuDeviceGet(&dev, 0);

    CUcontext ctx;
    cuDevicePrimaryCtxRetain(&ctx, dev);
    cuCtxSetCurrent(ctx);

    CUdeviceptr d_cycles;
    cuMemAlloc(&d_cycles, sizeof(unsigned long long) * warp_size);

    size_t out_bytes = sizeof(int) * warp_size;
    CUdeviceptr d_out;
    cuMemAlloc(&d_out, out_bytes);

    // Prepare input vectors on host and upload to device.
    std::vector<int> host_a(warp_size);
    std::vector<int> host_b(warp_size);
    for (unsigned i = 0; i < warp_size; ++i) {
        host_a[i] = static_cast<int>(i);
        host_b[i] = static_cast<int>(2 * i);
    }
    CUdeviceptr d_a;
    CUdeviceptr d_b;
    cuMemAlloc(&d_a, out_bytes);
    cuMemAlloc(&d_b, out_bytes);
    cuMemcpyHtoD(d_a, host_a.data(), out_bytes);
    cuMemcpyHtoD(d_b, host_b.data(), out_bytes);

    CUmodule mod;
    cuModuleLoad(&mod, "iadd3.cubin");

    CUfunction fn;
    cuModuleGetFunction(&fn, mod, "iadd3");

    void *args[] = {&d_cycles, &d_out, &d_a, &d_b};

    // Launch a single warp so every lane executes the explicit IADD3 sequence.
    cuLaunchKernel(fn, 1, 1, 1, warp_size, 1, 1, 0, nullptr, args, nullptr);
    cuCtxSynchronize();

    std::vector<unsigned long long> cycles(warp_size);
    cuMemcpyDtoH(cycles.data(), d_cycles,
                 sizeof(unsigned long long) * warp_size);

    std::vector<int> out(warp_size);
    cuMemcpyDtoH(out.data(), d_out, out_bytes);

    unsigned long long sum_cycles = 0;
    for (unsigned long long c : cycles) {
        sum_cycles += c;
    }
    double avg_cycles = static_cast<double>(sum_cycles) / warp_size;
    double avg_iadd3 = avg_cycles / static_cast<double>(iadd3_insns);
    std::printf(
        "Vector IADD3 latency: %.2f cycles/lane (sum %llu cycles across %u lanes)\n",
        avg_cycles, sum_cycles, warp_size);
    std::printf("Approximate latency per IADD3: %.2f cycles over %u ops.\n",
                avg_iadd3, iadd3_insns);

    bool all_match = true;
    for (unsigned i = 0; i < warp_size; ++i) {
        int expected =
            static_cast<int>((add_ops / 2u) * (host_a[i] + host_b[i]));
        if (out[i] != expected) {
            std::printf("Mismatch at lane %u: got %d, expected %d\n", i, out[i],
                        expected);
            all_match = false;
        }
    }
    if (all_match) {
        std::printf("All %u outputs match expected (ops/2)*(a+b) per lane.\n",
                    warp_size);
    }

    cuMemFree(d_b);
    cuMemFree(d_a);
    cuMemFree(d_out);
    cuMemFree(d_cycles);
    cuModuleUnload(mod);
    cuCtxSetCurrent(nullptr);
    cuDevicePrimaryCtxRelease(dev);

    return 0;
}
