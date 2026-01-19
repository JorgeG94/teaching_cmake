# Lesson 12: Per-File Compile Flags

Apply different compilation flags to specific source files.

## What You'll Learn
- `set_source_files_properties()` - override flags for specific files
- Compiler-specific workarounds
- The "defensive compilation" pattern
- Version-specific flag adjustments

## Build & Run

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -- VERBOSE=1  # See actual compile commands
./build/demo
```

## Key Concepts

### Basic Per-File Flags

```cmake
set_source_files_properties(
    src/problematic.f90
    PROPERTIES COMPILE_FLAGS "-O0"
)
```

### Multiple Files, Same Flags

```cmake
set_source_files_properties(
    src/file1.f90
    src/file2.f90
    src/file3.f90
    PROPERTIES COMPILE_FLAGS "-O1"
)
```

### Compiler-Specific Per-File Flags

```cmake
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set_source_files_properties(src/tricky.f90
        PROPERTIES COMPILE_FLAGS "-O0 -fno-tree-vectorize")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    set_source_files_properties(src/tricky.f90
        PROPERTIES COMPILE_FLAGS "-O0")
endif()
```

### The Defensive Compilation Pattern (GAMESS)

Real scientific codes often have files that produce wrong results with aggressive optimization:

```cmake
function(apply_defensive_compilation)
    if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
        # Files that fail with -O3 in gfortran
        set_source_files_properties(
            ${CMAKE_BINARY_DIR}/source/eigen.f
            ${CMAKE_BINARY_DIR}/source/guess.f
            PROPERTIES COMPILE_FLAGS "-O0"
        )

    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
        # NVHPC has different problem files
        set_source_files_properties(
            ${CMAKE_BINARY_DIR}/source/int2a.F
            PROPERTIES COMPILE_FLAGS "-O1 -Mnoautoinline"
        )
    endif()
endfunction()
```

### Version-Specific Workarounds

```cmake
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_Fortran_COMPILER_VERSION VERSION_LESS "10.0")
        # GCC 9 and earlier need this workaround
        set_source_files_properties(src/old_bug.f90
            PROPERTIES COMPILE_FLAGS "-O1")
    endif()
endif()

if(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
    if(CMAKE_Fortran_COMPILER_VERSION VERSION_LESS "25.0")
        # NVHPC < 25 has issues with certain files
        set_source_files_properties(src/nvhpc_bug.f90
            PROPERTIES COMPILE_FLAGS "-O0")
    endif()
endif()
```

### Inspecting Applied Flags

```cmake
get_source_file_property(flags src/file.f90 COMPILE_FLAGS)
message(STATUS "Flags for file.f90: ${flags}")
```

## When to Use Per-File Flags

1. **Compiler bugs** - Specific files trigger compiler bugs at high optimization
2. **Numerical precision** - Code is sensitive to floating-point optimization
3. **Legacy code** - Old code with undefined behavior exposed by optimization
4. **Build time** - Very large files that take too long to optimize

## Alternative: target_compile_options with Generator Expressions

For more complex scenarios:

```cmake
target_compile_options(mylib PRIVATE
    $<$<COMPILE_LANGUAGE:Fortran>:-O3>
)

# Then override specific files
set_source_files_properties(tricky.f90 PROPERTIES COMPILE_FLAGS "-O0")
```

## Debugging Compilation Issues

```bash
# See actual compile commands
cmake --build build -- VERBOSE=1

# Or with Ninja
cmake --build build -- -v
```

## Next Steps
In Lesson 13, we'll organize larger projects with subdirectories.
