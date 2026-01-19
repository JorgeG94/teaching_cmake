# Lesson 06: find_package

Locate and use external libraries installed on your system.

## What You'll Learn
- `find_package()` - locate installed libraries
- Imported targets vs variables
- Required vs optional dependencies
- MODULE vs CONFIG mode
- Hinting package locations

## Build & Run

```bash
cmake -B build
cmake --build build
./build/demo

# If MPI is available, run with mpirun
mpirun -n 4 ./build/demo
```

## Key Concepts

### Basic Usage

```cmake
# Required dependency - fails if not found
find_package(BLAS REQUIRED)

# Optional dependency - continues if not found
find_package(MPI QUIET)
if(MPI_FOUND)
    # Use MPI
endif()

# With specific components
find_package(OpenMP COMPONENTS Fortran REQUIRED)
```

### Imported Targets vs Variables

**Modern approach (imported targets):**
```cmake
find_package(OpenMP COMPONENTS Fortran REQUIRED)
target_link_libraries(myapp PRIVATE OpenMP::OpenMP_Fortran)
```

**Legacy approach (variables):**
```cmake
find_package(BLAS REQUIRED)
target_link_libraries(myapp PRIVATE ${BLAS_LIBRARIES})
target_include_directories(myapp PRIVATE ${BLAS_INCLUDE_DIRS})
```

Prefer imported targets when available - they handle include paths, compile flags, and transitive dependencies automatically.

### Common Packages for Fortran/HPC

| Package | Components | Imported Target |
|---------|------------|-----------------|
| OpenMP | Fortran | `OpenMP::OpenMP_Fortran` |
| MPI | Fortran | `MPI::MPI_Fortran` |
| BLAS | - | `BLAS::BLAS` (CMake 3.18+) |
| LAPACK | - | `LAPACK::LAPACK` (CMake 3.18+) |

### Hinting Package Locations

If CMake can't find a package:

```bash
# General hint for all packages
cmake -B build -DCMAKE_PREFIX_PATH=/opt/mylibs

# Package-specific hint
cmake -B build -DBLAS_ROOT=/opt/openblas

# Environment variable
export CMAKE_PREFIX_PATH=/opt/mylibs
cmake -B build
```

### MODULE vs CONFIG Mode

**MODULE mode** (CMake's Find scripts):
```cmake
find_package(BLAS)  # Uses CMake's FindBLAS.cmake
```

**CONFIG mode** (library's own CMake files):
```cmake
find_package(jsonfortran CONFIG REQUIRED)  # Uses jsonfortranConfig.cmake
```

Libraries that provide good CMake support (like json-fortran, tblite, etc.) ship their own Config files. These are more reliable than Find modules.

## Package Variables

After `find_package(XXX)`, you typically get:

| Variable | Description |
|----------|-------------|
| `XXX_FOUND` | TRUE if found |
| `XXX_VERSION` | Version string |
| `XXX_LIBRARIES` | Libraries to link |
| `XXX_INCLUDE_DIRS` | Include directories |

## Next Steps
In Lesson 07, we'll use `FetchContent` to download dependencies automatically.
