# =============================================================================
# Lesson 04: Build Types
# =============================================================================
# CMake has built-in build types that control optimization and debug info:
# - Debug: no optimization, full debug info
# - Release: full optimization, no debug info
# - RelWithDebInfo: optimization + debug info (good default)
# - MinSizeRel: optimize for size
#
# Build instructions:
#   cmake -B build -DCMAKE_BUILD_TYPE=Debug
#   cmake -B build -DCMAKE_BUILD_TYPE=Release
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(build_types_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Set a default build type if none was specified
# -----------------------------------------------------------------------------
# This is important! Without this, single-config generators (like Make)
# will have no optimization flags at all.

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type" FORCE)
    message(STATUS "Setting build type to '${CMAKE_BUILD_TYPE}' as none was specified.")
endif()

# Show which build type is being used
message(STATUS "")
message(STATUS "=== Build Configuration ===")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "")

# -----------------------------------------------------------------------------
# Compiler-specific flags for each build type
# -----------------------------------------------------------------------------
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_Fortran_FLAGS "-ffree-line-length-none")
    set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -march=native -DNDEBUG")
    set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
    set(CMAKE_Fortran_FLAGS_MINSIZEREL "-Os -DNDEBUG")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" OR CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    set(CMAKE_Fortran_FLAGS "-traceback")
    set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -check all -fpe0")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -xHost -DNDEBUG")
    set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
    set(CMAKE_Fortran_FLAGS_MINSIZEREL "-O1 -DNDEBUG")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
    set(CMAKE_Fortran_FLAGS "-traceback")
    set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -Mbounds -Mchkptr")
    set(CMAKE_Fortran_FLAGS_RELEASE "-fast -DNDEBUG")
    set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
    set(CMAKE_Fortran_FLAGS_MINSIZEREL "-O1 -DNDEBUG")
endif()

# Display the flags that will be used
message(STATUS "=== Flags for ${CMAKE_BUILD_TYPE} ===")
message(STATUS "Base flags:       ${CMAKE_Fortran_FLAGS}")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Build type flags: ${CMAKE_Fortran_FLAGS_DEBUG}")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    message(STATUS "Build type flags: ${CMAKE_Fortran_FLAGS_RELEASE}")
elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    message(STATUS "Build type flags: ${CMAKE_Fortran_FLAGS_RELWITHDEBINFO}")
elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    message(STATUS "Build type flags: ${CMAKE_Fortran_FLAGS_MINSIZEREL}")
endif()
message(STATUS "")

# -----------------------------------------------------------------------------
# Create the executable
# -----------------------------------------------------------------------------
add_executable(demo main.F90)

# -----------------------------------------------------------------------------
# Custom build type example: Coverage
# -----------------------------------------------------------------------------
# You can define your own build types!
# This is useful for special configurations like code coverage.

set(CMAKE_Fortran_FLAGS_COVERAGE "-O0 -g --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags for coverage builds")

# Mark it as an advanced option (hidden in cmake-gui by default)
mark_as_advanced(CMAKE_Fortran_FLAGS_COVERAGE)

# If using Coverage build type, you might want to add a custom target
if(CMAKE_BUILD_TYPE STREQUAL "Coverage")
    message(STATUS "Coverage build enabled - use 'make coverage' after running tests")
endif()
