# =============================================================================
# Lesson 14: CMake Presets
# =============================================================================
# CMakePresets.json provides a standardized way to configure builds.
# Users don't need to remember complex command-line options.
#
# Build with presets:
#   cmake --preset debug
#   cmake --build --preset debug
#   ctest --preset debug
#
# Or for release:
#   cmake --preset release
#   cmake --build --preset release
# =============================================================================

cmake_minimum_required(VERSION 3.21)  # Presets require 3.21+
project(presets_demo
    VERSION 1.0.0
    LANGUAGES Fortran
)

# Options that presets can control
option(ENABLE_OPENMP "Enable OpenMP" OFF)
option(ENABLE_ASSERTIONS "Enable runtime assertions" ON)
option(BUILD_TESTING "Build tests" ON)

# Compiler flags based on build type
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -ffree-line-length-none")
    set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -fcheck=all -fbacktrace")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -march=native")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" OR
       CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -traceback")
    set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -check all")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -xHost")
endif()

# Handle OpenMP
if(ENABLE_OPENMP)
    find_package(OpenMP COMPONENTS Fortran REQUIRED)
endif()

# Create library
add_library(mylib STATIC src/mylib.f90)
set_target_properties(mylib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

if(ENABLE_OPENMP)
    target_link_libraries(mylib PUBLIC OpenMP::OpenMP_Fortran)
    target_compile_definitions(mylib PRIVATE USE_OPENMP)
endif()

if(ENABLE_ASSERTIONS)
    target_compile_definitions(mylib PRIVATE ENABLE_ASSERTIONS)
endif()

# Create executable
add_executable(demo app/main.f90)
target_link_libraries(demo PRIVATE mylib)
target_include_directories(demo PRIVATE ${CMAKE_BINARY_DIR}/modules)

# Testing
if(BUILD_TESTING)
    enable_testing()
    add_executable(test_mylib test/test_mylib.f90)
    target_link_libraries(test_mylib PRIVATE mylib)
    target_include_directories(test_mylib PRIVATE ${CMAKE_BINARY_DIR}/modules)
    add_test(NAME mylib_tests COMMAND test_mylib)
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "=== Configuration ===")
message(STATUS "Build type:    ${CMAKE_BUILD_TYPE}")
message(STATUS "OpenMP:        ${ENABLE_OPENMP}")
message(STATUS "Assertions:    ${ENABLE_ASSERTIONS}")
message(STATUS "Testing:       ${BUILD_TESTING}")
message(STATUS "")
