# CMake for Fortran Projects

A progressive tutorial on using CMake for Fortran projects, from basics to advanced patterns used in production codebases like GAMESS and metalquicha.

## Lessons

| # | Topic | Description |
|---|-------|-------------|
| 01 | [Hello World](01_hello_world/) | Minimal CMake project - `project()`, `add_executable()` |
| 02 | [Library and Executable](02_library_and_exe/) | Create libraries, link them, handle Fortran modules |
| 03 | [Compiler Flags](03_compiler_flags/) | Detect compilers, set appropriate flags |
| 04 | [Build Types](04_build_types/) | Debug, Release, RelWithDebInfo configurations |
| 05 | [Options](05_options/) | User-configurable build options |
| 06 | [find_package](06_find_package/) | Locate system libraries (BLAS, LAPACK, MPI, OpenMP) |
| 07 | [FetchContent](07_fetchcontent/) | Download and build dependencies automatically |
| 08 | [Installing](08_installing/) | Install libraries, executables, and modules |
| 09 | [Making Findable](09_making_findable/) | Create Config.cmake for `find_package()` support |
| 10 | [Testing](10_testing/) | CTest integration and test-drive framework |
| 11 | [Custom Commands](11_custom_commands/) | Run external scripts, process source files |
| 12 | [Per-File Flags](12_per_file_flags/) | Defensive compilation, file-specific settings |
| 13 | [Subdirectories](13_subdirectories/) | Organize large projects with `add_subdirectory()` |
| 14 | [CMake Presets](14_presets/) | Standardized build configurations |
| 15 | [test-drive + CTest](15_test_drive/) | Comprehensive unit testing with test-drive |
| 16 | [C-Fortran Interop](16_c_fortran_interop/) | `iso_c_binding`, mixed-language projects |

## Quick Start

Each lesson is self-contained. Navigate to a lesson directory and follow its README:

```bash
cd 01_hello_world
cmake -B build
cmake --build build
./build/hello
```

## Prerequisites

- CMake 3.18+ (3.21+ for presets)
- A Fortran compiler (gfortran, ifort, ifx, nvfortran, etc.)
- Basic command line familiarity

## Suggested Path

1. **Beginners**: Start at Lesson 01, work through sequentially
2. **Know basics**: Skip to Lesson 06 (dependencies)
3. **Library authors**: Focus on Lessons 08-09 (installing/findable)
4. **CI/CD setup**: Jump to Lesson 14 (presets)

## Key Takeaways

### Essential Commands
```bash
cmake -B build                    # Configure
cmake --build build               # Build
ctest --test-dir build            # Test
cmake --install build             # Install
cmake --preset debug              # Use presets
```

### Essential CMake for Fortran
```cmake
# Create library with module support
add_library(mylib STATIC src/module.f90)
set_target_properties(mylib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

# Link library to executable
add_executable(myapp app/main.f90)
target_link_libraries(myapp PRIVATE mylib)
target_include_directories(myapp PRIVATE ${CMAKE_BINARY_DIR}/modules)
```

### Compiler Detection
```cmake
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    # gfortran flags
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    # ifort flags
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    # ifx flags
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "NVHPC")
    # nvfortran flags
endif()
```

## Real-World Examples

These lessons are based on patterns from:
- **metalquicha** - Fragmentation quantum chemistry
- **GAMESS** - General Atomic and Molecular Electronic Structure System

See the metalquicha CMakeLists.txt for a complete production example.

## Contributing

Found an error or want to add a lesson? Contributions welcome!
