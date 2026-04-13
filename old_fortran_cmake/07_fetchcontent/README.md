# Lesson 07: FetchContent

Automatically download and build dependencies - no manual installation needed.

## What You'll Learn
- `FetchContent_Declare()` - specify where to get a dependency
- `FetchContent_MakeAvailable()` - download and configure it
- Best practices for reproducible builds
- Creating reusable fetch macros

## Build & Run

```bash
# First build takes longer (downloads dependencies)
cmake -B build
cmake --build build
./build/demo

# Subsequent builds are fast (already cached)
cmake --build build
```

## Key Concepts

### Basic Pattern

```cmake
include(FetchContent)

FetchContent_Declare(
    dependency_name
    GIT_REPOSITORY https://github.com/org/repo.git
    GIT_TAG        v1.0.0    # Always pin a specific version!
)

FetchContent_MakeAvailable(dependency_name)

# Now targets from dependency_name are available
target_link_libraries(myapp PRIVATE dependency_name)
```

### Available Variables After Fetch

| Variable | Description |
|----------|-------------|
| `${name}_SOURCE_DIR` | Where source was downloaded |
| `${name}_BINARY_DIR` | Where it's being built |
| `${name}_POPULATED` | TRUE if already fetched |

### Best Practices

**1. Always pin specific versions:**
```cmake
GIT_TAG v1.2.3          # Good: reproducible
GIT_TAG main            # Bad: may break unexpectedly
```

**2. For releases, prefer URL over git:**
```cmake
FetchContent_Declare(
    mylib
    URL https://github.com/org/repo/archive/v1.0.tar.gz
    URL_HASH SHA256=abc123...  # Verify integrity
)
```

**3. Use shallow clones for faster downloads:**
```cmake
FetchContent_Declare(
    mylib
    GIT_REPOSITORY https://github.com/org/repo.git
    GIT_TAG        v1.0.0
    GIT_SHALLOW    TRUE    # Don't download full history
)
```

**4. Override with local source (for development):**
```bash
cmake -B build -DFETCHCONTENT_SOURCE_DIR_MYLIB=/path/to/local/mylib
```

### Creating a Reusable Macro

```cmake
macro(fetch_fortran_package name url tag)
    message(STATUS "Fetching ${name} from ${url} (${tag})")

    FetchContent_Declare(
        ${name}
        GIT_REPOSITORY ${url}
        GIT_TAG        ${tag}
    )
    FetchContent_MakeAvailable(${name})

    # Create namespaced alias for consistency
    if(NOT TARGET ${name}::${name})
        if(TARGET ${name})
            add_library(${name}::${name} ALIAS ${name})
        endif()
    endif()
endmacro()

# Usage:
fetch_fortran_package("test-drive" "https://github.com/fortran-lang/test-drive" "v0.5.0")
target_link_libraries(myapp PRIVATE test-drive::test-drive)
```

### Integrating with find_package

A common pattern: try `find_package` first, fall back to `FetchContent`:

```cmake
find_package(mylib QUIET)

if(NOT mylib_FOUND)
    message(STATUS "mylib not found, fetching...")
    FetchContent_Declare(
        mylib
        GIT_REPOSITORY https://github.com/org/mylib.git
        GIT_TAG        v1.0.0
    )
    FetchContent_MakeAvailable(mylib)
endif()
```

This respects system installations while providing a fallback.

### Where Are Downloads Cached?

By default: `${CMAKE_BINARY_DIR}/_deps/`

You can change this:
```cmake
set(FETCHCONTENT_BASE_DIR /path/to/cache)
```

Or share across projects:
```bash
export FETCHCONTENT_BASE_DIR=$HOME/.cmake-fetchcontent-cache
```

## Next Steps
In Lesson 08, we'll learn how to install your project so others can use it.
