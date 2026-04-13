# /add_cmake_build_system

Analyze the current repository and generate a complete, modern CMake build system that is installable, exportable, and consumable via both `find_package()` and `FetchContent`.

## Step 1: Analyze the Repository

Scan the repository thoroughly before generating anything.

### Detect languages

- Look for file extensions: `.c`, `.h` (C), `.cpp`, `.cxx`, `.cc`, `.hpp`, `.hxx` (C++), `.f`, `.f90`, `.f95`, `.f03`, `.f08`, `.F90` (Fortran), `.cu` (CUDA)
- Report which languages are present

### Detect existing build systems

- Check for: `Makefile`, `makefile`, `GNUmakefile`, `configure.ac`, `configure.in`, `meson.build`, `CMakeLists.txt`, `Cargo.toml`, `build.zig`
- If a CMake build system already exists, **stop and ask** the user if they want to replace it or augment it
- If a Makefile or autotools setup exists, try to extract useful information from it:
  - Compiler flags being used
  - Libraries being linked (`-l` flags, `pkg-config` calls)
  - Install targets and their destinations

### Map the source tree

- Identify all source files and header files
- Find entry points: files containing `main(` (C/C++) or `program ` (Fortran)
- Find Fortran module definitions (`module <name>`) and their `use` dependencies
- Identify header files that constitute the public API (typically in `include/` or top-level)
- Note any source files that `#include` or `use` third-party libraries

### Classify targets

For each group of source files, determine if it should be:

- **An executable**: has a `main()` or `program` entry point
- **A library**: collection of functions/modules used by executables or other libraries
- **Multiple libraries**: if there are clear subsystems (e.g., `src/core/`, `src/io/`, `src/solver/`) that could be independent

## Step 2: Recommend Architecture to the User

Before generating files, present a summary and ask for confirmation:

```
I analyzed the repository and here is what I recommend:

Languages detected: C, C++, Fortran
Entry points found: src/main.cpp, tools/convert.cpp

Recommended targets:
  - myproject (LIBRARY): src/core/*.cpp, src/solver/*.f90
    -> This is the main library containing the bulk of the code
  - myproject_app (EXECUTABLE): src/main.cpp -> links myproject
  - convert_tool (EXECUTABLE): tools/convert.cpp -> links myproject

Dependencies detected (from includes/linking):
  - MPI (used in solver/*.f90)
  - LAPACK (used in core/linalg.cpp)
  - HDF5 (used in core/io.cpp)

Suggestions:
  - Consider splitting core/ and solver/ into separate libraries
    if they have independent consumers
  - src/utils.cpp is included by everything --- good candidate
    for an OBJECT library to avoid compiling twice
  - The Fortran modules in solver/ define types used in the public
    API --- MPI will need to be a PUBLIC dependency

Shall I proceed with this layout?
```

## Step 3: Generate the Build System

Generate the following files. Use the project name derived from the repository directory name, or ask the user.

### CMakeLists.txt (top-level)

Requirements --- every generated CMakeLists.txt MUST:

- Use `cmake_minimum_required(VERSION 3.21...3.31)` with version range
- Use `project()` with VERSION, LANGUAGES, and DESCRIPTION
- Block in-source builds
- Include `GNUInstallDirs`
- Guard tests/examples with `PROJECT_IS_TOP_LEVEL`
- Use ONLY target-based commands --- never use:
  - `include_directories()`
  - `link_directories()`
  - `link_libraries()`
  - `add_definitions()`
  - `add_compile_options()` at directory scope
- Create an ALIAS target with namespace: `add_library(project::target ALIAS target)`
- Set `target_include_directories` with both `BUILD_INTERFACE` and `INSTALL_INTERFACE`
- If Fortran: set `Fortran_MODULE_DIRECTORY` and add the mod dir to include paths
- Set `VERSION` and `SOVERSION` properties on libraries
- Use `PRIVATE` for internal dependencies, `PUBLIC` for dependencies that appear in public headers or Fortran module interfaces

### Install and Export Rules

Every library target must have:

```cmake
install(TARGETS <target>
  EXPORT <project>Targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/<project>
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# If Fortran
install(DIRECTORY ${<PROJECT>_Fortran_MODULE_DIR}/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT <project>Targets
  NAMESPACE <project>::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<project>
)
```

### cmake/<Project>Config.cmake.in

```cmake
@PACKAGE_INIT@

include(CMakeFindDependencyMacro)

# List only PUBLIC dependencies here
# find_dependency(MPI COMPONENTS C Fortran)
# find_dependency(SomeOtherPublicDep)

include("${CMAKE_CURRENT_LIST_DIR}/<project>Targets.cmake")

check_required_components(<project>)
```

### CMakePresets.json

Generate presets based on which languages are present:

- Always include: `gcc-debug`, `gcc-release`
- If C/C++ present: add `clang-debug`, `clang-release`
- If Fortran present: add `intel-release` (ifx), `nvhpc-release` (nvfortran)
- Use a hidden base preset with `"generator": "Ninja"` and `CMAKE_EXPORT_COMPILE_COMMANDS: ON`
- Include build presets and test presets that reference configure presets

### tests/CMakeLists.txt

If test files exist, generate a test CMakeLists.txt using CTest:

```cmake
add_executable(test_<name> test_<name>.cpp)
target_link_libraries(test_<name> PRIVATE <project>::<target>)
add_test(NAME <name> COMMAND test_<name>)
```

## Step 4: Report

After generating all files, print a summary:

```
Generated CMake build system for <project>:

Files created:
  - CMakeLists.txt
  - cmake/<project>Config.cmake.in
  - CMakePresets.json
  - tests/CMakeLists.txt

To build:
  cmake --preset gcc-debug
  cmake --build --preset gcc-debug

To install:
  cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/local
  cmake --build build
  cmake --install build

To consume from another project:
  find_package(<project> REQUIRED)
  target_link_libraries(myapp PRIVATE <project>::<target>)

Optimization suggestions:
  - [any suggestions from analysis]
```

## Rules

- NEVER generate CMake that uses deprecated or global commands
- NEVER hardcode compiler paths or flags --- use presets or generator expressions
- NEVER skip the install/export rules --- the whole point is making the package consumable
- If you are unsure about something (e.g., whether a dependency is PUBLIC or PRIVATE), ASK the user rather than guessing
- If the project already has a partial CMakeLists.txt, preserve any custom logic and integrate it rather than overwriting blindly
