每一个 Streaming Multiprocessor (SM) 包含四个 Streaming Processors (SPs)，warp 和 Sps的对应关系猜测是SPs_id=warp_id % 4。


为验证这一映射关系，设计了一个基准测试,该测试在一个 SM 上同时让两个warp执行一系列融合乘加指令, 记为 Warp A 和 Warp B。
每次测试会调用 8 个warp，其中 6 个保持空闲，剩余两个warp(warp A 和 warp B)负责发出 FFMA 指令，并测量 FFMA 指令的吞吐量（以“十亿次浮点运算每秒”，GFLOPS 为单位）。

因为当所有 FFMA 指令被限制在一个Sps时性能会显著降低，从表可以看出，上述结论是正确的。

               | warpA_id = 0 | warpA_id = 1 | warpA_id = 2 | warpA_id = 3 |
----------------------------------------------------------------------------
warpB_id = 4   |     0.67     |     0.83     |     0.83     |     0.83     |
warpB_id = 5   |     0.83     |     0.67     |     0.83     |     0.83     |
warpB_id = 6   |     0.83     |     0.83     |     0.67     |     0.83     |
warpB_id = 7   |     0.83     |     0.83     |     0.83     |     0.67     |
