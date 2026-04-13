# Lesson 01: Hello World

The absolute minimum CMake configuration for a Fortran project.

## What You'll Learn
- `cmake_minimum_required()` - specify minimum CMake version
- `project()` - define project name and languages
- `add_executable()` - create an executable from source files

## Files
- `CMakeLists.txt` - the CMake configuration
- `main.f90` - a simple Fortran program

## Build & Run

```bash
# Create a build directory (out-of-source build)
mkdir build && cd build

# Configure the project (generates Makefiles)
cmake ..

# Build the executable
make

# Run it
./hello
```

## Key Concepts

### Out-of-Source Builds
Always build in a separate directory (`build/`). This keeps your source tree clean and makes it easy to start fresh by deleting the build directory.

### The Three-Step Process
1. **Configure**: `cmake ..` - CMake reads CMakeLists.txt and generates build files
2. **Build**: `make` - The build system compiles your code
3. **Run**: `./hello` - Execute your program

## Next Steps
In Lesson 02, we'll create a library and link it to an executable.
