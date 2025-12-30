fma.mad.biwarp.cu

在同一个warp中交替发射fma 和 mad，测试同一个warp中fma 和 mad 是否可以coissue。 在5070ti上的测试表面，fma + mad 需要大约 3 cycle，也就是说不能coissue。
