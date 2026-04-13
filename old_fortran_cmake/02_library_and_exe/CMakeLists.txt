# =============================================================================
# Lesson 02: Library and Executable
# =============================================================================
# Most real projects have a library (reusable code) and an executable (the app).
# This lesson shows how to create both and link them together.
#
# Build instructions:
#   cmake -B build
#   cmake --build build
#   ./build/calculator
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(calculator LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Create a static library
# -----------------------------------------------------------------------------
# add_library() creates a library target
# - First argument: library name (will create libmathlib.a)
# - STATIC: creates a static library (.a file)
#   Other options: SHARED (.so), OBJECT (compiled but not archived)
# - Remaining arguments: source files
add_library(mathlib STATIC
    src/math_operations.f90
)

# -----------------------------------------------------------------------------
# Handle Fortran module files (.mod)
# -----------------------------------------------------------------------------
# Fortran compilers generate .mod files when compiling modules.
# We need to tell CMake where to put them and where to find them.

# Set where the .mod files will be written during compilation
set_target_properties(mathlib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Create the executable
# -----------------------------------------------------------------------------
add_executable(calculator app/main.f90)

# Tell the executable where to find the .mod files from the library
target_include_directories(calculator PRIVATE ${CMAKE_BINARY_DIR}/modules)

# Link the library to the executable
# - PRIVATE: the linkage is only for this target, not transitive
target_link_libraries(calculator PRIVATE mathlib)

# -----------------------------------------------------------------------------
# Summary of targets created:
# - mathlib: static library containing math_operations module
# - calculator: executable that uses the library
# -----------------------------------------------------------------------------
