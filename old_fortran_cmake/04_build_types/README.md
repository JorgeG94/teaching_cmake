# Lesson 04: Build Types

Control optimization levels and debug information with CMake build types.

## What You'll Learn
- Built-in build types: Debug, Release, RelWithDebInfo, MinSizeRel
- Setting a default build type
- `CMAKE_Fortran_FLAGS_<CONFIG>` variables
- Creating custom build types (e.g., Coverage)

## Build Types Explained

| Build Type | Optimization | Debug Info | Use Case |
|------------|--------------|------------|----------|
| `Debug` | None (-O0) | Full | Development, debugging |
| `Release` | Full (-O3) | None | Production |
| `RelWithDebInfo` | Medium (-O2) | Full | Profiling, crash debugging |
| `MinSizeRel` | Size (-Os) | None | Embedded, size-constrained |

## Build & Run

```bash
# Debug build (slow, with checks)
cmake -B build-debug -DCMAKE_BUILD_TYPE=Debug
cmake --build build-debug
./build-debug/demo

# Release build (fast, no checks)
cmake -B build-release -DCMAKE_BUILD_TYPE=Release
cmake --build build-release
./build-release/demo

# Compare execution times!
time ./build-debug/demo
time ./build-release/demo
```

## Key Concepts

### Default Build Type
Without specifying a build type, CMake uses no flags! Always set a default:

```cmake
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type" FORCE)
    message(STATUS "Setting build type to '${CMAKE_BUILD_TYPE}' as none was specified.")
endif()
```

### Flag Variables
CMake appends build-type-specific flags automatically:

```cmake
# Always applied
CMAKE_Fortran_FLAGS

# Added based on CMAKE_BUILD_TYPE
CMAKE_Fortran_FLAGS_DEBUG
CMAKE_Fortran_FLAGS_RELEASE
CMAKE_Fortran_FLAGS_RELWITHDEBINFO
CMAKE_Fortran_FLAGS_MINSIZEREL
```

### Custom Build Types
You can create your own:

```cmake
set(CMAKE_Fortran_FLAGS_COVERAGE "-O0 -g --coverage"
    CACHE STRING "Flags for coverage builds")

# Use with: cmake -B build -DCMAKE_BUILD_TYPE=Coverage
```

### The NDEBUG Preprocessor Macro
By convention, Release builds define `NDEBUG`:
- Use `-DNDEBUG` flag in release configurations
- Check with `#ifdef NDEBUG` in Fortran preprocessor directives

## Multi-Config Generators
Some generators (Visual Studio, Xcode, Ninja Multi-Config) support multiple configurations in one build directory:

```bash
cmake -B build -G "Ninja Multi-Config"
cmake --build build --config Debug
cmake --build build --config Release
```

## Next Steps
In Lesson 05, we'll add user-configurable options to control build features.
