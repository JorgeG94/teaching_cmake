# Lesson 13: Subdirectories

Organize larger projects using `add_subdirectory()`.

## What You'll Learn
- `add_subdirectory()` - include other CMakeLists.txt files
- Variable scope and `PARENT_SCOPE`
- Project organization patterns
- Component-based builds

## Project Structure

```
13_subdirectories/
├── CMakeLists.txt           # Root: project definition, orchestration
├── cmake/
│   └── CMakeLists.txt       # Compiler flags, build options
├── src/
│   ├── CMakeLists.txt       # Main library, collects components
│   ├── core/
│   │   ├── CMakeLists.txt   # Core component sources
│   │   └── core_module.f90
│   └── utils/
│       ├── CMakeLists.txt   # Utils component sources
│       └── utils_module.f90
├── app/
│   ├── CMakeLists.txt       # Executable target
│   └── main.f90
└── test/
    ├── CMakeLists.txt       # Test targets
    └── test_core.f90
```

## Build & Run

```bash
cmake -B build
cmake --build build
./build/app/demo
ctest --test-dir build
```

## Key Concepts

### add_subdirectory()

```cmake
add_subdirectory(src)    # Process src/CMakeLists.txt
add_subdirectory(app)    # Process app/CMakeLists.txt
```

Subdirectories are processed in order. Targets and variables defined earlier are available to later subdirectories.

### Variable Scope

Variables set in a subdirectory are local to that scope:

```cmake
# In subdir/CMakeLists.txt:
set(MY_VAR "value")           # Only visible in subdir/
set(MY_VAR "value" PARENT_SCOPE)  # Visible in parent
```

**Important**: `PARENT_SCOPE` sets the variable in the parent only, not the current scope. To have it in both:

```cmake
set(MY_VAR "value")
set(MY_VAR "value" PARENT_SCOPE)
```

### Useful Directory Variables

| Variable | Description |
|----------|-------------|
| `CMAKE_CURRENT_SOURCE_DIR` | Source dir of current CMakeLists.txt |
| `CMAKE_CURRENT_BINARY_DIR` | Build dir for current CMakeLists.txt |
| `CMAKE_SOURCE_DIR` | Top-level source directory |
| `CMAKE_BINARY_DIR` | Top-level build directory |
| `PROJECT_SOURCE_DIR` | Source dir of most recent `project()` |
| `PROJECT_BINARY_DIR` | Build dir of most recent `project()` |

### Common Organization Patterns

**Pattern 1: Sources in subdirectories, library at top**
```cmake
# Root CMakeLists.txt
add_library(mylib STATIC)
add_subdirectory(src/component1)
add_subdirectory(src/component2)
target_sources(mylib PRIVATE ${COMPONENT1_SRCS} ${COMPONENT2_SRCS})
```

**Pattern 2: Library defined in src/**
```cmake
# Root
add_subdirectory(src)  # Defines library
add_subdirectory(app)  # Uses library
```

**Pattern 3: Each component is its own library**
```cmake
add_subdirectory(src/core)    # Creates core_lib
add_subdirectory(src/utils)   # Creates utils_lib
add_library(mylib INTERFACE)
target_link_libraries(mylib INTERFACE core_lib utils_lib)
```

### Conditional Subdirectories

```cmake
option(BUILD_TESTING "Build tests" ON)
option(BUILD_DOCS "Build documentation" OFF)

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
endif()

if(BUILD_DOCS)
    add_subdirectory(docs)
endif()
```

### Order Matters

```cmake
# cmake/ sets compiler flags - must come first
add_subdirectory(cmake)

# src/ defines library - must come before app/
add_subdirectory(src)

# app/ uses the library
add_subdirectory(app)

# test/ uses the library
add_subdirectory(test)
```

## Next Steps
In Lesson 14, we'll learn about CMakePresets.json for reproducible builds.
