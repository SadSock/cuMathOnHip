#include <cuda_fp4.h>
#include <cuda_fp8.h>
#include <cuda_runtime.h>

#include <cstdint>
#include <cstdio>

struct Result {
    uint8_t nibble[8];
    uint8_t e4m3[8];
    uint8_t e5m2[8];
    float value[8];
};

__global__ void cvt_fp4_to_fp8(uint32_t fp4_word, uint16_t scale_word,
                               Result *result) {
    const int i = threadIdx.x;
    if (i >= 8) {
        return;
    }

    const uint8_t fp4_bits = static_cast<uint8_t>((fp4_word >> (4 * i)) & 0xf);
    __nv_fp4_e2m1 fp4;
    fp4.__x = fp4_bits;

    __nv_fp8_e8m0 scale;
    scale.__x = static_cast<uint8_t>((scale_word >> (8 * (i / 4))) & 0xff);

    const float value = static_cast<float>(fp4) * static_cast<float>(scale);

    result->nibble[i] = fp4_bits;
    result->value[i] = value;
    result->e4m3[i] = __nv_fp8_e4m3(value).__x;
    result->e5m2[i] = __nv_fp8_e5m2(value).__x;
}

static void print_order(const char *name, const Result &r, bool high_to_low) {
    std::printf("%s\n", name);
    std::printf("idx  fp4  value  e4m3  e5m2\n");
    for (int row = 0; row < 8; ++row) {
        const int i = high_to_low ? (7 - row) : row;
        std::printf("%3d  0x%x  %5.1f  0x%02x  0x%02x\n", i, r.nibble[i],
                    r.value[i], r.e4m3[i], r.e5m2[i]);
    }

    std::printf("e4m3 bytes:");
    for (int row = 0; row < 8; ++row) {
        const int i = high_to_low ? (7 - row) : row;
        std::printf(" %02x", r.e4m3[i]);
    }
    std::printf("\n");

    std::printf("e5m2 bytes:");
    for (int row = 0; row < 8; ++row) {
        const int i = high_to_low ? (7 - row) : row;
        std::printf(" %02x", r.e5m2[i]);
    }
    std::printf("\n\n");
}

int main() {
    constexpr uint32_t fp4_word = 0x01234567u;
    constexpr uint16_t scale_word = 0x7F7Fu;

    Result *device_result = nullptr;
    cudaMalloc(&device_result, sizeof(Result));

    cvt_fp4_to_fp8<<<1, 8>>>(fp4_word, scale_word, device_result);
    cudaDeviceSynchronize();

    Result host_result{};
    cudaMemcpy(&host_result, device_result, sizeof(Result),
               cudaMemcpyDeviceToHost);
    cudaFree(device_result);

    std::printf("input fp4 word : 0x%08x\n", fp4_word);
    std::printf("scale word     : 0x%04x\n\n", scale_word);
    print_order("natural packed order, low nibble first", host_result, false);
    print_order("hex text order, high nibble first", host_result, true);
    return 0;
}
