# =============================================================================
# Lesson 17: GPU Offloading with NVHPC
# =============================================================================
# This lesson demonstrates how to enable GPU offloading with the NVIDIA HPC
# compiler (nvfortran). Two approaches are covered:
#   1. OpenMP Offloading (-mp=gpu)
#   2. Do Concurrent with stdpar (-stdpar=multicore,gpu)
#
# Build instructions:
#   cmake -B build -DCMAKE_Fortran_COMPILER=nvfortran -DENABLE_GPU=ON
#   cmake -B build -DCMAKE_Fortran_COMPILER=nvfortran -DENABLE_GPU=ON -DGPU_ARCH=80
#   cmake -B build -DCMAKE_Fortran_COMPILER=nvfortran -DENABLE_DO_CONCURRENT=ON
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(gpu_offloading_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Options
# -----------------------------------------------------------------------------
option(ENABLE_GPU "Enable GPU offloading with OpenMP" OFF)
option(ENABLE_DO_CONCURRENT "Enable do concurrent parallelization with stdpar" OFF)

# GPU architecture - default to 70 (Volta/V100), common options:
#   70 = Volta (V100)
#   80 = Ampere (A100)
#   90 = Hopper (H100)
set(GPU_ARCH "70" CACHE STRING "NVIDIA GPU architecture (e.g., 70, 80, 90)")

# -----------------------------------------------------------------------------
# Validate compiler
# -----------------------------------------------------------------------------
# GPU offloading with these flags requires NVHPC
if(ENABLE_GPU OR ENABLE_DO_CONCURRENT)
    if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
        message(FATAL_ERROR
            "GPU offloading requires the NVHPC compiler (nvfortran).\n"
            "Detected compiler: ${CMAKE_Fortran_COMPILER_ID}\n"
            "Please configure with: -DCMAKE_Fortran_COMPILER=nvfortran")
    endif()
endif()

# -----------------------------------------------------------------------------
# Display configuration
# -----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "=== GPU Offloading Configuration ===")
message(STATUS "Compiler:            ${CMAKE_Fortran_COMPILER_ID}")
message(STATUS "ENABLE_GPU:          ${ENABLE_GPU}")
message(STATUS "ENABLE_DO_CONCURRENT: ${ENABLE_DO_CONCURRENT}")
message(STATUS "GPU_ARCH:            ${GPU_ARCH}")
message(STATUS "")

# -----------------------------------------------------------------------------
# Build GPU architecture flags
# -----------------------------------------------------------------------------
# NVHPC uses the format: -gpu=cc70 or -gpu=cc70,cc80 for multiple archs
# GPU_ARCH can be a single value "70" or multiple "70;80" (CMake list)

if(ENABLE_GPU OR ENABLE_DO_CONCURRENT)
    # Convert GPU_ARCH to a list if it contains semicolons
    string(REPLACE "," ";" GPU_ARCH_LIST "${GPU_ARCH}")

    # Build the architecture string for NVHPC: cc70,cc80,etc
    set(gpu_arch_flags "")
    foreach(arch IN LISTS GPU_ARCH_LIST)
        list(APPEND gpu_arch_flags "cc${arch}")
    endforeach()
    string(REPLACE ";" "," GPU_ARCH_STR "${gpu_arch_flags}")

    message(STATUS "GPU architecture flags: ${GPU_ARCH_STR}")
endif()

# -----------------------------------------------------------------------------
# Create target
# -----------------------------------------------------------------------------
add_executable(demo main.F90)

# -----------------------------------------------------------------------------
# Handle OpenMP GPU Offloading
# -----------------------------------------------------------------------------
if(ENABLE_GPU)
    # NVHPC OpenMP offload flags:
    #   -mp=gpu       : Enable OpenMP with GPU offloading
    #   -gpu=ccXX     : Target specific GPU architecture
    #   -Minfo=accel  : Show accelerator optimization info
    set(OMP_GPU_FLAGS -mp=gpu -gpu=${GPU_ARCH_STR} -Minfo=accel)

    message(STATUS "OpenMP GPU flags: ${OMP_GPU_FLAGS}")

    # Apply to target (both compile and link)
    target_compile_options(demo PRIVATE ${OMP_GPU_FLAGS})
    target_link_options(demo PRIVATE ${OMP_GPU_FLAGS})
    target_compile_definitions(demo PRIVATE USE_OMP_GPU)
endif()

# -----------------------------------------------------------------------------
# Handle Do Concurrent with stdpar
# -----------------------------------------------------------------------------
if(ENABLE_DO_CONCURRENT)
    # NVHPC stdpar flags:
    #   -stdpar=multicore,gpu : Enable stdpar for both CPU and GPU
    #   -gpu=ccXX             : Target specific GPU architecture
    #   -Minfo=accel          : Show accelerator optimization info
    #
    # Note: multicore,gpu means the runtime can choose where to execute
    # Use -stdpar=gpu for GPU-only execution
    set(STDPAR_FLAGS -stdpar=multicore,gpu -gpu=${GPU_ARCH_STR} -Minfo=accel)

    message(STATUS "Do Concurrent stdpar flags: ${STDPAR_FLAGS}")

    # Apply to target (both compile and link)
    target_compile_options(demo PRIVATE ${STDPAR_FLAGS})
    target_link_options(demo PRIVATE ${STDPAR_FLAGS})
    target_compile_definitions(demo PRIVATE USE_DO_CONCURRENT_GPU)
endif()

# -----------------------------------------------------------------------------
# Additional NVHPC GPU options (for reference)
# -----------------------------------------------------------------------------
# Other useful NVHPC GPU flags:
#   -gpu=managed      : Use CUDA managed memory (unified memory)
#   -gpu=pinned       : Use pinned host memory for faster transfers
#   -gpu=debug        : Enable GPU debugging
#   -gpu=lineinfo     : Include line info for profiling
#   -cuda             : Enable CUDA Fortran extensions
#   -acc              : Enable OpenACC (alternative to OpenMP offload)
#
# Example combining options:
#   set(GPU_FLAGS "-mp=gpu -gpu=${GPU_ARCH_STR},managed -Minfo=accel")
