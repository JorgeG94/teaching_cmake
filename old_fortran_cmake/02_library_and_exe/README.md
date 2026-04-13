# Lesson 02: Library and Executable

Create a static library and link it to an executable - the foundation of most projects.

## What You'll Learn
- `add_library()` - create a static/shared library
- `target_link_libraries()` - link libraries to targets
- `target_include_directories()` - specify include paths
- `Fortran_MODULE_DIRECTORY` - control where .mod files go

## Project Structure
```
02_library_and_exe/
├── CMakeLists.txt
├── src/
│   └── math_operations.f90   # Library source (module)
└── app/
    └── main.f90              # Executable source
```

## Build & Run

```bash
cmake -B build
cmake --build build
./build/calculator
```

## Key Concepts

### Fortran Module Files (.mod)
When you compile a Fortran `module`, the compiler generates a `.mod` file. Any code that `use`s that module needs to find the `.mod` file.

```cmake
# Tell CMake where to put .mod files
set_target_properties(mathlib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# Tell consuming targets where to find them
target_include_directories(calculator PRIVATE ${CMAKE_BINARY_DIR}/modules)
```

### Library Types
- `STATIC` - compiled into a `.a` archive, linked at compile time
- `SHARED` - compiled into a `.so`, linked at runtime (needs to be installed)
- `OBJECT` - compiled objects, not archived (used for internal organization)

### Link Visibility (PRIVATE/PUBLIC/INTERFACE)
- `PRIVATE` - only this target uses the dependency
- `PUBLIC` - this target and anything linking to it uses the dependency
- `INTERFACE` - only things linking to this target use the dependency

## Next Steps
In Lesson 03, we'll handle different Fortran compilers and their flags.
