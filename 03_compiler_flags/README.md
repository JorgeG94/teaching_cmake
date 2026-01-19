# Lesson 03: Compiler Flags

Handle multiple Fortran compilers and their different flag syntax.

## What You'll Learn
- `CMAKE_Fortran_COMPILER_ID` - detect which compiler is being used
- Setting flags per compiler (GNU, Intel, NVHPC, etc.)
- Global vs per-target flags
- `target_compile_options()` - apply flags to specific targets

## Common Compiler IDs
| Compiler | `CMAKE_Fortran_COMPILER_ID` |
|----------|------------------------------|
| gfortran | `GNU` |
| ifort (classic) | `Intel` |
| ifx (LLVM-based) | `IntelLLVM` |
| nvfortran | `NVHPC` |
| flang-new | `LLVMFlang` |
| Cray ftn | `Cray` |

## Build & Run

```bash
# Default (usually RelWithDebInfo or Debug)
cmake -B build
cmake --build build

# Explicit build type
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

## Key Concepts

### Global Flags vs Target Flags

**Global flags** (affect all targets):
```cmake
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Wall")
```

**Per-target flags** (preferred for libraries):
```cmake
target_compile_options(mylib PRIVATE -Wall -Wextra)
```

### Common Fortran Flags by Compiler

#### GNU (gfortran)
```
-ffree-line-length-none  # No line length limit
-fbacktrace              # Stack trace on crash
-fcheck=all              # Runtime checks (debug)
-ffpe-trap=invalid,zero  # Trap floating point errors
-march=native            # Optimize for current CPU
```

#### Intel (ifort/ifx)
```
-traceback               # Stack trace on crash
-check all               # Runtime checks (debug)
-fpe0                    # Trap floating point errors
-xHost                   # Optimize for current CPU
```

#### NVHPC (nvfortran)
```
-traceback               # Stack trace on crash
-Mbounds                 # Array bounds checking
-Mchkptr                 # Null pointer checking
-fast                    # Aggressive optimization
```

## Try It

Build with different compilers:
```bash
# With gfortran
FC=gfortran cmake -B build-gnu
cmake --build build-gnu

# With Intel
FC=ifx cmake -B build-intel
cmake --build build-intel
```

## Next Steps
In Lesson 04, we'll explore CMake build types (Debug, Release, etc.).
