每一个 Streaming Multiprocessor (SM) 包含四个 Streaming Processors (SPs)。我们推测 warp 会按照 `sp_id = warp_id % 4` 的方式被映射到 SPs 上。

为验证这一假设，构造了一个简单的基准：在单个 SM 内同时运行两个 warp（Warp A、Warp B），并让它们执行大量融合乘加 (FFMA) 指令。

每轮实验启动 8 个 warp，其中 6 个保持空闲，用于确保 Warp A 与 Warp B 一定驻留在同一 SM。通过变换它们的 warp_id 并测量 FFMA 吞吐量（GFLOPS），可以观察两者是否被调度到同一个 SP。

如果 Warp A 与 Warp B 被划分到同一个 SP，理论上吞吐量会下降，因为所有指令需在同一流水线排队。下表显示，当两者的 warp_id 对 4 取模相同（例如 A=0 与 B=4）时吞吐量跌至约 0.67 GFLOPS，而其余组合保持在 0.83 GFLOPS 左右，验证了上述映射关系。

               | warpA_id = 0 | warpA_id = 1 | warpA_id = 2 | warpA_id = 3 |
----------------------------------------------------------------------------
warpB_id = 4   |     0.67     |     0.83     |     0.83     |     0.83     |
warpB_id = 5   |     0.83     |     0.67     |     0.83     |     0.83     |
warpB_id = 6   |     0.83     |     0.83     |     0.67     |     0.83     |
warpB_id = 7   |     0.83     |     0.83     |     0.83     |     0.67     |
