#include <stdio.h>
#define VA (0x112)
#define VB (0xffffff11)
#define VC (0x556)

const int valAND  =((VA & VB));
const int valOR  =((VA | VB));
const int valTest  =((VA ^ VB));
__device__ int my_LOP_AND(int A, int B, int C){
  int temp;
  asm("lop3.b32 %0, %1, %2, %3, 0xc0;" : "=r"(temp) : "r"(A), "r"(B), "r"(C));
 // asm("lop3.b32 %0, %1, %2, %3, 0x80;" : "=r"(temp) : "r"(A), "r"(B), "r"(C));
  return temp;
}

__device__ int my_LOP_OR(int A, int B, int C){
  int temp;
  asm("lop3.b32 %0, %1, %2, %3, 0xfc;" : "=r"(temp) : "r"(A), "r"(B), "r"(C));
 // asm("lop3.b32 %0, %1, %2, %3, 0xfe;" : "=r"(temp) : "r"(A), "r"(B), "r"(C));
  return temp;
}

__device__ int my_LOP_Test(int A, int B, int C){
  int temp;
  asm("lop3.b32 %0, %1, %2, %3, 0x3c;" : "=r"(temp) : "r"(A), "r"(B), "r"(C));
  //asm("lop3.b32 %0, %1, %2, %3, 0x96;" : "=r"(temp) : "r"(A), "r"(B), "r"(C));
  return temp;
}

__global__ void testkernel(){
  printf("GPU: A: %x, B: %x, C: %x,  F=%x\n", VA, VB, VC, my_LOP_AND(VA, VB, VC));
  printf("GPU: A: %x, B: %x, C: %x,  F=%x\n", VA, VB, VC, my_LOP_OR(VA, VB, VC));
  printf("GPU: A: %x, B: %x, C: %x,  F=%x\n", VA, VB, VC, my_LOP_Test(VA, VB, VC));
}


void immLut()
{
	constexpr int ta = 0xF0;
    constexpr int tb = 0xCC;
    constexpr int tc = 0xAA;
	int immLut;
	immLut = (ta & tb);
	printf("a & b immLut:%x\n", immLut);
	immLut = (ta | tb);
	printf("a | b immLut:%x\n", immLut);
	immLut = (ta ^ tb);
	printf("a ^ b immLut:%x\n", immLut);

	immLut = (ta & tb & tc);
	printf("a & b & c immLut:%x\n", immLut);
	immLut = (ta | tb | tc);
	printf("a | b | c immLut:%x\n", immLut);
	immLut = (ta ^ tb ^ tc);
	printf("a ^ b ^ c immLut:%x\n", immLut);

	immLut = (ta | tb & tc);
	printf("a | b & c immLut:%x\n", immLut);
}

int main(){
  immLut();
  printf("CPU: A: %x, B: %x, C: %x,  F=%x\n", VA, VB, VC, valAND);
  printf("CPU: A: %x, B: %x, C: %x,  F=%x\n", VA, VB, VC, valOR);
  printf("CPU: A: %x, B: %x, C: %x,  F=%x\n", VA, VB, VC, valTest);
  testkernel<<<1,1>>>();
  cudaDeviceSynchronize();
}