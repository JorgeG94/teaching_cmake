# Lesson 08: Installing

Install your library and executables so others can use them.

## What You'll Learn
- `install()` - define what gets installed where
- `GNUInstallDirs` - standard installation directories
- Installing libraries, executables, and Fortran modules
- Setting the installation prefix

## Build & Install

```bash
# Configure with a custom install prefix
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local

# Build
cmake --build build

# Install
cmake --install build

# Run the installed executable
$HOME/.local/bin/calculator
```

## Key Concepts

### GNUInstallDirs

Include this module for standard directory variables:

```cmake
include(GNUInstallDirs)
```

| Variable | Default (Linux) | Description |
|----------|-----------------|-------------|
| `CMAKE_INSTALL_BINDIR` | `bin` | Executables |
| `CMAKE_INSTALL_LIBDIR` | `lib` or `lib64` | Libraries |
| `CMAKE_INSTALL_INCLUDEDIR` | `include` | Headers/modules |
| `CMAKE_INSTALL_DATADIR` | `share` | Data files |

### Installing Targets

```cmake
install(
    TARGETS mytarget
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}   # Static libs (.a)
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}   # Shared libs (.so)
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}   # Executables
)
```

### Installing Fortran Modules

Fortran `.mod` files are needed for compilation, similar to C++ headers:

```cmake
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/modules/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    FILES_MATCHING PATTERN "*.mod"
)
```

### Installation Prefix

```bash
# System-wide (requires sudo)
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr/local

# User-local (no sudo needed)
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local

# Project-specific
cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/myproject
```

### Directory Structure After Install

```
$PREFIX/
├── bin/
│   └── calculator           # Executable
├── lib/
│   └── libmathlib.a         # Static library
└── include/
    └── installing_demo/
        └── math_funcs.mod   # Fortran module
```

### Export Sets

For other CMake projects to use your library:

```cmake
install(
    TARGETS mathlib
    EXPORT mathlibTargets    # Creates an "export set"
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Install the export set as CMake files
install(
    EXPORT mathlibTargets
    FILE mathlibTargets.cmake
    NAMESPACE mathlib::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/mathlib
)
```

This is covered in detail in Lesson 09.

## Useful Commands

```bash
# Install to a staging directory (for packaging)
cmake --install build --prefix /tmp/staging

# Install only a specific component
cmake --install build --component Runtime

# Verbose install (see what's happening)
cmake --install build --verbose
```

## Next Steps
In Lesson 09, we'll make our library discoverable via `find_package()`.
