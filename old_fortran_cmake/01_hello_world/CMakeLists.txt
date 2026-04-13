# =============================================================================
# Lesson 01: Hello World - The Minimal Fortran CMake Project
# =============================================================================
# This is the simplest possible CMake configuration for a Fortran project.
# It compiles a single source file into an executable.
#
# Build instructions:
#   mkdir build && cd build
#   cmake ..
#   make
#   ./hello
# =============================================================================

# Minimum CMake version required. 3.18+ has good Fortran support.
cmake_minimum_required(VERSION 3.18)

# Define the project name and language(s)
# - The first argument is the project name
# - LANGUAGES specifies which compilers CMake should find
# - Fortran tells CMake to look for a Fortran compiler (gfortran, ifort, etc.)
project(hello_world LANGUAGES Fortran)

# Create an executable target named "hello" from the source file
# - First argument: the name of the executable (will create ./hello)
# - Second argument: the source file(s) to compile
add_executable(hello main.f90)

# That's it! CMake will:
# 1. Find a Fortran compiler on your system
# 2. Generate appropriate build files (Makefiles, Ninja files, etc.)
# 3. Compile main.f90 into an executable called "hello"
