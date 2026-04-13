# Lesson 09: Making Your Library Findable

Enable other projects to use your library with `find_package()`.

## What You'll Learn
- Creating `Config.cmake.in` templates
- `configure_package_config_file()` - generate config files
- `write_basic_package_version_file()` - version compatibility
- Export sets and namespaced targets
- Generator expressions for build/install interfaces

## The Goal

After installing your library, other projects can do:

```cmake
find_package(mathlib 2.0 REQUIRED)
target_link_libraries(myapp PRIVATE mathlib::mathlib)
```

## Build & Install

```bash
# Install the library
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local
cmake --build build
cmake --install build

# Now test it from a consumer project
cd consumer
cmake -B build -DCMAKE_PREFIX_PATH=$HOME/.local
cmake --build build
./build/app
```

## Key Concepts

### The Three Config Files

After installation, you have:

```
$PREFIX/lib/cmake/mathlib/
├── mathlibConfig.cmake         # Main file (find_package loads this)
├── mathlibConfigVersion.cmake  # Version compatibility info
└── mathlibTargets.cmake        # Defines mathlib::mathlib target
```

### Creating the Config File

**Template (cmake/mathlibConfig.cmake.in):**
```cmake
@PACKAGE_INIT@
include("${CMAKE_CURRENT_LIST_DIR}/mathlibTargets.cmake")
check_required_components(mathlib)
```

**In CMakeLists.txt:**
```cmake
configure_package_config_file(
    "cmake/mathlibConfig.cmake.in"
    "${CMAKE_BINARY_DIR}/mathlibConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mathlib
)
```

### Version Compatibility

```cmake
write_basic_package_version_file(
    "mathlibConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
```

Compatibility options:
- `AnyNewerVersion` - 1.0 works for 0.9, 1.0, 2.0, etc.
- `SameMajorVersion` - 1.x works for 1.0-1.99, not 2.0
- `SameMinorVersion` - 1.2.x works for 1.2.0-1.2.99
- `ExactVersion` - only exact match

### Generator Expressions

Handle paths that differ between build and install:

```cmake
target_include_directories(mathlib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/mathlib>
)
```

- `BUILD_INTERFACE` - used when building this project
- `INSTALL_INTERFACE` - used when consuming the installed package

### Handling Dependencies

If your library depends on others, find them in Config.cmake.in:

```cmake
@PACKAGE_INIT@

include(CMakeFindDependencyMacro)
find_dependency(OpenMP COMPONENTS Fortran)
find_dependency(BLAS)

include("${CMAKE_CURRENT_LIST_DIR}/mathlibTargets.cmake")
check_required_components(mathlib)
```

`find_dependency()` propagates REQUIRED/QUIET from the original call.

### Namespaced Targets

Always use namespaced targets (`mathlib::mathlib`):

```cmake
# Create alias for use within the project
add_library(mathlib::mathlib ALIAS mathlib)

# Export with namespace
install(EXPORT mathlibTargets
    NAMESPACE mathlib::
    ...
)
```

Benefits:
- Clear that it's an imported target
- Consistent whether using FetchContent, find_package, or add_subdirectory
- CMake errors if target doesn't exist (instead of silently failing)

## Testing Your Config

Create a simple consumer project:

```cmake
# consumer/CMakeLists.txt
cmake_minimum_required(VERSION 3.18)
project(consumer LANGUAGES Fortran)

find_package(mathlib 2.0 REQUIRED)

add_executable(app main.f90)
target_link_libraries(app PRIVATE mathlib::mathlib)
```

## Next Steps
In Lesson 10, we'll add testing with test-drive.
