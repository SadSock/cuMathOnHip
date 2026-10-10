# cuMathonHip

用于研究 NVIDIA CUDA 设备端数学函数，并在 HIP/ROCm 上复刻其可观测行为。

项目关注函数结果的位级一致性、舍入模式、NaN/Inf/非规格数等边界条件，以及生成这些结论所需的 CUDA PTX/SASS 证据；它不是通用数学库。

## 目录

- `cuda/`：CUDA 侧的探针、最小复现程序，以及 PTX/SASS/控制流图等逆向证据。
- `hip/`：基于 HIP/ROCm 的复刻实现与比较程序。
- `testData/`：随机输入生成与 ULP 比较工具。

各实验保持独立。部分旧程序仍有硬编码的数据文件路径，运行前需要显式提供相应输入；后续新增实验应将路径做成命令行参数或使用仓库内的固定回归数据。

## 构建探针

默认配置不要求 CUDA 或 HIP 工具链：

```sh
cmake -S . -B build
```

构建 CUDA 侧的无输入探针（默认架构为 `sm_75`，可通过 `CUMATHONHIP_CUDA_ARCHITECTURES` 覆盖）：

```sh
cmake -S . -B build/cuda -DCUMATHONHIP_BUILD_CUDA_PROBES=ON
cmake --build build/cuda --target cuda_exp_probe
```

构建一个 HIP 复刻验证探针：

```sh
cmake -S . -B build/hip \
  -DCUMATHONHIP_BUILD_HIP_PROBES=ON \
  -DCMAKE_HIP_COMPILER=/opt/rocm/llvm/bin/clang++ \
  -DCMAKE_HIP_ARCHITECTURES=gfx90a
cmake --build build/hip --target hip_expf_probe
```

原生 ROCm 主机可以让 CMake 自动发现 HIP 编译器和架构。无本地 AMD GPU 的 CI 或交叉编译环境应同时设置 `CMAKE_HIP_COMPILER`（通常为 ROCm 的 `clang++`，不是 `hipcc` 包装器）和 `CMAKE_HIP_ARCHITECTURES`（将示例中的 `gfx90a` 替换为目标 GPU 架构）；也可在 CMake toolchain 文件中设置这两个变量。CUDA 配置需要 `nvcc`。

## 许可证

本项目采用 [GNU GPL v3.0](LICENSE)。
