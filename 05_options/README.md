# Lesson 05: Options

Add user-configurable options to control build features.

## What You'll Learn
- `option()` - define ON/OFF switches
- `target_compile_definitions()` - pass preprocessor macros
- `mark_as_advanced()` - hide rarely-used options
- Conditional logic based on options

## Build & Run

```bash
# Default options
cmake -B build
cmake --build build
./build/demo

# Enable OpenMP
cmake -B build-omp -DENABLE_OPENMP=ON
cmake --build build-omp
./build-omp/demo

# Single precision + verbose
cmake -B build-sp -DENABLE_DOUBLE_PRECISION=OFF -DENABLE_VERBOSE=ON
cmake --build build-sp
./build-sp/demo

# See all options
cmake -B build -LH
```

## Key Concepts

### Defining Options

```cmake
option(ENABLE_FEATURE "Description shown in cmake-gui" ON)
```

- First argument: option name (convention: `ENABLE_` or `WITH_` prefix)
- Second argument: description string
- Third argument: default value (`ON` or `OFF`)

### Using Options

```cmake
if(ENABLE_FEATURE)
    # Do something when feature is enabled
    target_compile_definitions(mytarget PRIVATE FEATURE_ENABLED)
endif()
```

### Passing to Fortran Code

CMake options become preprocessor definitions:

```cmake
target_compile_definitions(mytarget PRIVATE MY_FLAG)
```

In Fortran (requires preprocessing, `.F90` or `-cpp` flag):
```fortran
#ifdef MY_FLAG
    ! This code is compiled when MY_FLAG is defined
#endif
```

### Hiding Advanced Options

```cmake
mark_as_advanced(RARELY_USED_OPTION)
```

These options won't show in `cmake-gui` unless "Advanced" is checked.

### Dependent Options

Options that only make sense when another option is enabled:

```cmake
include(CMakeDependentOption)
cmake_dependent_option(
    ENABLE_GPU_DOUBLE "Use double precision on GPU"
    ON                    # Default value when visible
    "ENABLE_GPU"          # Condition to be visible
    OFF                   # Value when condition is false
)
```

## Option Naming Conventions

- `ENABLE_*` - toggle a feature on/off
- `WITH_*` - include an optional dependency
- `USE_*` - choose between alternatives
- `BUILD_*` - control what gets built
- `<PROJECT>_*` - prefix with project name to avoid conflicts

## Listing All Options

```bash
# List all cache variables (options)
cmake -B build -LH

# List only advanced options too
cmake -B build -LAH
```

## Next Steps
In Lesson 06, we'll use `find_package()` to locate external dependencies.
