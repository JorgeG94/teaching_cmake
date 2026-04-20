# Modern CMake for Scientific Computing in 2026

## A Practical Guide to Building, Installing, and Sharing Scientific Software

---

## A Hitchhiker's Guide to Migrating from Make to CMake 

- Jorge Luis Galvez Vallejo 
  - NCI

---

## About This Class

- Duration: ~2 hours
- Target audience: Scientists and engineers writing C, C++, and Fortran code that use Make as a build system or are starting to explore CMake
- Goal: Understand the basics of CMake and how it compiles, installs, and creates dependencies for other programs. 
        - Understand how to drive an effective migration from Make to CMake
- Bonus: LLM-powered skills to automate CMake scaffolding

---

# Part I: Foundations

## What Is a Build System?

### What Is a Build System?

A build system automates the process of turning source code into runnable software. At its core, it answers three questions:

1. **What** needs to be compiled? (which source files, in which order)
2. **How** should it be compiled? (which compiler, which flags, which standards)
3. **Where** do the results go? (executables, libraries, install locations)

---

### Without a build system

We have two small scientific projects that we will use as running examples throughout this tutorial. Let's see how they are built today.

**C project: 2D heat diffusion** (`compile.sh`)

```bash
#!/bin/bash
CC=gcc
CFLAGS="-O2 -Wall -I./include"

echo "Compiling heatmap library..."
$CC $CFLAGS -c src/heatmap.c -o heatmap.o

echo "Compiling main program..."
$CC $CFLAGS -c src/main.c -o main.o

echo "Linking..."
$CC heatmap.o main.o -lm -o heatmap_sim
```

Problems: no incremental builds (change one file, recompile everything), hardcoded compiler, no way to install, no way for another project to use `heatmap` as a library.

---

### Without a build system (cont.)

**Fortran project: 1D wave equation** (`Makefile`)

```makefile
FC = gfortran
FFLAGS = -O2 -Wall -Wextra

# Object files (ORDER MATTERS - wave_solver.f90 must compile first
# because main.f90 uses the module.) 
OBJS = wave_solver.o main.o

wave_sim: $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

wave_solver.o: src/wave_solver.f90
	$(FC) $(FFLAGS) -c $< -o $@

main.o: src/main.f90 wave_solver.o
	$(FC) $(FFLAGS) -c $< -o $@

clean:
	rm -f *.o *.mod wave_sim
```

Better than a shell script --- Make tracks dependencies and does incremental builds. But: you manually manage Fortran module ordering, the compiler is hardcoded, there is no install target, and no other project can consume `wave_solver` as a dependency. Add a third `.f90` file that uses the module and you must update the Makefile by hand.

Both projects work on the developer's machine. Neither is portable, installable, or consumable.

---

### With a build system

The build system tracks dependencies between files, recompiles only what changed, handles compiler detection, and produces consistent results across machines. Additionally, certain build systems (like CMake) provide some of the only ways to do cross OS portable builds. 

### The landscape

| Tool | Type | How it works |
|------|------|-------------|
| **Make** | Build system | You write explicit rules (`foo.o: foo.c`) and Make executes them. You manage all the logic. |
| **Autotools** | Meta-build system | `configure` script probes the system, generates Makefiles. The classic Unix approach. |
| **Meson** | Meta-build system | Python-based. Generates Ninja files. Clean syntax, gaining traction. |
| **CMake** | Meta-build system | Generates native build files (Make, Ninja, VS, Xcode). Dominant in scientific computing. |

The key distinction: **Make** is a build system (it runs compilers). **CMake** is a build system *generator* --- it produces Makefiles (or Ninja files, or IDE projects) that then run the compilers.

---

## What Is CMake, Really?

- CMake is **not** a build system --- it is a **meta-build system** (a build system generator)
- You describe *what* to build, CMake figures out *how*
- CMake generates native build files for your platform:
  - **Makefiles** (GNU Make) --- the classic, still common on HPC
  - **Ninja** --- faster parallel builds, recommended for development
  - **Visual Studio** solutions --- Windows
  - **Xcode** projects --- macOS
- The generator is chosen at configure time:

```bash
cmake -G Ninja -B build
cmake -G "Unix Makefiles" -B build
```

---

## Why CMake Won in Scientific Computing

| Feature             | Makefiles | Autotools | Meson  | CMake  |
|---------------------|-----------|-----------|--------|--------|
| Fortran support     | Manual    | Partial   | Yes    | Yes    |
| Cross-platform      | No        | No        | Yes    | Yes    |
| IDE integration     | No        | No        | Some   | Yes    |
| HPC ecosystem       | ---       | Legacy    | Rare   | Dominant |
| find_package ecosystem | No     | No        | wrap   | Native |

- A lot of scientific libraries ship CMake support: HDF5, PETSc, Trilinos, deal.II, BLAS/LAPACK vendors
- Fortran module dependency tracking is built in
- CTest + CDash for testing infrastructure

---

## Why Global State Is the Root of All Evil

Before we look at old vs modern CMake, let's talk about **why** the old way is bad. 

---

### The problem with globals in any language

```c
// C: global state
int precision = 64;          // who set this? when? why?
double threshold = 1e-12;    // can anyone change it at any time?

void solve() {
    // uses precision and threshold implicitly
    // caller has no idea what this function depends on
}
```

```python
# Python: same problem
GRID_SIZE = 256  # set at module level, mutated somewhere in main()

def compute_field():
    # uses GRID_SIZE --- but what if two callers need different sizes?
    pass
```

---

### Global state creates three problems:

1. **Invisible coupling**: Code depends on things that are not in its function signature. You cannot understand `solve()` by reading `solve()` alone.
2. **Action at a distance**: Changing a global in file A breaks behavior in file Z, with no obvious connection between them.
3. **Composition failure**: You cannot have two instances with different settings. If library A sets `precision = 32` and library B sets `precision = 64`, whoever runs last wins.

---

### The same problem in old CMake

```cmake
# Old CMake: global state everywhere
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -O2")  # affects EVERY target
include_directories(/opt/hdf5/include)                 # affects EVERY target
add_definitions(-DUSE_MPI)                             # affects EVERY target

add_library(mylib solver.cpp)     # gets -Wall -O2, HDF5 includes, -DUSE_MPI
add_executable(myapp main.cpp)    # also gets ALL of that, even if it doesn't need it
add_executable(tests test.cpp)    # also gets ALL of that --- tests compiled with -O2?
```

Every `include_directories()`, `add_definitions()`, and `CMAKE_CXX_FLAGS` modification is a **global mutation**. It affects every target defined after it in the current directory and all subdirectories. This leads to:

- Libraries that only compile when consumed in exactly the right order
- Tests that accidentally inherit production optimization flags
- Subdirectories that break when you reorder `add_subdirectory()` calls
- Dependencies that silently pollute your compile flags

---

### The modern alternative: explicit, local, composable

```cmake
# Modern CMake: each target declares its own needs
add_library(mylib solver.cpp)
target_compile_options(mylib PRIVATE -Wall -O2)
target_include_directories(mylib PRIVATE /opt/hdf5/include)
target_compile_definitions(mylib PRIVATE USE_MPI)

add_executable(myapp main.cpp)
target_link_libraries(myapp PRIVATE mylib)
# myapp gets only what mylib explicitly exports (PUBLIC), nothing else

add_executable(tests test.cpp)
target_link_libraries(tests PRIVATE mylib)
# tests get mylib's interface, not its internal flags
```

This is the same principle as passing arguments to functions instead of using globals. **Each target is self-contained. Dependencies are explicit. Nothing leaks.**

---

## What Is a Target?

A **target** is the central concept in modern CMake. It represents a single "thing" that CMake knows how to build, along with everything needed to build it.

### Analogy: a recipe card

Think of a target as a recipe card in a kitchen:

- **Name**: "chocolate cake" (or `mycake`, `mycake`)
- **Ingredients**: flour, sugar, eggs (or `solver.cpp`, `utils.f90`)
- **Equipment needed**: oven at 180C (or `-O2`, `-std=c++17`)
- **Depends on**: "make the frosting first" (or `target_link_libraries(cake PRIVATE frosting)`)
- **What it produces**: a cake (or `libmycake.so`, `mycake`)

The recipe card is self-contained. You can read it and know everything needed to make the cake. You do not need to check what the previous recipe did, or what the kitchen's "global oven temperature" is set to.

---

### In CMake

Every target is created by one of these commands:

```cmake
add_executable(myapp main.cpp)          # target "myapp" --- produces a binary
add_library(mylib solver.cpp)           # target "mylib" --- produces a library (can be static, shared, or object)
add_library(mylib INTERFACE)            # target "mylib" --- header-only, no compiled output
```

Once a target exists, you attach information to it:

```cmake
# What include paths does mylib need to compile?
target_include_directories(mylib PUBLIC include/)

# What other targets does mylib depend on?
target_link_libraries(mylib PRIVATE BLAS::BLAS)

# What compiler features does mylib require?
target_compile_features(mylib PUBLIC cxx_std_17)

# What preprocessor definitions?
target_compile_definitions(mylib PRIVATE USE_OPENMP)
```

Every `target_*` command takes the target name as its first argument. There is no ambiguity about *what* you are configuring.

---

### Why targets matter

Targets are the unit of **dependency propagation**. When you write:

```cmake
target_link_libraries(myapp PRIVATE mylib)
```

CMake does not just add `-lmylib` to the linker command. It propagates everything `mylib` declared as `PUBLIC` or `INTERFACE`:
- Include directories
- Compile definitions
- Compile features (e.g., C++17)
- Other transitive library dependencies

This is what makes modern CMake composable. You describe each target once, and consumers automatically inherit the right settings through `target_link_libraries`. No manual flag passing. No global state.

---

### Targets are not just libraries and executables

CMake also creates **imported targets** when you find external packages:

```cmake
find_package(MPI REQUIRED COMPONENTS Fortran)
# This creates the imported target MPI::MPI_Fortran
# It carries include paths, link flags, and compiler wrappers

target_link_libraries(mylib PUBLIC MPI::MPI_Fortran)
# mylib and all its consumers now get MPI automatically
```

The `::` in target names like `MPI::MPI_Fortran` is a namespace convention. It serves two purposes:
1. Makes it clear this is an imported target, not a local one
2. If the target does not exist, CMake gives a clear error instead of silently treating it as a linker flag

We will cover target types in detail (STATIC, SHARED, OBJECT, INTERFACE, etc.) in Part II.

---

## The Old Way vs The Modern Way

### Do NOT do this (pre-2014 CMake):

```cmake
# BAD! - global state, pollutes everything
include_directories(${SOME_LIB_INCLUDE_DIRS})
link_directories(${SOME_LIB_LIB_DIRS})
add_definitions(-DUSE_MPI)
add_executable(myapp main.cpp)
target_link_libraries(myapp ${SOME_LIB_LIBRARIES})
```

### Do this (Modern CMake --- target-based):

```cmake
# RIGHT - explicit, composable, exportable
add_executable(myapp main.cpp)
target_link_libraries(myapp PRIVATE SomeLib::SomeLib)
target_compile_definitions(myapp PRIVATE USE_MPI)
```

Key principle: **Everything is a target, everything is a property.**

---

## cmake_minimum_required and Policies

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
```

- The minimum version sets the **policy defaults** --- this controls CMake's behavior
- Version ranges (`3.21...3.31`) let you support older CMake while opting into new policies
- In 2026, `3.28` is a reasonable floor:
  - Fortran module dependency scanning
  - `CMakePresets.json` v3
  - HIP language support
  - Better `install(TARGETS)` defaults
- This should always be the first line of CMake in any top level CMakeList 

---

### What is a policy?

CMake evolves by introducing **policies** that change default behavior. Each policy has an OLD (deprecated) and NEW (correct) behavior:

```cmake
# You rarely set these manually --- cmake_minimum_required does it for you
cmake_policy(SET CMP0077 NEW)  # option() honors normal variables
```

When you set `cmake_minimum_required(VERSION 3.21)`, all policies introduced up to 3.21 default to NEW. This is why bumping the minimum version can change behavior --- and why you should test when you do.

---

# Part II: Core Concepts

## Target Types

CMake has several target types. Understanding them is essential.

### Executable

```cmake
add_executable(myapp main.cpp utils.cpp)
```

A program you can run. Sources are compiled and linked into a binary.

### Static Library

```cmake
add_library(mylib STATIC solver.cpp matrix.cpp)
```

An archive (`.a` / `.lib`). Code is copied into the final executable at link time. No runtime dependency.

### Shared Library

```cmake
add_library(mylib SHARED solver.cpp matrix.cpp)
```

A dynamic library (`.so` / `.dylib` / `.dll`). Loaded at runtime. Saves disk/memory when multiple executables use the same library. Requires the `.so` to be findable at runtime (`LD_LIBRARY_PATH`, `RPATH`, etc.).

### Default Library (let the user choose)

```cmake
add_library(mylib solver.cpp matrix.cpp)
```

No `STATIC` or `SHARED` keyword. The type is controlled by `BUILD_SHARED_LIBS`:

```bash
cmake -B build -DBUILD_SHARED_LIBS=ON    # shared
cmake -B build -DBUILD_SHARED_LIBS=OFF   # static (default)
```

---

### Object Library

```cmake
add_library(mylib_objects OBJECT solver.cpp matrix.cpp)
```

Compiles sources to `.o` files but does **not** create an archive or shared library. An object library is not a "real" library --- it is a bag of compiled `.o` files that can be poured into other targets. You cannot link against it in the traditional sense.

**When would you actually use this?**

**Use case 1: Building both static and shared from the same sources.** This is the primary legitimate use. When you build a shared library, the compiler needs `-fPIC` (position-independent code). Static libraries typically do not. So the same source file produces different `.o` files depending on the target type --- you cannot just compile once and archive both ways.

An object library lets you compile once (with PIC) and reuse:

```cmake
add_library(mylib_objects OBJECT solver.cpp matrix.cpp)
set_target_properties(mylib_objects PROPERTIES POSITION_INDEPENDENT_CODE ON)

# Same .o files, two different packaging
add_library(mylib_shared SHARED $<TARGET_OBJECTS:mylib_objects>)
add_library(mylib_static STATIC $<TARGET_OBJECTS:mylib_objects>)
```

Without this, every source file compiles twice. For a large scientific codebase with heavy Fortran or template-heavy C++, that time adds up.

---

### Object Library (cont.)

**Use case 2: Organizing a large project without creating unnecessary library artifacts.** Imagine a project with 200 source files across several subdirectories. You want to organize the build logically, but these subdirectories are internal --- nobody will ever consume `src/core/` independently from `src/solver/`. Creating real libraries for them adds install/export overhead for no benefit.

```cmake
# src/core/CMakeLists.txt --- internal, not a consumable package
add_library(core_objects OBJECT field.cpp mesh.cpp)
target_include_directories(core_objects PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# src/solver/CMakeLists.txt --- internal, not a consumable package
add_library(solver_objects OBJECT poisson.f90 helmholtz.f90)

# Top-level: the one real library that gets installed and exported
add_library(mylib
  $<TARGET_OBJECTS:core_objects>
  $<TARGET_OBJECTS:solver_objects>
)
```

This gives you subdirectory organization without creating separate `.a`/`.so` files that nobody will ever link against independently.

**When NOT to use object libraries**: If the components have genuinely independent consumers, make them real libraries with real interfaces. Object libraries cannot carry PUBLIC properties the same way a real library target can. Default to proper libraries; reach for OBJECT only when you have a concrete reason (dual static/shared, or internal build organization).

---

### Interface Library

```cmake
add_library(mylib INTERFACE)
```

No source files, no compiled output. An interface library produces nothing you can point to on disk --- no `.a`, no `.so`, no `.o`. It exists purely to carry **usage requirements**: include paths, compile definitions, compile features, and link dependencies. Anything you attach to it gets propagated to whoever links against it.

**Why would you want a library that produces nothing?**

**Use case 1: Header-only C++ libraries.** Many modern C++ libraries (nlohmann/json, Eigen, Catch2 v2) are header-only. There is nothing to compile --- the consumer compiles the code as part of their own build. But you still want a proper target so consumers can do `target_link_libraries(myapp PRIVATE json)` and get the include paths automatically.

```cmake
add_library(json INTERFACE)
target_include_directories(json
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Consumer just does:
target_link_libraries(myapp PRIVATE json)
# and the include paths are set up --- no manual -I flags
```

---

### Interface Library (cont.)

**Use case 2: Bundling a collection of dependencies under one name.** Say your project has a standard set of dependencies that most targets need --- MPI, a math library, and some compile flags. Instead of repeating them on every target, create an interface library that collects them:

```cmake
add_library(project_defaults INTERFACE)
target_compile_features(project_defaults INTERFACE cxx_std_17)
target_link_libraries(project_defaults INTERFACE MPI::MPI_CXX)
target_compile_options(project_defaults
  INTERFACE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra>
)

# Now every target just links this one "meta-target"
add_library(core solver.cpp)
target_link_libraries(core PRIVATE project_defaults)

add_library(io writer.cpp)
target_link_libraries(io PRIVATE project_defaults)
```

---

This is a common pattern in larger projects to avoid repeating the same 10 lines of `target_*` calls on every target.

**Use case 3: Fortran module-only packages.** Some Fortran packages provide only `.mod` files (module interfaces) with no compiled code --- the consumer compiles against the module definitions. An INTERFACE library is the natural fit.

Note: Even though interface libraries have no compiled output, they **can be installed and exported** just like regular libraries. Consumers can `find_package` them and link against them normally.

### Module Library

```cmake
add_library(myplugin MODULE plugin.cpp)
```

A shared library that is loaded at runtime via `dlopen()` / `LoadLibrary()`. Not linked against directly. Used for plugin architectures. Rarely needed in scientific computing.

---

## Properties

Properties are the fundamental data model in modern CMake. Every target, directory, source file, test, and even the global scope can have properties.

### Target properties

```cmake
add_library(mylib solver.cpp)

# Set properties directly
set_target_properties(mylib PROPERTIES
  VERSION 1.0.0
  SOVERSION 1
  POSITION_INDEPENDENT_CODE ON
  Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mod"
)

# Or query them
get_target_property(ver mylib VERSION)
message(STATUS "mylib version: ${ver}")
```

### The target_* commands set properties with scope

The `target_*` commands are just convenient wrappers that set properties with the right visibility:

| Command | Property set |
|---------|-------------|
| `target_include_directories(A PUBLIC dir)` | `INCLUDE_DIRECTORIES` and `INTERFACE_INCLUDE_DIRECTORIES` |
| `target_compile_definitions(A PRIVATE DEF)` | `COMPILE_DEFINITIONS` |
| `target_link_libraries(A PUBLIC B)` | `LINK_LIBRARIES` and `INTERFACE_LINK_LIBRARIES` |
| `target_compile_options(A PRIVATE -Wall)` | `COMPILE_OPTIONS` |
| `target_compile_features(A PUBLIC cxx_std_17)` | `COMPILE_FEATURES` and `INTERFACE_COMPILE_FEATURES` |

---

### PUBLIC, PRIVATE, INTERFACE --- the visibility model

This is the single most important concept in modern CMake:

- **PRIVATE**: Only used when building this target. Consumers do not see it.
- **INTERFACE**: Only used by consumers. Not used when building this target itself.
- **PUBLIC**: Both --- used when building this target AND propagated to consumers.

```cmake
add_library(mylib solver.cpp)

# mylib needs Eigen headers to compile, and so do its consumers
target_link_libraries(mylib PUBLIC Eigen3::Eigen)

# mylib uses fmt internally, but consumers don't need it
target_link_libraries(mylib PRIVATE fmt::fmt)

# Consumers need this define, but mylib's own sources don't
target_compile_definitions(mylib INTERFACE USING_MYLIB)
```

**Rule of thumb**: If it appears in your public headers, it is PUBLIC. If it is only in your `.cpp` / `.f90` files, it is PRIVATE.

---

## Generator Expressions

Generator expressions are evaluated at **generate time** (when CMake writes the build files), not at configure time. They look like `$<...>` and are essential for writing CMake that works in multiple contexts.

These can get messy and some people prefer to avoid them, they are powerful but to each their own, I guess.

### Why do we need them?

Because some information depends on the context. An include path is different during build vs after install. A compile flag depends on which compiler is being used. These things are not known until generate time.

### The most important ones

#### BUILD_INTERFACE / INSTALL_INTERFACE

```cmake
target_include_directories(mylib
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
```

- `BUILD_INTERFACE`: Active when the target is used from the build tree (building directly or via FetchContent)
- `INSTALL_INTERFACE`: Active when the target is used from an install tree (via find_package)

---

### Generator Expressions: Conditionals

#### Conditional on build type

```cmake
target_compile_definitions(mylib
  PRIVATE
    $<$<CONFIG:Debug>:MYLIB_DEBUG_MODE>
)
```

---

#### Conditional on compiler

```cmake
target_compile_options(mylib
  PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra>
    $<$<CXX_COMPILER_ID:Intel>:-w3>
    $<$<Fortran_COMPILER_ID:GNU>:-fcheck=all>
)
```

---

#### Conditional on language

```cmake
target_compile_options(mylib
  PRIVATE
    $<$<COMPILE_LANGUAGE:Fortran>:-ffree-form>
    $<$<COMPILE_LANGUAGE:CXX>:-std=c++17>
)
```

---

#### TARGET_EXISTS (check before linking)

```cmake
target_link_libraries(mylib
  PRIVATE
    $<$<TARGET_EXISTS:OpenMP::OpenMP_CXX>:OpenMP::OpenMP_CXX>
)
```

### Nesting

Generator expressions can be nested, but readability drops fast:

```cmake
# Add -O3 only for Release builds with GCC
$<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:GNU>>:-O3>
```

When nesting gets ugly, consider using a helper variable or a `cmake_language(EVAL)` instead.

---

## CMake Modules (Custom Scripts)

CMake modules are `.cmake` files that extend CMake's functionality. They come in three flavors.

### Built-in modules (shipped with CMake)

```cmake
include(GNUInstallDirs)         # Provides CMAKE_INSTALL_LIBDIR, etc.
include(CMakePackageConfigHelpers)  # Helpers for Config.cmake
include(FetchContent)           # Pull dependencies at configure time
include(CheckFortranSourceCompiles) # Compiler feature checks
include(CTest)                  # Enable testing support
```

---

### Find modules (Find<Package>.cmake)

CMake ships many, and you can write your own:

```cmake
find_package(BLAS REQUIRED)     # Uses CMake's built-in FindBLAS.cmake
find_package(MyLib REQUIRED)    # Looks for FindMyLib.cmake or MyLibConfig.cmake
```

Search order for `find_package(Foo)`:
1. `FooConfig.cmake` (or `foo-config.cmake`) --- **Config mode** (preferred, provided by the package)
2. `FindFoo.cmake` --- **Module mode** (provided by CMake or the consumer in their `cmake/` dir)

These are case sensity, if you want to find BLAS your package should be BLASConfig.cmake, "blas" won't get picked up.

---

### Custom utility modules

Put reusable logic in `cmake/` and include it:

```cmake
# cmake/CompilerWarnings.cmake
function(set_project_warnings target)
  target_compile_options(${target}
    PRIVATE
      $<$<COMPILE_LANGUAGE:CXX>:-Wall -Wextra -Wpedantic>
      $<$<COMPILE_LANGUAGE:Fortran>:-Wall -Wextra>
      $<$<CXX_COMPILER_ID:Intel>:-w3 -diag-disable=remark>
  )
endfunction()
```

```cmake
# CMakeLists.txt
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(CompilerWarnings)

add_library(mylib solver.cpp)
set_project_warnings(mylib)
```

---

### Writing a Find module: FindMyPackage.cmake

When a third-party library does **not** ship a Config.cmake, you can write a Find module for it. This goes in your project's `cmake/` directory.
```cmake
# cmake/FindSuperLU.cmake
# Finds the SuperLU library (does not ship its own CMake config)
find_path(SuperLU_INCLUDE_DIR
  NAMES slu_ddefs.h
  HINTS
    ${SuperLU_ROOT}
    ENV SuperLU_ROOT
  PATH_SUFFIXES include include/superlu
)
find_library(SuperLU_LIBRARY
  NAMES superlu
  HINTS
    ${SuperLU_ROOT}
    ENV SuperLU_ROOT
  PATH_SUFFIXES lib lib64
)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SuperLU
  REQUIRED_VARS SuperLU_LIBRARY SuperLU_INCLUDE_DIR
)
if(SuperLU_FOUND AND NOT TARGET SuperLU::SuperLU)
  add_library(SuperLU::SuperLU UNKNOWN IMPORTED)
  set_target_properties(SuperLU::SuperLU PROPERTIES
    IMPORTED_LOCATION "${SuperLU_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${SuperLU_INCLUDE_DIR}"
  )
endif()
```
---


Now consumers do:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
find_package(SuperLU REQUIRED)
target_link_libraries(myapp PRIVATE SuperLU::SuperLU)
```

Key points:
- Always create an IMPORTED target with a namespaced name (`SuperLU::SuperLU`)
- Use `find_package_handle_standard_args` for consistent `REQUIRED` / `QUIET` handling
- Support `<Package>_ROOT` hints so users can point to custom install locations

---

## CMake Presets

`CMakePresets.json` at the project root --- **a covenient tool for reproducibility on HPC**. Full example in `examples/CMakePresets.json`. The key ideas:

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "default",
      "hidden": true,
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build-${presetName}",
      "cacheVariables": {
        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
      }
    },
    {
      "name": "gcc-release",
      "inherits": "default",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_C_COMPILER": "gcc",
        "CMAKE_CXX_COMPILER": "g++",
        "CMAKE_Fortran_COMPILER": "gfortran"
      }
    }
  ]
}
```

---

### Preset inheritance

- `"hidden": true` base preset defines generator, build dir, common variables
- Concrete presets use `"inherits": "default"` and only add what differs
- Presets can inherit from multiple parents
- Add `gcc-debug`, `clang-release`, `intel-release`, `nvhpc-release` --- same pattern

---

### User-local overrides: CMakeUserPresets.json

Developers can create `CMakeUserPresets.json` (gitignored) for machine-specific overrides:

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "my-gcc",
      "inherits": "gcc-debug",
      "cacheVariables": {
        "CMAKE_C_COMPILER": "/opt/gcc-14/bin/gcc",
        "CMAKE_CXX_COMPILER": "/opt/gcc-14/bin/g++",
        "CMAKE_Fortran_COMPILER": "/opt/gcc-14/bin/gfortran"
      }
    }
  ]
}
```
---


### Usage

```bash
cmake --preset gcc-release
cmake --build --preset gcc-release
ctest --preset gcc-debug
```

No more "which flags did I use last time?" --- it is all versioned in the repo.

---

## Build Order, Parallelism, and Dependencies

When you run `cmake --build build`, the build tool (Make or Ninja) compiles as many files **in parallel** as it can. But some things must happen in a specific order. CMake manages this automatically --- if you tell it about the dependencies.

### Target-level ordering

`target_link_libraries` does double duty: it sets up link flags **and** build ordering.

```cmake
add_library(core solver.cpp)
add_library(io writer.cpp)
add_executable(sim main.cpp)

target_link_libraries(io PRIVATE core)       # io depends on core
target_link_libraries(sim PRIVATE core io)   # sim depends on both
```

CMake guarantees:
- `core` finishes building before `io` starts linking
- Both `core` and `io` finish before `sim` links
- But `core` and `io` source files **compile in parallel** (they don't depend on each other's object files)

For Fortran, this matters even more: if `io.f90` does `use core_module`, CMake detects the module dependency and ensures `core` compiles first (so the `.mod` file exists). This is the problem our Makefile solved manually --- CMake solves it automatically.

It is not failure proof. A very large project with a lot of files and inter-module dependencies can run into race conditions when built in parallel

---

### Explicit ordering without linking

Sometimes you need target A to build before target B, but they do not link to each other:

```cmake
add_dependencies(my_executable my_code_generator)
```

This says: "build `my_code_generator` before `my_executable`", without adding any link flags. Use this when one target produces files that another target needs.

---

## Custom Commands: Generating Files at Build Time

Scientific projects often need to generate source files, headers, or data at build time --- code generators, preprocessing scripts, configuration headers from templates.

### add_custom_command: produce a file

```cmake
# Generate a header from a template using a Python script
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/config.h"
  COMMAND Python3::Interpreter
          "${CMAKE_CURRENT_SOURCE_DIR}/gen_config.py"
          "--output" "${CMAKE_CURRENT_BINARY_DIR}/config.h"
  DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/gen_config.py"
  COMMENT "Generating config.h"
)
```

---


Key points:
- `OUTPUT`: the file(s) this command produces. CMake uses this to track dependencies --- if a target needs `config.h`, this command runs automatically.
- `DEPENDS`: input files. If any change, the command re-runs.
- `COMMENT`: printed during build so you know what is happening.

The command only runs if something depends on its output. To connect it to a target:

```cmake
add_library(mylib solver.cpp "${CMAKE_CURRENT_BINARY_DIR}/config.h")
```

Now `config.h` is generated before `mylib` compiles.

---

### add_custom_target: always-run commands

Unlike `add_custom_command` (which runs only when its output is needed), `add_custom_target` creates a named target that **always runs** when invoked:

```cmake
add_custom_target(generate_grids
  COMMAND Python3::Interpreter "${CMAKE_CURRENT_SOURCE_DIR}/make_grids.py"
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  COMMENT "Generating grid input files"
)

# Make the simulation depend on generated grids
add_dependencies(sim generate_grids)
```

Common uses:
- Pre-processing steps that produce multiple files
- Running code formatters (`clang-format`, `fprettify`)
- Generating documentation

---

### Fortran-specific: preprocessing `.F90` files

Fortran files with uppercase extensions (`.F90`) are run through the C preprocessor before compilation. CMake handles this automatically. But if you have a custom preprocessing step:

```cmake
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated_solver.f90"
  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/preprocess.sh"
          "${CMAKE_CURRENT_SOURCE_DIR}/solver.f90.in"
          "${CMAKE_CURRENT_BINARY_DIR}/generated_solver.f90"
  DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/solver.f90.in"
          "${CMAKE_CURRENT_SOURCE_DIR}/preprocess.sh"
  COMMENT "Preprocessing solver.f90"
)

add_library(solver "${CMAKE_CURRENT_BINARY_DIR}/generated_solver.f90")
```

---

## Cross-Compilation and Architectures

On a cluster, you often compile on a login node for a different architecture (compute nodes, GPU accelerators). CMake handles this with **toolchain files**.

These are way more common in enterprise type software and/or games. However, that doesn't make them unsuited for HPC.

### Toolchain files

A toolchain file tells CMake which compilers and system paths to use:

```cmake
# toolchain-cray.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_C_COMPILER cc)        # Cray compiler wrappers
set(CMAKE_CXX_COMPILER CC)
set(CMAKE_Fortran_COMPILER ftn)

# Where to find libraries for the target architecture
set(CMAKE_FIND_ROOT_PATH /opt/cray/pe)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

Usage:

```bash
cmake -B build --toolchain toolchain-cray.cmake
```

---

Or in a preset:

```json
{
  "name": "cray",
  "inherits": "default",
  "toolchainFile": "${sourceDir}/cmake/toolchain-cray.cmake"
}
```

---

### GPU offloading (OpenMP, OpenACC, CUDA)

For GPU-enabled scientific codes:

```cmake
# CUDA as a first-class language
project(mysolver LANGUAGES C CXX CUDA Fortran)

add_library(gpu_kernels src/kernels.cu)
target_compile_features(gpu_kernels PUBLIC cuda_std_17)

# Or OpenMP offloading (compiler-specific)
find_package(OpenMP REQUIRED)
target_link_libraries(solver PRIVATE OpenMP::OpenMP_Fortran)
target_compile_options(solver
  PRIVATE
    $<$<Fortran_COMPILER_ID:GNU>:-fopenmp -foffload=nvptx-none>
    $<$<Fortran_COMPILER_ID:NVHPC>:-mp=gpu -gpu=cc80>
)
```

---

### Architecture-specific flags --- use presets, not CMakeLists.txt

Do **not** put `-march=native` or `-gpu=cc80` in your CMakeLists.txt. These are deployment decisions, not project properties. Put them in presets:

```json
{
  "name": "a100-release",
  "inherits": "nvhpc-release",
  "cacheVariables": {
    "CMAKE_Fortran_FLAGS_RELEASE": "-O3 -gpu=cc80"
  }
}
```

This keeps the CMakeLists.txt portable and lets each deployment site choose the right flags.

---

# Part III: Scientific Computing Specifics

## Multi-Language Projects (C + C++ + Fortran)

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(MySimulation
  VERSION 1.0.0
  LANGUAGES C CXX Fortran
)
```

- CMake detects compilers, checks interoperability
- Fortran `.mod` files are tracked automatically for dependency ordering
- C/Fortran interop via `iso_c_binding` (Fortran 2003+) is the modern way

---

## Finding Scientific Libraries

### BLAS / LAPACK

```cmake
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

target_link_libraries(mylib PRIVATE BLAS::BLAS LAPACK::LAPACK)
```

---

### MPI

```cmake
find_package(MPI REQUIRED COMPONENTS C CXX Fortran)

target_link_libraries(mylib PUBLIC MPI::MPI_Fortran)
```

---

### HDF5

```cmake
find_package(HDF5 REQUIRED COMPONENTS C Fortran)

target_link_libraries(mylib PRIVATE HDF5::HDF5)
```

---

### On HPC: pointing CMake to the right place

```bash
cmake -B build \
  -DCMAKE_PREFIX_PATH="/opt/openmpi/4.1;/opt/hdf5/1.14" \
  -DBLAS_ROOT=/opt/openblas/0.3
```

Or via environment modules:

```bash
module load openmpi hdf5 openblas
cmake -B build  # find_package picks up $PATH and $LD_LIBRARY_PATH hints
```

---

## FetchContent for Dependencies

Pull a dependency at configure time --- no need for git submodules:

```cmake
include(FetchContent)

FetchContent_Declare(
  fmt
  GIT_REPOSITORY https://github.com/fmtlib/fmt.git
  GIT_TAG        11.1.4
)
FetchContent_MakeAvailable(fmt)

target_link_libraries(myapp PRIVATE fmt::fmt)
```

This works because `fmt` has a proper CMake install/export setup. **Your project should too.**

---

## When Projects Collide: The Option Namespace Problem

When you use `FetchContent` or `add_subdirectory` to pull in another CMake project, both projects run in the **same CMake scope**. Their cache variables, options, and targets all share a single flat namespace. This leads to one of the most common and frustrating problems in multi-project CMake builds.

---

### The disaster

Suppose you are building a simulation that depends on both our example projects:

```cmake
# heatmap's CMakeLists.txt (BAD version)
project(heatmap)
option(BUILD_TESTS "Build tests" ON)
option(BUILD_DOCS "Build documentation" OFF)
option(USE_OPENMP "Enable OpenMP" ON)
```

```cmake
# wave's CMakeLists.txt (BAD version)
project(wave)
option(BUILD_TESTS "Build tests" ON)
option(BUILD_DOCS "Build documentation" OFF)
option(USE_OPENMP "Enable OpenMP" OFF)  # different default!
```

```cmake
# Your project
project(my_simulation)
include(FetchContent)

FetchContent_Declare(heatmap ...)
FetchContent_Declare(wave ...)
FetchContent_MakeAvailable(heatmap wave)
```

---

Now you run:

```bash
cmake -B build -DBUILD_TESTS=OFF -DUSE_OPENMP=ON
```

**What happens?**

- `BUILD_TESTS` is a single cache variable. Both `heatmap` and `wave` read the same value. You cannot build tests for one but not the other.
- `USE_OPENMP` is also shared. You set it to ON, but you meant it for `heatmap` --- now `wave` also gets OpenMP, which it was not designed for by default.
- If `heatmap` is fetched first, its `option(USE_OPENMP ... ON)` creates the cache entry. When `wave` reaches its `option(USE_OPENMP ... OFF)`, the variable already exists --- `option()` does nothing. `wave` silently gets `ON` regardless of its default.

This gets worse with common option names. These are real option names that appear in dozens of projects:

- `BUILD_TESTS`
- `BUILD_EXAMPLES`
- `BUILD_DOCS`
- `BUILD_SHARED_LIBS`
- `ENABLE_MPI`
- `USE_OPENMP`

If your dependency tree has 5 projects, and 3 of them use `BUILD_TESTS`, one `-D` flag silently controls all of them.

---

### The fix: prefix everything

Every option, cache variable, and custom function should be prefixed with the project name. This is what we did in our actual examples:

```cmake
# heatmap's CMakeLists.txt --- CORRECT
project(heatmap)
option(HEATMAP_BUILD_TESTS "Build heatmap tests" ON)
option(HEATMAP_BUILD_DOCS "Build heatmap documentation" OFF)
option(HEATMAP_USE_OPENMP "Enable OpenMP in heatmap" ON)
```

```cmake
# wave's CMakeLists.txt --- CORRECT
project(wave)
option(WAVE_BUILD_TESTS "Build wave tests" ON)
option(WAVE_BUILD_DOCS "Build wave documentation" OFF)
option(WAVE_USE_OPENMP "Enable OpenMP in wave" OFF)
```

---

Now the consumer has full control:

```bash
cmake -B build \
  -DHEATMAP_BUILD_TESTS=OFF \
  -DWAVE_BUILD_TESTS=OFF \
  -DHEATMAP_USE_OPENMP=ON \
  -DWAVE_USE_OPENMP=OFF
```

No collisions. No surprises.

---

### Guard tests and examples behind PROJECT_IS_TOP_LEVEL

Even with prefixed options, you usually do not want to build a dependency's tests when it is consumed as a sub-project. The `PROJECT_IS_TOP_LEVEL` variable (CMake 3.21+) tells you if this project is the root or was pulled in by someone else:

```cmake
project(heatmap VERSION 1.0.0 LANGUAGES C)

if(PROJECT_IS_TOP_LEVEL)
  option(HEATMAP_BUILD_TESTS "Build tests" ON)
  option(HEATMAP_BUILD_EXAMPLES "Build examples" ON)
else()
  # Pulled in via FetchContent or add_subdirectory --- don't build extras
  set(HEATMAP_BUILD_TESTS OFF)
  set(HEATMAP_BUILD_EXAMPLES OFF)
endif()
```

This means `FetchContent` consumers get only the library, not the tests, docs, and examples --- without needing to know which `-D` flags to set.

---

### The same problem with target names

Options are not the only thing that collides. Target names are also global:

```cmake
# heatmap
add_library(utils utils.c)       # target "utils"

# wave
add_library(utils helpers.f90)   # CONFLICT: target "utils" already exists!
```

CMake will error on the second `add_library(utils ...)`. The fix is the same --- prefix target names:

```cmake
add_library(heatmap_utils utils.c)
add_library(heatmap::utils ALIAS heatmap_utils)
```

Or organize so that your internal targets have project-specific names. The ALIAS with namespace lets consumers use the clean `heatmap::utils` name.

---

### Summary of namespace hygiene rules

| What | Bad | Good |
|------|-----|------|
| Options | `BUILD_TESTS` | `MYPROJECT_BUILD_TESTS` |
| Cache variables | `USE_OPENMP` | `MYPROJECT_USE_OPENMP` |
| Targets | `utils` | `myproject_utils` |
| Functions/macros | `add_test_suite()` | `myproject_add_test_suite()` |
| Find modules | `FindUtils.cmake` | `FindMyProjectUtils.cmake` |

**Rule**: If it goes into the global CMake namespace, prefix it with your project name. Assume your project will be consumed as a sub-project by someone else, even if you think it won't be.

---

# Interlude: Migrating from Make to CMake

## The Migration Mindset

You have a Makefile (or a shell script) that works. The goal is not to rewrite your code --- it is to **describe what you already have** in CMake's language. The source files do not change. The compiler does not change. Only the build description changes.

This is a mechanical process, not a creative one. Here is the recipe.

---

## Step 1: Read Your Makefile

Before writing any CMake, extract the information your Makefile already contains. Everything you need is in there.

**From our heatmap `compile.sh`:**

| What | Value |
|------|-------|
| Language | C |
| Compiler | `gcc` (but we want this to be flexible) |
| Flags | `-O2 -Wall` |
| Include paths | `-I./include` |
| Source files | `src/heatmap.c`, `src/main.c` |
| Link libraries | `-lm` |
| Output | `heatmap_sim` (executable) |

**From our wave `Makefile`:**

| What | Value |
|------|-------|
| Language | Fortran |
| Compiler | `gfortran` (hardcoded) |
| Flags | `-O2 -Wall -Wextra` |
| Source files | `src/wave_solver.f90`, `src/main.f90` |
| Module dependencies | `main.f90` depends on `wave_solver.f90` (manually tracked!) |
| Output | `wave_sim` (executable) |

---

## Step 2: Identify Libraries vs Executables

This is the key design decision. In a Makefile, everything gets compiled and linked into one binary. In CMake, you want to **separate the library from the executable**.

Ask yourself: "If someone else wanted to use my code, which files would they need?"

**heatmap:**
- `src/heatmap.c` + `include/heatmap/heatmap.h` --- that is the library (reusable)
- `src/main.c` --- that is just a driver program (not reusable)

**wave:**
- `src/wave_solver.f90` --- that is the library (the module that defines `WaveState`)
- `src/main.f90` --- that is just a driver program

This split does not exist in the Makefile. Creating it is the single biggest improvement you make during migration.

---

## Step 3: Write the Minimal CMakeLists.txt

Start with the absolute minimum that builds the same thing your Makefile builds. Do not add install rules, presets, or export machinery yet. Get it building first.

**heatmap --- first pass:**

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(heatmap VERSION 1.0.0 LANGUAGES C)

add_library(heatmap src/heatmap.c)
target_include_directories(heatmap PUBLIC include)
target_link_libraries(heatmap PRIVATE m)

add_executable(heatmap_sim src/main.c)
target_link_libraries(heatmap_sim PRIVATE heatmap)
```

---

**wave --- first pass:**

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(wave VERSION 1.0.0 LANGUAGES Fortran)

add_library(wave src/wave_solver.f90)

add_executable(wave_sim src/main.f90)
target_link_libraries(wave_sim PRIVATE wave)
```

That is it. Build it:

```bash
cmake -B build -G Ninja
cmake --build build
```

If it compiles and runs, you have a working migration. Everything from here is improvement.

---

## Step 4: Translate Makefile Patterns to CMake

Here is a cheat sheet for common Makefile patterns and their CMake equivalents:

| Makefile | CMake |
|----------|-------|
| `CC = gcc` | Do not set --- CMake detects the compiler, or use presets |
| `CFLAGS = -O2` | Build type: `cmake -B build -DCMAKE_BUILD_TYPE=Release` |
| `CFLAGS += -Wall` | `target_compile_options(mylib PRIVATE -Wall)` |
| `-I./include` | `target_include_directories(mylib PUBLIC include)` |
| `-DUSE_MPI` | `target_compile_definitions(mylib PRIVATE USE_MPI)` |
| `-L/path -lfoo` | `find_package(Foo REQUIRED)` + `target_link_libraries(mylib PRIVATE Foo::Foo)` |
| `-lm` | `target_link_libraries(mylib PRIVATE m)` |
| `%.o: %.c` pattern rules | Not needed --- CMake generates these automatically |
| Manual `.mod` ordering | Not needed --- CMake tracks Fortran `use` dependencies |
| `install: ...` with `cp` | `install(TARGETS ...)` + `install(DIRECTORY include/ ...)` |
| `clean:` | Not needed --- `cmake --build build --target clean`, or just delete `build/` |

---

## Step 5: What NOT to Migrate

Some things in your Makefile should **not** be carried over. They are either handled automatically by CMake or should be done differently:

**Do not migrate:**
- Compiler paths (`CC = /usr/bin/gcc-12`) --- use presets
- Optimization flags (`-O2`, `-O3`) --- use `CMAKE_BUILD_TYPE` (Debug, Release, RelWithDebInfo)
- Architecture flags (`-march=native`, `-gpu=cc80`) --- use presets
- Manual dependency tracking (`main.o: solver.o`) --- CMake does this automatically
- `clean` targets --- CMake provides them, or just `rm -rf build/`
- Recursive Make patterns (`$(MAKE) -C subdir`) --- use `add_subdirectory(subdir)`

**Do migrate:**
- Which files are sources vs headers
- Which external libraries are needed (`-lfoo` becomes `find_package`)
- Preprocessor definitions that are genuinely needed
- Any custom code generation steps (`add_custom_command`)

---

## Step 6: Add the Good Stuff

Once the basic build works, layer on improvements in this order:

1. **Presets** --- so you never type compiler paths again
2. **Install rules** --- `install(TARGETS ...)`, `install(DIRECTORY include/ ...)`
3. **Export rules** --- `install(EXPORT ...)`, `Config.cmake.in` so others can `find_package` you
4. **Namespace alias** --- `add_library(heatmap::heatmap ALIAS heatmap)` for FetchContent
5. **Tests** --- `enable_testing()`, `add_test()`
6. **BUILD_INTERFACE / INSTALL_INTERFACE** --- so both consumption methods work

This is exactly what we do in Part IV. The minimal CMakeLists.txt from Step 3 becomes the full example.

---

# Part IV: Making Your Package a Good Citizen

## The Goal

Remember our two example projects --- `heatmap` (C) built with a shell script, and `wave` (Fortran) built with a Makefile? We are going to make them proper CMake packages. When we are done, other projects will be able to do **either** of these and get the same result:

### Option A: Installed package

```bash
cmake -B build -Dheatmap_ROOT=/path/to/heatmap/install
```

```cmake
find_package(heatmap REQUIRED)
target_link_libraries(myapp PRIVATE heatmap::heatmap)
```

---

### Option B: FetchContent

```cmake
FetchContent_Declare(heatmap
  GIT_REPOSITORY https://github.com/yourorg/heatmap.git
  GIT_TAG v1.0.0
)
FetchContent_MakeAvailable(heatmap)
target_link_libraries(myapp PRIVATE heatmap::heatmap)
```

**Same target name, same interface, both work.** This is the standard we aim for.

---

## Example 1: C Library --- heatmap

Our 2D heat diffusion solver, written in C. Currently built with `compile.sh`. Let's turn it into a proper, installable CMake package.

### Before: what we have

```
heatmap/
  compile.sh            # hardcoded gcc, no incremental builds
  include/
    heatmap/
      heatmap.h         # public API: HeatGrid type, create/destroy/step/write
  src/
    heatmap.c           # library implementation (FTCS diffusion scheme)
    main.c              # driver program
```

---

### After: what we want

```
heatmap/
  CMakeLists.txt
  CMakePresets.json
  cmake/
    heatmapConfig.cmake.in
  include/
    heatmap/
      heatmap.h
  src/
    heatmap.c
    main.c
```

---

### heatmap: CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(heatmap
  VERSION 1.0.0
  LANGUAGES C
  DESCRIPTION "2D heat diffusion solver"
)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed.")
endif()

include(GNUInstallDirs)

# --- Options ---

if(PROJECT_IS_TOP_LEVEL)
  option(HEATMAP_BUILD_TESTS "Build tests" ON)
  option(HEATMAP_BUILD_EXAMPLES "Build examples" ON)
else()
  set(HEATMAP_BUILD_TESTS OFF)
  set(HEATMAP_BUILD_EXAMPLES OFF)
endif()

# --- Library target ---
# The library is the reusable part. The executable is just a driver.

add_library(heatmap
  src/heatmap.c
)
```

---

```cmake
add_library(heatmap::heatmap ALIAS heatmap)

target_include_directories(heatmap
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Link libm (math library) --- PRIVATE because our header doesn't
# expose math.h types, only our public API
target_link_libraries(heatmap PRIVATE m)

set_target_properties(heatmap PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
  C_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN ON
)

# --- Executable ---
# Only built when this is the top-level project or examples are enabled

if(PROJECT_IS_TOP_LEVEL OR HEATMAP_BUILD_EXAMPLES)
  add_executable(heatmap_sim src/main.c)
  target_link_libraries(heatmap_sim PRIVATE heatmap::heatmap)
endif()

# --- Install rules (see next slide) ---
```

---

### heatmap: Install and Export Rules

```cmake
# --- Install rules ---

install(TARGETS heatmap
  EXPORT heatmapTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/heatmap
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT heatmapTargets
  NAMESPACE heatmap::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/heatmap
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  cmake/heatmapConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/heatmapConfig.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/heatmap
)

```

---
```cmake
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/heatmapConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/heatmapConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/heatmapConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/heatmap
)

# --- Tests ---

if(HEATMAP_BUILD_TESTS)
  enable_testing()
  # add_subdirectory(tests)
endif()
```

---

### What changed from compile.sh?

| compile.sh | CMakeLists.txt |
|-----------|---------------|
| `CC=gcc` hardcoded | CMake detects the compiler, or use presets |
| `-O2 -Wall` hardcoded | Use presets for build type; warnings via `target_compile_options` |
| `-I./include` | `target_include_directories` with BUILD/INSTALL_INTERFACE |
| No incremental builds | CMake + Ninja tracks every dependency |
| No install | `install(TARGETS)` + `install(EXPORT)` + Config.cmake |
| Not consumable | `find_package(heatmap)` or `FetchContent` just works |
| Library and executable mixed | Separated: library is the reusable product, executable is a driver |

### cmake/heatmapConfig.cmake.in

```cmake
@PACKAGE_INIT@

# No public dependencies to re-find --- libm is PRIVATE

include("${CMAKE_CURRENT_LIST_DIR}/heatmapTargets.cmake")

check_required_components(heatmap)
```

Note: `libm` is PRIVATE (only used internally in heatmap.c, not exposed in the header), so it does **not** appear in the config file. Compare this with the Fortran example below.

---

### Symbol visibility

```cmake
set_target_properties(heatmap PROPERTIES
  C_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN ON
)
```

This hides all symbols by default. Only symbols explicitly marked with `__attribute__((visibility("default")))` (or your export macro) are visible in the shared library. Benefits:
- Faster load time
- Smaller binary
- Prevents accidental ABI leaks
- Matches Windows DLL behavior (nothing exported by default)

Use CMake's `GenerateExportHeader` module to create a portable export macro:

```cmake
include(GenerateExportHeader)
generate_export_header(heatmap
  EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/include/heatmap/export.h"
)
```

This generates a header with `HEATMAP_EXPORT` / `HEATMAP_NO_EXPORT` macros that work on all platforms.

---

### Consuming heatmap

```cmake
# Consumer CMakeLists.txt
find_package(heatmap 1.0 REQUIRED)

add_executable(my_thermal_sim main.c)
target_link_libraries(my_thermal_sim PRIVATE heatmap::heatmap)
# Headers are found automatically, libm is linked internally
```

---

## Example 2: Fortran Library --- wave

Our 1D wave equation solver, written in Fortran. Currently built with a Makefile where compilation order is manually managed. Let's turn it into a proper, installable CMake package.

### Before: what we have

```
wave/
  Makefile              # manual .mod ordering, hardcoded gfortran
  src/
    wave_solver.f90     # module: WaveState type, init/step/energy/write
    main.f90            # driver program
```

---

### After: what we want

```
wave/
  CMakeLists.txt
  CMakePresets.json
  cmake/
    waveConfig.cmake.in
  src/
    wave_solver.f90
    main.f90
```

---

### wave: CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(wave
  VERSION 1.0.0
  LANGUAGES Fortran
  DESCRIPTION "1D wave equation solver"
)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed.")
endif()

include(GNUInstallDirs)

if(PROJECT_IS_TOP_LEVEL)
  option(WAVE_BUILD_TESTS "Build tests" ON)
  option(WAVE_BUILD_EXAMPLES "Build examples" ON)
else()
  set(WAVE_BUILD_TESTS OFF)
  set(WAVE_BUILD_EXAMPLES OFF)
endif()

# --- Library target ---
# The wave_solver module is the reusable part

add_library(wave
  src/wave_solver.f90
)
add_library(wave::wave ALIAS wave)

# Fortran .mod files go to a known directory during build
set(WAVE_Fortran_MODULE_DIR "${CMAKE_CURRENT_BINARY_DIR}/mod")
set_target_properties(wave PROPERTIES
  Fortran_MODULE_DIRECTORY "${WAVE_Fortran_MODULE_DIR}"
)

# Make .mod files available to consumers (BUILD_INTERFACE for FetchContent,
# INSTALL_INTERFACE for find_package)
target_include_directories(wave
  PUBLIC
    $<BUILD_INTERFACE:${WAVE_Fortran_MODULE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(wave PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION ${PROJECT_VERSION_MAJOR}
)

# --- Executable ---

if(PROJECT_IS_TOP_LEVEL OR WAVE_BUILD_EXAMPLES)
  add_executable(wave_sim src/main.f90)
  target_link_libraries(wave_sim PRIVATE wave::wave)
endif()

# --- Install rules (see next slide) ---
```

---

### wave: Install and Export Rules

```cmake
# --- Install rules ---

install(TARGETS wave
  EXPORT waveTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Fortran .mod files
install(DIRECTORY ${WAVE_Fortran_MODULE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT waveTargets
  NAMESPACE wave::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/wave
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  cmake/waveConfig.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/waveConfig.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/wave
)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/waveConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)
```

---

```cmake
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/waveConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/waveConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/wave
)

# --- Tests ---

if(WAVE_BUILD_TESTS)
  enable_testing()
  # add_subdirectory(tests)
endif()
```

---

### What changed from the Makefile?

| Makefile | CMakeLists.txt |
|---------|---------------|
| `FC = gfortran` hardcoded | CMake detects the compiler, or use presets |
| Manual `.mod` ordering (`wave_solver.o` before `main.o`) | CMake tracks Fortran module dependencies automatically |
| `.mod` files scattered in build dir | `Fortran_MODULE_DIRECTORY` collects them in one place |
| No install target | `install(TARGETS)` + `.mod` file installation |
| Not consumable | `find_package(wave)` or `FetchContent` just works |
| Adding a new `.f90` requires editing the Makefile | Just add it to `add_library()` --- CMake resolves `use` dependencies |

### cmake/waveConfig.cmake.in

```cmake
@PACKAGE_INIT@

# No external dependencies --- pure Fortran library

include("${CMAKE_CURRENT_LIST_DIR}/waveTargets.cmake")

check_required_components(wave)
```

---

### Fortran Module Files: The Tricky Part

Fortran `.mod` files are compiler-specific and version-specific:
- A `.mod` from GFortran 13 will **not** work with GFortran 14
- A `.mod` from GFortran will **never** work with Intel ifx

This means:
1. Always install `.mod` files alongside your library
2. Consumers **must** use the same compiler family and compatible version
3. Document this requirement clearly
4. Use `CMakePresets.json` to make multi-compiler builds easy

---

### Key differences from the C example

| Aspect | heatmap (C) | wave (Fortran) |
|--------|-------------|----------------|
| Header files | `include/heatmap/heatmap.h` installed to `${CMAKE_INSTALL_INCLUDEDIR}` | No headers --- Fortran uses `.mod` files instead |
| .mod files | N/A | Must install, compiler-specific |
| Symbol visibility | `C_VISIBILITY_PRESET hidden` | Not applicable for Fortran |
| Module ordering | N/A | CMake handles automatically (was manual in Makefile) |
| Consumer compiler constraint | Any C compiler | Must match Fortran compiler vendor/version |

---

## BUILD_INTERFACE vs INSTALL_INTERFACE --- Deep Dive

Let's look at this from our heatmap example:

```cmake
target_include_directories(heatmap
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
```

- **BUILD_INTERFACE**: Active when the target is used from the build tree
  - Building directly: `cmake -B build && cmake --build build`
  - Via `FetchContent` or `add_subdirectory` --- the consumer compiles against source tree paths
  - For heatmap: resolves to `/home/you/heatmap/include`
- **INSTALL_INTERFACE**: Active when the target is used from an install tree
  - After `cmake --install build --prefix /some/path`
  - Found via `find_package()` --- paths are relative to the install prefix
  - For heatmap: resolves to `include` (relative to install prefix)

This duality is what makes a single CMakeLists.txt work for both consumption methods.

---

### BUILD_INTERFACE vs INSTALL_INTERFACE: Fortran .mod files

And for the wave example, the same applies to Fortran module directories:

```cmake
target_include_directories(wave
  PUBLIC
    $<BUILD_INTERFACE:${WAVE_Fortran_MODULE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
```

### What happens without it?

```cmake
# BROKEN: absolute source paths leak into the installed Config.cmake
target_include_directories(heatmap PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
# Consumers get: -I/home/yourname/src/heatmap/include  (does not exist on their machine)
```

---

## Consuming Packages

### After installing:

```bash
# Build and install heatmap
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/local
cmake --build build
cmake --install build

# In the consumer project:
cmake -B build -Dheatmap_ROOT=$HOME/local
# or equivalently:
cmake -B build -DCMAKE_PREFIX_PATH=$HOME/local
```

### Consumer CMakeLists.txt (C example):

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(my_thermal_sim LANGUAGES C)

find_package(heatmap 1.0 REQUIRED)

add_executable(sim main.c)
target_link_libraries(sim PRIVATE heatmap::heatmap)
# Headers found automatically, libm linked internally
```

---

### Consumer CMakeLists.txt (Fortran example):

```cmake
cmake_minimum_required(VERSION 3.21...3.31)
project(my_wave_sim LANGUAGES Fortran)

find_package(wave 1.0 REQUIRED)

add_executable(sim main.f90)
target_link_libraries(sim PRIVATE wave::wave)
# Fortran .mod files found automatically
```

---

## Static vs Shared: Let the Consumer Decide

Notice that our CMakeLists.txt files use `add_library(heatmap ...)` and `add_library(wave ...)` without specifying STATIC or SHARED. The type is controlled at configure time by the consumer:

```bash
cmake -B build -DBUILD_SHARED_LIBS=ON    # .so / .dylib
cmake -B build -DBUILD_SHARED_LIBS=OFF   # .a
```

For HPC, static is often preferred (no `LD_LIBRARY_PATH` headaches on compute nodes).

---

# Part V: LLM-Powered CMake Workflows

## Why LLMs for CMake?

- CMake has an enormous surface area --- nobody remembers every command
- The boilerplate for proper install/export is tedious but critical
- Error messages are notoriously cryptic
- LLMs are good at generating structured, repetitive config --- when guided correctly

---

## Chat Prompts: Copy-Paste for Any LLM

### Prompt 1: "Make My Project Installable"

```
You are a CMake expert specializing in scientific computing (C, C++,
Fortran). I will describe my project and you will generate a complete,
modern CMakeLists.txt that:

1. Uses cmake_minimum_required with version range (floor 3.21)
2. Uses target-based commands only (no global include_directories, etc.)
3. Sets up proper install() rules with EXPORT
4. Generates a Config.cmake and ConfigVersion.cmake so others can use
   find_package(MyProject REQUIRED) and link via MyProject::MyProject
5. Handles BUILD_INTERFACE vs INSTALL_INTERFACE for include directories
6. If Fortran is involved, handles .mod file installation
7. Uses GNUInstallDirs for standard paths
8. Uses PROJECT_IS_TOP_LEVEL to guard tests/examples
9. Creates an ALIAS target for FetchContent compatibility

Do not use any deprecated CMake features. Do not use global state.
Explain any non-obvious choices in brief comments.

My project: [DESCRIBE YOUR PROJECT HERE]
```

---

### Prompt 2: "Debug My CMake Error"

```
You are a CMake debugging expert. I will paste a CMake error or warning.

Explain:
1. What the error actually means (in plain language)
2. The most likely cause in a scientific computing context
3. The fix, using modern CMake best practices

Do not suggest workarounds using deprecated commands. If the underlying
project structure is wrong, say so.

The error:
[PASTE ERROR HERE]
```

---

### Prompt 3: "Review My CMakeLists.txt"

```
You are a CMake reviewer for scientific computing projects. Review the
following CMakeLists.txt and check for:

1. Use of deprecated or global commands
2. Missing install/export rules (can others use find_package with this?)
3. Incorrect PUBLIC/PRIVATE/INTERFACE usage
4. Missing Fortran .mod file handling
5. Hardcoded paths or compiler flags
6. Missing version compatibility files
7. Whether FetchContent consumption would work

For each issue, show the fix. Be specific.

[PASTE CMAKELISTS.TXT HERE]
```

---

### Prompt 4: "Write a Find Module"

```
You are a CMake expert. I need a Find<Package>.cmake module for a
third-party library that does NOT ship its own CMake config.

Requirements:
1. Search for headers and libraries using find_path / find_library
2. Support <Package>_ROOT and ENV hints
3. Use find_package_handle_standard_args for standard REQUIRED/QUIET handling
4. Create an IMPORTED target with namespace: <Package>::<Package>
5. Set INTERFACE_INCLUDE_DIRECTORIES and IMPORTED_LOCATION on the target
6. Guard the target creation with "if(NOT TARGET ...)"

The library: [DESCRIBE LIBRARY, HEADER NAMES, LIB NAMES]
```

---

## Skill Files for LLM-Powered Editors

For tools like Claude Code, Cursor, or other LLM-powered editors that support skill or
instruction files, we provide three skills that can be dropped into any project.

### How to install

Copy the skill `.md` files into your tool's skill directory:

- Claude Code: `.claude/skills/`
- Cursor: `.cursorrules` or project rules directory
- Other tools: wherever custom instructions are loaded from

The skills are written as tool-agnostic prompts --- they describe *what to do*, not *how to call a specific tool's API*. Any LLM-powered editor that can read files and edit code can follow them.

---

### /add_cmake_build_system

**Purpose**: Scaffold a complete CMake build system on an existing repository.

**What it does**:
1. Analyzes the repo: detects languages, finds entry points (`main()` / `program`), maps source files to targets, identifies dependencies from `#include` and `use` statements
2. Presents a recommended architecture: which files become libraries, which become executables, where to split, what dependencies are PUBLIC vs PRIVATE
3. After user confirmation, generates: `CMakeLists.txt`, `cmake/<Project>Config.cmake.in`, `CMakePresets.json` (multi-compiler), install/export rules, ALIAS targets
4. Reports suggestions: library splitting, object libraries for shared compilation, visibility settings

**Key guarantee**: Every generated CMakeLists.txt is installable, exportable, and consumable via both `find_package()` and `FetchContent`. No deprecated commands. No global state.

See: `skills/add_cmake_build_system.md`

---

### /roast_my_cmake

**Purpose**: Review and critique the CMake build system in the current repo.

**What it does**:
1. Reads every `CMakeLists.txt`, `*.cmake`, and preset file in the repo
2. Scores 8 categories: Modern CMake compliance, target hygiene, installability/exportability, Fortran handling, dependency management, hardcoded sins, presets, testing
3. Each category is rated **GOOD** / **MEH** / **BAD** / **CURSED**
4. Every roast comes with the specific fix (file, line, corrected code)
5. Mandatory "what you did right" section

**Best for**: Code review, onboarding onto a new project, pre-release audits.

See: `skills/roast_my_cmake.md`

---

### /fix_my_cmake

**Purpose**: Diagnose and fix CMake errors.

**What it does**:
1. Classifies the error: configure, build, install, or consumer-side
2. Follows diagnostic trees for common scientific computing failures:
   - `find_package` failures (missing packages, wrong paths, HPC module issues)
   - Linker errors (missing libraries, wrong PUBLIC/PRIVATE, Fortran interop)
   - Fortran `.mod` file issues (wrong directory, cross-target dependencies)
   - Install/export errors (absolute path leaks, missing `find_dependency`)
3. Applies the fix directly to the CMake files
4. Verifies the fix builds
5. Explains: what was wrong, why, what changed, how to prevent it

**Best for**: When `cmake` gives you a wall of red text and you have no idea what it means.

See: `skills/fix_my_cmake.md`

---

## Summary

| What | How |
|------|-----|
| Build system | CMake is a generator --- use Ninja for speed |
| Modern style | Targets and properties, never global state |
| Target types | STATIC, SHARED, OBJECT, INTERFACE --- pick the right one |
| Properties | PUBLIC/PRIVATE/INTERFACE control what propagates to consumers |
| Generator expressions | `$<BUILD_INTERFACE:...>` / `$<INSTALL_INTERFACE:...>` for dual-mode |
| Custom modules | `cmake/` directory for Find modules and utility scripts |
| Multi-compiler | `CMakePresets.json` with preset inheritance |
| Find dependencies | `find_package()` + `CMAKE_PREFIX_PATH` for HPC |
| Pull dependencies | `FetchContent` --- works if upstream exports properly |
| Be a good package | `install(EXPORT)` + `Config.cmake` + namespaced targets |
| Fortran modules | Install `.mod` files, document compiler requirement |
| Static vs Shared | `BUILD_SHARED_LIBS` option, let consumer decide |
| LLM assistance | Guided prompts for chat, skill files for editors |

---

## Resources

- CMake documentation: https://cmake.org/cmake/help/latest/
- "It's Time To Do CMake Right" --- Pablo Arias
- "Effective Modern CMake" --- Daniel Pfeifer (CppCon talk)
- CMake Presets documentation: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html
- This presentation's repository: https://github.com/JorgeG94/teaching_cmake
