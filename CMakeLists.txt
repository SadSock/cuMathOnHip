cmake_minimum_required(VERSION 3.25)

project(cuMathonHip LANGUAGES CXX)

set(
  CUMATHONHIP_CUDA_ARCHITECTURES
  "75"
  CACHE STRING
  "CUDA architectures used to compile CUDA probe targets"
)

option(
  CUMATHONHIP_BUILD_CUDA_PROBES
  "Build CUDA programs used to observe device math behavior"
  OFF
)
option(
  CUMATHONHIP_BUILD_HIP_PROBES
  "Build HIP programs used to validate reconstructed implementations"
  OFF
)

function(cumathonhip_add_cuda_probe target source)
  add_executable("${target}" "${source}")
  set_target_properties(
    "${target}"
    PROPERTIES CUDA_ARCHITECTURES "${CUMATHONHIP_CUDA_ARCHITECTURES}"
  )
endfunction()

if(CUMATHONHIP_BUILD_CUDA_PROBES)
  include(CheckLanguage)
  check_language(CUDA)
  if(NOT CMAKE_CUDA_COMPILER)
    message(FATAL_ERROR "CUMATHONHIP_BUILD_CUDA_PROBES requires an nvcc CUDA compiler.")
  endif()

  enable_language(CUDA)

  cumathonhip_add_cuda_probe(cuda_exp_probe cuda/exp/crack_exp.cu)
  cumathonhip_add_cuda_probe(cuda_expf_probe cuda/expf/crack_expf.cu)
  cumathonhip_add_cuda_probe(cuda_log_probe cuda/log/crack_log.cu)
  cumathonhip_add_cuda_probe(cuda_logf_probe cuda/logf/crack_logf.cu)
  cumathonhip_add_cuda_probe(cuda_tanhf_probe cuda/tanhf/crack_ftanh.cu)
  cumathonhip_add_cuda_probe(cuda_tgamma_probe cuda/tgamma/crack_tgamma.cu)
endif()

if(CUMATHONHIP_BUILD_HIP_PROBES)
  if(CMAKE_HIP_COMPILER OR CMAKE_HIP_ARCHITECTURES)
    enable_language(HIP)
  else()
    include(CheckLanguage)
    check_language(HIP)
    if(NOT CMAKE_HIP_COMPILER)
      message(
        FATAL_ERROR
        "CUMATHONHIP_BUILD_HIP_PROBES requires a ROCm/HIP compiler. "
        "On GPU-less or cross-compiling hosts, set both "
        "-DCMAKE_HIP_COMPILER=<ROCm clang++> and "
        "-DCMAKE_HIP_ARCHITECTURES=<target architecture>."
      )
    endif()

    enable_language(HIP)
  endif()

  add_executable(hip_expf_probe hip/expf/test.unary.expf.cpp)
  set_source_files_properties(
    hip/expf/test.unary.expf.cpp
    PROPERTIES LANGUAGE HIP
  )
endif()
