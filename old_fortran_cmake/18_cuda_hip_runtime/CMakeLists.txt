# =============================================================================
# Lesson 18: Finding CUDA and HIP Runtimes
# =============================================================================
# This lesson demonstrates how to find and link CUDA or HIP runtimes for
# GPU-accelerated applications. This is the foundation for GPU programming
# before adding libraries like cuBLAS or hipBLAS.
#
# Build instructions:
#   # For CUDA (NVIDIA GPUs):
#   cmake -B build -DGPU_RUNTIME=CUDA
#
#   # For HIP (AMD GPUs):
#   cmake -B build -DGPU_RUNTIME=HIP
#
#   # CPU-only (no GPU):
#   cmake -B build
# =============================================================================

cmake_minimum_required(VERSION 3.22)
project(cuda_hip_demo LANGUAGES Fortran)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# -----------------------------------------------------------------------------
# GPU Runtime Selection
# -----------------------------------------------------------------------------
# Use a cache variable with predefined options for easy selection
set(GPU_RUNTIME "" CACHE STRING "Select GPU runtime: CUDA, HIP, or empty for CPU-only")
set_property(CACHE GPU_RUNTIME PROPERTY STRINGS "" "CUDA" "HIP")

# List to collect libraries we need to link
set(gpu_libraries)

# -----------------------------------------------------------------------------
# Handle CUDA Runtime
# -----------------------------------------------------------------------------
if(GPU_RUNTIME STREQUAL "CUDA")
    message(STATUS "Configuring with CUDA runtime")

    # Enable CUDA language support
    # This allows CMake to find CUDA compilers and set up the toolchain
    enable_language(CUDA)

    # Find the CUDA Toolkit
    # This provides targets like CUDA::cudart, CUDA::cublas, etc.
    find_package(CUDAToolkit REQUIRED)

    # Add preprocessor definition so Fortran code knows CUDA is available
    add_compile_definitions(USE_CUDA)

    # Link the CUDA runtime library
    list(APPEND gpu_libraries CUDA::cudart)

    message(STATUS "CUDA Toolkit version: ${CUDAToolkit_VERSION}")
    message(STATUS "CUDA include dirs: ${CUDAToolkit_INCLUDE_DIRS}")

# -----------------------------------------------------------------------------
# Handle HIP Runtime
# -----------------------------------------------------------------------------
elseif(GPU_RUNTIME STREQUAL "HIP")
    message(STATUS "Configuring with HIP runtime")

    # HIP requires C++ for some headers
    enable_language(CXX)

    # Enable HIP language support (CMake 3.21+)
    enable_language(HIP)

    # Find HIP package
    find_package(HIP REQUIRED)

    # Add preprocessor definition
    add_compile_definitions(USE_HIP)

    # Link the HIP host runtime
    list(APPEND gpu_libraries hip::host)

    message(STATUS "HIP version: ${HIP_VERSION}")

# -----------------------------------------------------------------------------
# CPU-only (no GPU)
# -----------------------------------------------------------------------------
else()
    message(STATUS "No GPU runtime selected - building CPU-only version")
    add_compile_definitions(CPU_ONLY)
endif()

# -----------------------------------------------------------------------------
# Display Configuration Summary
# -----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "=== GPU Configuration ===")
message(STATUS "GPU_RUNTIME: ${GPU_RUNTIME}")
if(gpu_libraries)
    message(STATUS "GPU libraries: ${gpu_libraries}")
endif()
message(STATUS "")

# -----------------------------------------------------------------------------
# Create targets
# -----------------------------------------------------------------------------
add_executable(demo main.F90)
target_link_libraries(demo PRIVATE ${gpu_libraries})

# -----------------------------------------------------------------------------
# Notes on GPU library targets
# -----------------------------------------------------------------------------
# CUDA Toolkit provides these imported targets (among others):
#   CUDA::cudart       - CUDA runtime library
#   CUDA::cuda_driver  - CUDA driver API
#   CUDA::cublas       - cuBLAS (add with find_package)
#   CUDA::cufft        - cuFFT
#   CUDA::cusolver     - cuSOLVER
#   CUDA::cusparse     - cuSPARSE
#
# HIP provides these imported targets:
#   hip::host          - HIP host runtime
#   hip::device        - HIP device runtime
#
# For HIP BLAS libraries, you need separate find_package calls:
#   find_package(hipblas REQUIRED)  -> provides hipblas::hipblas
#   find_package(rocblas REQUIRED)  -> provides rocblas::rocblas
