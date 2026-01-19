# =============================================================================
# Lesson 03: Compiler Flags
# =============================================================================
# Fortran has many compilers (gfortran, ifort, ifx, nvfortran, etc.)
# Each has different flags. This lesson shows how to detect the compiler
# and set appropriate flags.
#
# Build instructions:
#   cmake -B build
#   cmake --build build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(compiler_flags_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Detect and display compiler information
# -----------------------------------------------------------------------------
# CMake provides these variables after finding the Fortran compiler:
# - CMAKE_Fortran_COMPILER_ID: "GNU", "Intel", "IntelLLVM", "NVHPC", etc.
# - CMAKE_Fortran_COMPILER_VERSION: e.g., "11.4.0"
# - CMAKE_Fortran_COMPILER: full path to the compiler

message(STATUS "")
message(STATUS "=== Fortran Compiler Information ===")
message(STATUS "Compiler ID:      ${CMAKE_Fortran_COMPILER_ID}")
message(STATUS "Compiler Version: ${CMAKE_Fortran_COMPILER_VERSION}")
message(STATUS "Compiler Path:    ${CMAKE_Fortran_COMPILER}")
message(STATUS "")

# -----------------------------------------------------------------------------
# Set compiler-specific flags
# -----------------------------------------------------------------------------
# Use CMAKE_Fortran_COMPILER_ID to detect the compiler and set flags

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    # GCC/gfortran flags
    set(FORTRAN_FLAGS "-ffree-line-length-none -fbacktrace")
    set(FORTRAN_FLAGS_DEBUG "-fcheck=all -ffpe-trap=invalid,zero,overflow")
    set(FORTRAN_FLAGS_RELEASE "-march=native -O3")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    # Classic Intel Fortran (ifort) flags
    set(FORTRAN_FLAGS "-traceback")
    set(FORTRAN_FLAGS_DEBUG "-check all -fpe0")
    set(FORTRAN_FLAGS_RELEASE "-xHost -O3")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    # Intel LLVM Fortran (ifx) flags
    set(FORTRAN_FLAGS "-traceback")
    set(FORTRAN_FLAGS_DEBUG "-check all -fpe0")
    set(FORTRAN_FLAGS_RELEASE "-xHost -O3")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
    # NVIDIA HPC Fortran (nvfortran) flags
    set(FORTRAN_FLAGS "-traceback -Minfo=all")
    set(FORTRAN_FLAGS_DEBUG "-Mbounds -Mchkptr -Mchkstk")
    set(FORTRAN_FLAGS_RELEASE "-fast")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "LLVMFlang")
    # LLVM Flang (flang-new) flags - still maturing
    set(FORTRAN_FLAGS "")
    set(FORTRAN_FLAGS_DEBUG "")
    set(FORTRAN_FLAGS_RELEASE "-O3")

else()
    message(WARNING "Unknown Fortran compiler: ${CMAKE_Fortran_COMPILER_ID}")
    set(FORTRAN_FLAGS "")
    set(FORTRAN_FLAGS_DEBUG "")
    set(FORTRAN_FLAGS_RELEASE "")
endif()

# -----------------------------------------------------------------------------
# Apply flags globally (simple approach)
# -----------------------------------------------------------------------------
# CMAKE_Fortran_FLAGS applies to ALL Fortran targets in the project

set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${FORTRAN_FLAGS}")
set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} ${FORTRAN_FLAGS_DEBUG}")
set(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE} ${FORTRAN_FLAGS_RELEASE}")

# Display what we're using
message(STATUS "=== Flags Being Used ===")
message(STATUS "Base flags:    ${FORTRAN_FLAGS}")
message(STATUS "Debug flags:   ${FORTRAN_FLAGS_DEBUG}")
message(STATUS "Release flags: ${FORTRAN_FLAGS_RELEASE}")
message(STATUS "")

# -----------------------------------------------------------------------------
# Create a simple target to demonstrate
# -----------------------------------------------------------------------------
add_executable(demo main.f90)

# -----------------------------------------------------------------------------
# Alternative: Per-target flags (more control, better for libraries)
# -----------------------------------------------------------------------------
# Instead of modifying global CMAKE_Fortran_FLAGS, you can use:
#
#   target_compile_options(demo PRIVATE -Wall -Wextra)
#
# This only affects the "demo" target, not other targets in the project.
# Use this approach when building libraries that others will consume.
