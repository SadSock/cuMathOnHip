__device__ int __hadd(int x, int y) {
  return (x & y) + ((x ^ y) >> 1);
}
