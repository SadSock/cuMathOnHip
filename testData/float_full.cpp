#include <climits>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <random>

int main(int argc, char *argv[]) {
        //freopen("/home/xwu/float.full.unary.txt", "w", stdout);
        FILE* pf = fopen("/home/xwu/float.full.bin","wb");
        for(uint32_t i = 0; i <= 0xffffffff; i++)
                fwrite(&i, sizeof(i), 1, pf);
}
