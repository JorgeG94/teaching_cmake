# =============================================================================
# Lesson 12: Per-File Compile Flags
# =============================================================================
# Sometimes specific source files need different compilation settings.
# This is common in legacy codebases where certain files fail with high
# optimization levels (the "defensive compilation" pattern from GAMESS).
#
# Build:
#   cmake -B build -DCMAKE_BUILD_TYPE=Release
#   cmake --build build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(per_file_flags_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Global flags (applied to all files by default)
# -----------------------------------------------------------------------------
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -march=native")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" OR
       CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3 -xHost")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
    set(CMAKE_Fortran_FLAGS_RELEASE "-fast")
endif()

# -----------------------------------------------------------------------------
# Source files
# -----------------------------------------------------------------------------
set(SOURCES
    src/main.f90
    src/stable_code.f90
    src/problematic_code.f90
    src/another_problem.f90
)

add_executable(demo ${SOURCES})

# -----------------------------------------------------------------------------
# Per-file flags with set_source_files_properties()
# -----------------------------------------------------------------------------
# Override optimization for files that fail with -O3

# Single file
set_source_files_properties(
    src/problematic_code.f90
    PROPERTIES COMPILE_FLAGS "-O0"
)

# Multiple files with the same flags
set_source_files_properties(
    src/another_problem.f90
    PROPERTIES COMPILE_FLAGS "-O1"
)

# -----------------------------------------------------------------------------
# Compiler-specific per-file flags (GAMESS pattern)
# -----------------------------------------------------------------------------
# Different compilers may have different problematic files

function(apply_defensive_compilation)
    message(STATUS "Applying defensive compilation for ${CMAKE_Fortran_COMPILER_ID}")

    if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
        # GNU-specific workarounds
        set_source_files_properties(
            src/problematic_code.f90
            PROPERTIES COMPILE_FLAGS "-O0 -fno-tree-vectorize"
        )

    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" OR
           CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
        # Intel-specific workarounds
        set_source_files_properties(
            src/problematic_code.f90
            PROPERTIES COMPILE_FLAGS "-O0"
        )
        set_source_files_properties(
            src/another_problem.f90
            PROPERTIES COMPILE_FLAGS "-O1"
        )

    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
        # NVHPC-specific workarounds
        set_source_files_properties(
            src/problematic_code.f90
            PROPERTIES COMPILE_FLAGS "-O0 -Mnoautoinline"
        )
    endif()
endfunction()

# Apply the defensive compilation
apply_defensive_compilation()

# -----------------------------------------------------------------------------
# Advanced: Version-specific workarounds
# -----------------------------------------------------------------------------
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_Fortran_COMPILER_VERSION VERSION_LESS "10.0")
        message(STATUS "Applying workarounds for GCC < 10")
        # Older GCC versions might need additional flags
        set_source_files_properties(
            src/stable_code.f90
            PROPERTIES COMPILE_FLAGS "-O2"
        )
    endif()
endif()

# -----------------------------------------------------------------------------
# Checking what flags are applied (debugging)
# -----------------------------------------------------------------------------
# You can inspect the properties:
get_source_file_property(flags src/problematic_code.f90 COMPILE_FLAGS)
message(STATUS "problematic_code.f90 flags: ${flags}")

# -----------------------------------------------------------------------------
# Full example: GAMESS-style defensive compilation function
# -----------------------------------------------------------------------------
function(apply_full_defensive_compilation all_sources)
    # Define problem files for each compiler
    if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
        set(o0_files src/problematic_code.f90)
        set(o1_files src/another_problem.f90)
        set(o2_files "")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
        set(o0_files src/problematic_code.f90 src/another_problem.f90)
        set(o1_files "")
        set(o2_files "")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
        set(o0_files "")
        set(o1_files src/problematic_code.f90)
        set(o2_files src/another_problem.f90)
    else()
        return()  # Unknown compiler, skip
    endif()

    # Apply -O0 flags
    foreach(file IN LISTS o0_files)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
            set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "-O0")
            message(STATUS "  ${file} -> -O0")
        endif()
    endforeach()

    # Apply -O1 flags
    foreach(file IN LISTS o1_files)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
            set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "-O1")
            message(STATUS "  ${file} -> -O1")
        endif()
    endforeach()

    # Apply -O2 flags
    foreach(file IN LISTS o2_files)
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
            set_source_files_properties(${file} PROPERTIES COMPILE_FLAGS "-O2")
            message(STATUS "  ${file} -> -O2")
        endif()
    endforeach()
endfunction()
