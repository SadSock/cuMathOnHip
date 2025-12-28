## 项目概览

本仓库包含一组用于测量 NVIDIA Blackwell（`sm_120`）架构上 FMA/FADD 指令延迟的 CUDA 微基准。核函数通过 `clock64` 直接统计周期数，并结合批量迭代方式（`batch` × `ITER`）稳定输出，从而分析寄存器读写冲突对单精度运算的影响。

- 所有内核都会先在共享内存中准备批量输入，并在同一个 Streaming Processor (SP) 上发射多条 FMA/FADD 指令。
- 测试前可进行长时间预热，以确保 SM 频率稳定，减少动态调频造成的噪声。
- 主机端会收集每个 warp 的开始/结束时间，并输出平均延迟。

## 构建与运行

```bash
make            # 编译所有基准程序并导出对应的 SASS
./fma.quadwarp.out
./fma.uniwarp.out
./fmac.uniwarp.out
./fadd.quadwarp.out
```

若只需单个基准，可直接运行 `make fma_uniwarp` 等目标。生成的 `.sass` 便于核对指令调度和寄存器分配。

## 各基准的作用与观测

- `fma.quadwarp.cu`：在同一个 SP 上同时运行 4 个 warp，以高压力触发寄存器银行冲突。实测平均延迟约 **1.5 cycle**，证明 `sm_120` 的 2R1W 寄存器文件在 `%4` 编号重合时需要额外一个周期。
- `fma.uniwarp.cu`：同一 SP 仅运行 1 个 warp，仍能观测到约 **1.5 cycle** 的延迟，说明即使在低占用下，寄存器冲突依旧是瓶颈。
- `fmac.uniwarp.cu`：将一个操作数替换为常量，仅依赖两个寄存器，平均延迟降至约 **1 cycle**，验证了寄存器读端口压力降低的收益。
- `fadd.quadwarp.cu`：对 FADD 指令进行同样的常量化处理，平均延迟同样接近 **1 cycle**，对比 FMA 结果说明加法单元在这种配置下几乎不受冲突影响。

这些基准可作为进一步分析 `sm_120` 指令调度、寄存器银行设计或手写 PTX/SASS 时延选择的参考。
