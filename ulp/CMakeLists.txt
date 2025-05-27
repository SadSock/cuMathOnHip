cmake_minimum_required(VERSION 3.31)
project(ulp LANGUAGES CUDA CXX)

# 设置CUDA架构（自动检测或手动指定）
set(CMAKE_CUDA_ARCHITECTURES "native")

# 定义要构建的CUDA文件列表
set(CUDA_SOURCES
    rcp.f32.cu
    # sin.f32.cu
)

add_executable(rcp.f32 rcp.f32.cu)
# add_executable(sin.f32 sin.f32.cu)
