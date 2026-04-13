# =============================================================================
# Lesson 16: Fortran-C Interoperability
# =============================================================================
# This lesson demonstrates how to build mixed-language projects with CMake,
# using iso_c_binding to call C functions from Fortran.
#
# Build & Run:
#   cmake -B build
#   cmake --build build
#   ./build/c_fortran_demo
# =============================================================================

cmake_minimum_required(VERSION 3.18)

# -----------------------------------------------------------------------------
# Enable both C and Fortran languages
# -----------------------------------------------------------------------------
# CMake handles the compilers and linking automatically when you specify
# multiple languages. It will use the appropriate compiler for each file
# based on the file extension (.c -> C compiler, .f90 -> Fortran compiler).

project(c_fortran_interop
    VERSION 1.0.0
    LANGUAGES C Fortran
)

# -----------------------------------------------------------------------------
# C library
# -----------------------------------------------------------------------------
# Build the C code as a static library. CMake will use the C compiler
# for these files automatically.

add_library(c_math_utils STATIC
    src/c/math_utils.c
)

# Make the header available (optional, useful if C code uses it)
target_include_directories(c_math_utils PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/c
)

# -----------------------------------------------------------------------------
# Fortran interface library
# -----------------------------------------------------------------------------
# The Fortran module that provides iso_c_binding interfaces to the C library.
# This could be part of the main executable, but separating it makes the
# interface reusable.

add_library(fortran_c_interface STATIC
    src/fortran/c_math_interface.f90
)

# Link to the C library
target_link_libraries(fortran_c_interface PUBLIC c_math_utils)

# Put .mod files in a known location
set_target_properties(fortran_c_interface PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Main executable
# -----------------------------------------------------------------------------
add_executable(c_fortran_demo
    src/fortran/main.f90
)

target_link_libraries(c_fortran_demo PRIVATE fortran_c_interface)

# Need to find the .mod files
target_include_directories(c_fortran_demo PRIVATE
    ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "=== C-Fortran Interop Demo ===")
message(STATUS "C Compiler:       ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "Fortran Compiler: ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
message(STATUS "")
message(STATUS "Build with: cmake --build build")
message(STATUS "Run with:   ./build/c_fortran_demo")
message(STATUS "")
