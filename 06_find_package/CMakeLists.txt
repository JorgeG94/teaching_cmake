# =============================================================================
# Lesson 06: find_package
# =============================================================================
# find_package() locates external libraries installed on your system.
# This is how you use dependencies like BLAS, LAPACK, MPI, OpenMP, etc.
#
# Build instructions:
#   cmake -B build
#   cmake --build build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(find_package_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Finding OpenMP (commonly used in HPC)
# -----------------------------------------------------------------------------
# find_package(NAME [REQUIRED] [COMPONENTS ...])
# - REQUIRED: fail if not found
# - COMPONENTS: specify which parts you need

find_package(OpenMP COMPONENTS Fortran REQUIRED)

# After a successful find_package, you typically get:
# - <NAME>_FOUND: TRUE if found
# - Imported target(s): OpenMP::OpenMP_Fortran

message(STATUS "OpenMP_Fortran_FOUND: ${OpenMP_Fortran_FOUND}")
message(STATUS "OpenMP_Fortran_FLAGS: ${OpenMP_Fortran_FLAGS}")

# -----------------------------------------------------------------------------
# Finding BLAS/LAPACK (essential for scientific computing)
# -----------------------------------------------------------------------------
# BLAS and LAPACK have multiple implementations (OpenBLAS, MKL, Apple, etc.)
# CMake's find modules abstract away the differences.

find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

message(STATUS "BLAS_FOUND: ${BLAS_FOUND}")
message(STATUS "BLAS_LIBRARIES: ${BLAS_LIBRARIES}")
message(STATUS "LAPACK_FOUND: ${LAPACK_FOUND}")
message(STATUS "LAPACK_LIBRARIES: ${LAPACK_LIBRARIES}")

# -----------------------------------------------------------------------------
# Finding MPI (optional, for parallel computing)
# -----------------------------------------------------------------------------
# Use QUIET to suppress warnings if not found
# Check _FOUND to see if it was successful

find_package(MPI COMPONENTS Fortran QUIET)

if(MPI_Fortran_FOUND)
    message(STATUS "MPI found!")
    message(STATUS "  MPI_Fortran_COMPILER: ${MPI_Fortran_COMPILER}")
    message(STATUS "  MPI_Fortran_VERSION:  ${MPI_Fortran_VERSION}")
else()
    message(STATUS "MPI not found (optional, skipping)")
endif()

# -----------------------------------------------------------------------------
# Create the executable
# -----------------------------------------------------------------------------
add_executable(demo main.f90)

# Link the found packages
# Modern CMake provides "imported targets" - use these when available!
target_link_libraries(demo PRIVATE
    OpenMP::OpenMP_Fortran  # Imported target (preferred)
    ${BLAS_LIBRARIES}       # Variable (older style)
    ${LAPACK_LIBRARIES}     # Variable (older style)
)

# Conditionally link MPI if found
if(MPI_Fortran_FOUND)
    target_link_libraries(demo PRIVATE MPI::MPI_Fortran)
    target_compile_definitions(demo PRIVATE USE_MPI)
endif()

# -----------------------------------------------------------------------------
# Specifying where to find packages
# -----------------------------------------------------------------------------
# If a package isn't found automatically, you can hint where to look:
#
#   cmake -B build -DCMAKE_PREFIX_PATH=/path/to/installed/libs
#
# Or for specific packages:
#   cmake -B build -DBLAS_ROOT=/opt/openblas
#   cmake -B build -DOpenMP_ROOT=/opt/llvm
#
# You can also set these in the environment:
#   export CMAKE_PREFIX_PATH=/opt/mylibs

# -----------------------------------------------------------------------------
# MODULE vs CONFIG mode
# -----------------------------------------------------------------------------
# find_package has two modes:
#
# 1. MODULE mode (default first attempt):
#    - Uses FindXXX.cmake scripts (shipped with CMake or your project)
#    - Good for system libraries (BLAS, LAPACK, OpenMP, MPI)
#
# 2. CONFIG mode:
#    - Uses XXXConfig.cmake shipped WITH the library
#    - Better for libraries that provide CMake support
#    - Explicitly request: find_package(XXX CONFIG REQUIRED)
#
# Example for a library like json-fortran that provides Config files:
#   find_package(jsonfortran CONFIG REQUIRED)
