#include <cuda.h>
#include <cstddef>
#include <cstdio>
#include <vector>

int main() {
    constexpr unsigned lanes = 32;
    constexpr unsigned scalars = 7;
    constexpr unsigned loops = 4096;
    constexpr unsigned imad_insns = 28672;

    cuInit(0);

    CUdevice dev;
    cuDeviceGet(&dev, 0);

    CUcontext ctx;
    cuDevicePrimaryCtxRetain(&ctx, dev);
    cuCtxSetCurrent(ctx);

    CUdeviceptr d_cycles;
    cuMemAlloc(&d_cycles, sizeof(unsigned long long) * lanes);

    size_t elem_count = lanes * scalars;
    size_t bytes = sizeof(int) * elem_count;
    CUdeviceptr d_out;
    cuMemAlloc(&d_out, bytes);

    std::vector<int> host_a(elem_count);
    std::vector<int> host_b(elem_count);
    std::vector<int> host_c(elem_count);
    for (unsigned lane = 0; lane < lanes; ++lane) {
        for (unsigned idx = 0; idx < scalars; ++idx) {
            unsigned offset = lane * scalars + idx;
            host_a[offset] = static_cast<int>(lane + idx);
            host_b[offset] = static_cast<int>(lane + 1);
            host_c[offset] = static_cast<int>(idx);
        }
    }

    CUdeviceptr d_a, d_b, d_c;
    cuMemAlloc(&d_a, bytes);
    cuMemAlloc(&d_b, bytes);
    cuMemAlloc(&d_c, bytes);
    cuMemcpyHtoD(d_a, host_a.data(), bytes);
    cuMemcpyHtoD(d_b, host_b.data(), bytes);
    cuMemcpyHtoD(d_c, host_c.data(), bytes);

    CUmodule mod;
    cuModuleLoad(&mod, "imad.cubin");

    CUfunction fn;
    cuModuleGetFunction(&fn, mod, "imad");

    void *args[] = {&d_cycles, &d_out, &d_a, &d_b, &d_c};
    cuLaunchKernel(fn, 1, 1, 1, lanes, 1, 1, 0, nullptr, args, nullptr);
    cuCtxSynchronize();

    std::vector<unsigned long long> cycles(lanes);
    cuMemcpyDtoH(cycles.data(), d_cycles, sizeof(unsigned long long) * lanes);

    std::vector<int> out(elem_count);
    cuMemcpyDtoH(out.data(), d_out, bytes);

    unsigned long long total_cycles = 0;
    for (auto c : cycles) {
        total_cycles += c;
    }
    double avg_cycles = static_cast<double>(total_cycles) / lanes;
    double avg_imad = avg_cycles / static_cast<double>(imad_insns);
    std::printf("IMAD latency: %.2f cycles/lane (sum %llu cycles across %u lanes)\n",
                avg_cycles, total_cycles, lanes);
    std::printf("Approximate latency per IMAD: %.2f cycles over %u ops.\n",
                avg_imad, imad_insns);

    bool ok = true;
    for (unsigned lane = 0; lane < lanes; ++lane) {
        for (unsigned idx = 0; idx < scalars; ++idx) {
            unsigned offset = lane * scalars + idx;
            long long product = static_cast<long long>(host_a[offset]) *
                                static_cast<long long>(host_b[offset]);
            long long expected =
                static_cast<long long>(host_c[offset]) +
                static_cast<long long>(loops) * product;
            if (out[offset] != expected) {
                std::printf("Mismatch lane %u idx %u: got %d expected %lld\n",
                            lane, idx, out[offset], expected);
                ok = false;
            }
        }
    }
    if (ok) {
        std::printf("All %u outputs match expected IMAD results.\n",
                    lanes * scalars);
    }

    cuMemFree(d_c);
    cuMemFree(d_b);
    cuMemFree(d_a);
    cuMemFree(d_out);
    cuMemFree(d_cycles);
    cuModuleUnload(mod);
    cuCtxSetCurrent(nullptr);
    cuDevicePrimaryCtxRelease(dev);

    return 0;
}
