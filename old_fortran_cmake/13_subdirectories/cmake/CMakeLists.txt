# =============================================================================
# cmake/CMakeLists.txt - Compiler Configuration
# =============================================================================
# This subdirectory sets up compiler flags and build options.
# It's processed first, so these settings apply to all other subdirectories.
# =============================================================================

# Set default build type
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type" FORCE)
endif()

# Compiler-specific flags
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

# Propagate flags to parent scope (the root CMakeLists.txt)
# This is needed because variables set here are local to this scope
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}" PARENT_SCOPE)
set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}" PARENT_SCOPE)
set(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}" PARENT_SCOPE)

message(STATUS "Compiler: ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
