#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cmath>

union b32{
    uint32_t u32;
    int32_t s32;
    float f32;
};

int main(int argc, char* argv[]){

    FILE *maca_file = fopen("/home/xwu/maca_tanhf.txt", "r");
    FILE *cuda_file = fopen("/home/xwu/cuda_tanhf.txt", "r");
    FILE *data_file = fopen("/home/xwu/float.random.unary.txt", "r");

    uint32_t batch = 100;
    uint32_t batchlength = 1024 * 1;

    for (int j = 0; j < batch; j++) {
        for (int i = 0; i < batchlength; i++) {
            b32 mret;
            b32 cret;
            b32 data;
            fscanf(maca_file, "%x", &mret.u32);
            fscanf(cuda_file, "%x", &cret.u32);
            fscanf(data_file, "%x", &data.u32);

            if(mret.u32==cret.u32)
                continue;

            float ulp = fabs(std::nexttoward(mret.f32, INFINITY) - mret.f32);
            //printf("ulp = %f\n",ulp);
            float num = fabs(mret.f32-cret.f32)/ulp;

            //double ulp = fabs(std::nexttoward(mret.f32, INFINITY) - mret.f32);
            //printf("ulp = %f\n",ulp);
            //double num = fabs((double)mret.f32-std::tgamma((double)data.f32))/ulp;

            //double ulp = fabs(std::nexttoward(cret.f32, INFINITY) - cret.f32);
            //printf("ulp = %f\n",ulp);
            //double num = fabs((double)cret.f32-std::tgamma((double)data.f32))/ulp;
            if(num - 1.0 > 0.0000001)
                printf("num = %f data = %a maca = %a cuda = %a libc = %la\n",num, data.f32, mret.f32, cret.f32, std::tanh((double)data.f32));
            //input_x[i] = fabs(input_x[i]);
        }
    }

    return 0;
}
