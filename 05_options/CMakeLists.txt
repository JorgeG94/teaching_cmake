# =============================================================================
# Lesson 05: Options
# =============================================================================
# Options let users configure your project at build time.
# They can enable/disable features, choose backends, etc.
#
# Build instructions:
#   cmake -B build -DENABLE_DOUBLE_PRECISION=ON -DENABLE_OPENMP=ON
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(options_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Define options
# -----------------------------------------------------------------------------
# option(NAME "Description" DEFAULT_VALUE)
# Users can change with: cmake -DNAME=ON or cmake -DNAME=OFF

option(ENABLE_DOUBLE_PRECISION "Use double precision (real*8)" ON)
option(ENABLE_OPENMP "Enable OpenMP parallelization" OFF)
option(ENABLE_VERBOSE "Enable verbose output" OFF)
option(ENABLE_EXPERIMENTAL "Enable experimental features (use at own risk)" OFF)

# Mark some options as "advanced" (hidden in cmake-gui unless toggled)
mark_as_advanced(ENABLE_EXPERIMENTAL)

# -----------------------------------------------------------------------------
# Display current option values
# -----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "=== Build Options ===")
message(STATUS "ENABLE_DOUBLE_PRECISION: ${ENABLE_DOUBLE_PRECISION}")
message(STATUS "ENABLE_OPENMP:           ${ENABLE_OPENMP}")
message(STATUS "ENABLE_VERBOSE:          ${ENABLE_VERBOSE}")
message(STATUS "ENABLE_EXPERIMENTAL:     ${ENABLE_EXPERIMENTAL}")
message(STATUS "")

# -----------------------------------------------------------------------------
# Handle DOUBLE_PRECISION option
# -----------------------------------------------------------------------------
# Use target_compile_definitions() to pass preprocessor macros to Fortran

add_executable(demo main.F90)

if(ENABLE_DOUBLE_PRECISION)
    # This defines USE_DOUBLE_PRECISION as a preprocessor macro
    # In Fortran: #ifdef USE_DOUBLE_PRECISION
    target_compile_definitions(demo PRIVATE USE_DOUBLE_PRECISION)
    message(STATUS "Using double precision (real*8)")
else()
    message(STATUS "Using single precision (real*4)")
endif()

# -----------------------------------------------------------------------------
# Handle OPENMP option
# -----------------------------------------------------------------------------
if(ENABLE_OPENMP)
    # find_package() locates OpenMP on the system
    find_package(OpenMP COMPONENTS Fortran)

    if(OpenMP_Fortran_FOUND)
        # Link OpenMP to our target
        target_link_libraries(demo PRIVATE OpenMP::OpenMP_Fortran)
        target_compile_definitions(demo PRIVATE USE_OPENMP)
        message(STATUS "OpenMP found and enabled")
    else()
        message(WARNING "OpenMP requested but not found - disabling")
    endif()
endif()

# -----------------------------------------------------------------------------
# Handle VERBOSE option
# -----------------------------------------------------------------------------
if(ENABLE_VERBOSE)
    target_compile_definitions(demo PRIVATE VERBOSE_OUTPUT)
endif()

# -----------------------------------------------------------------------------
# Handle EXPERIMENTAL option
# -----------------------------------------------------------------------------
if(ENABLE_EXPERIMENTAL)
    message(WARNING "Experimental features enabled - may be unstable!")
    target_compile_definitions(demo PRIVATE EXPERIMENTAL_FEATURES)
endif()

# -----------------------------------------------------------------------------
# Dependent options (advanced)
# -----------------------------------------------------------------------------
# Sometimes options depend on other options. CMake provides cmake_dependent_option:
#
# include(CMakeDependentOption)
# cmake_dependent_option(
#     ENABLE_GPU_DOUBLE "Use double precision on GPU"
#     ON                    # Default value
#     "ENABLE_GPU"          # Only available when ENABLE_GPU is ON
#     OFF                   # Value when condition is not met
# )
