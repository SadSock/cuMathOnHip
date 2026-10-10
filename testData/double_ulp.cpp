#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cmath>

union m64{
    uint64_t u64;
    int64_t s64;
    double f64;
};

int main(int argc, char* argv[]){

    FILE *maca_file = fopen("/home/xwu/hip.txt", "r");
    FILE *cuda_file = fopen("/home/xwu/cuda.txt", "r");
    FILE *data_file = fopen("/home/xwu/double.random.txt", "r");

    uint32_t batch = 100;
    uint32_t batchlength = 1024 * 1024;

    for (int j = 0; j < batch; j++) {
        for (int i = 0; i < batchlength; i++) {
            m64 mret;
            m64 cret;
            m64 data;
            fscanf(maca_file, "%lx", &mret.u64);
            fscanf(cuda_file, "%lx", &cret.u64);
            fscanf(data_file, "%lx", &data.u64);

            if(mret.u64==cret.u64)
                continue;

            float ulp = fabs(std::nexttoward(mret.f64, INFINITY) - mret.f64);
            //printf("ulp = %f\n",ulp);
            float num = fabs(mret.f64-cret.f64)/ulp;

            //double ulp = fabs(std::nexttoward(mret.f32, INFINITY) - mret.f32);
            //printf("ulp = %f\n",ulp);
            //double num = fabs((double)mret.f32-std::tgamma((double)data.f32))/ulp;

            //double ulp = fabs(std::nexttoward(cret.f32, INFINITY) - cret.f32);
            //printf("ulp = %f\n",ulp);
            //double num = fabs((double)cret.f32-std::tgamma((double)data.f32))/ulp;
            if(num - 3.0 > 0.0000001)
                printf("num = %lf data = %la maca = %la cuda = %la\n",num, data.f64, mret.f64, cret.f64);
            //input_x[i] = fabs(input_x[i]);
        }
    }

    return 0;
}
