# Lesson 11: Custom Commands

Run external scripts and tools as part of your build process.

## What You'll Learn
- `add_custom_command()` - generate files or run post-build steps
- `add_custom_target()` - create targets that run commands
- File generation at configure vs build time
- Processing source files with external scripts

## Build & Run

```bash
cmake -B build
cmake --build build
./build/demo

# Run the info target
cmake --build build --target show_info
```

## Key Concepts

### add_custom_command - Generate Output Files

Creates a rule to generate files. Only runs when the output is needed.

```cmake
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/generated.f90     # What it creates
    COMMAND my_generator --output generated.f90  # How to create it
    DEPENDS ${CMAKE_SOURCE_DIR}/input.txt        # Rebuild triggers
    COMMENT "Generating source file..."          # Progress message
)

# Use the generated file in a target
add_library(mylib ${CMAKE_BINARY_DIR}/generated.f90)
```

### add_custom_command - Post/Pre Build

Run commands before or after building a target:

```cmake
add_custom_command(
    TARGET myexe
    POST_BUILD                                   # or PRE_BUILD, PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E echo "Done!"
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:myexe> /some/path/
)
```

### add_custom_target - Always Runs

Unlike custom commands, custom targets always run when invoked:

```cmake
add_custom_target(docs
    COMMAND doxygen Doxyfile
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Generating documentation"
)

# Build with: cmake --build build --target docs
```

### Configure-Time vs Build-Time

**Configure time** (during `cmake ..`):
```cmake
file(WRITE ${CMAKE_BINARY_DIR}/config.f90 "...")
execute_process(COMMAND generate_something OUTPUT_FILE output.txt)
```

**Build time** (during `make`):
```cmake
add_custom_command(OUTPUT file.f90 COMMAND generator ...)
```

### The GAMESS Pattern: Processing Source Files

```cmake
function(copy_and_process src_files output_var)
    set(processed)
    foreach(src IN LISTS src_files)
        get_filename_component(name ${src} NAME_WE)
        set(dest "${CMAKE_BINARY_DIR}/source/${name}.f90")

        add_custom_command(
            OUTPUT ${dest}
            COMMAND ${CMAKE_COMMAND} -E copy ${src} ${dest}
            COMMAND ${CMAKE_SOURCE_DIR}/tools/addomp.sh ${dest}
            DEPENDS ${src}
            COMMENT "Processing ${name}"
        )
        list(APPEND processed ${dest})
    endforeach()
    set(${output_var} ${processed} PARENT_SCOPE)
endfunction()
```

### CMake -E: Cross-Platform Commands

CMake provides portable command-line operations:

```cmake
# Copy file
COMMAND ${CMAKE_COMMAND} -E copy src dest

# Create directory
COMMAND ${CMAKE_COMMAND} -E make_directory dir

# Remove file
COMMAND ${CMAKE_COMMAND} -E remove file

# Echo message
COMMAND ${CMAKE_COMMAND} -E echo "Hello"

# Compare files
COMMAND ${CMAKE_COMMAND} -E compare_files file1 file2

# Create symlink
COMMAND ${CMAKE_COMMAND} -E create_symlink target link
```

### Generator Expressions

Use generator expressions for build-type-specific paths:

```cmake
add_custom_command(
    TARGET myexe POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:myexe>
        ${CMAKE_BINARY_DIR}/bin/$<CONFIG>/
)
```

## Common Patterns

### Generate version info at configure time:
```cmake
file(WRITE ${CMAKE_BINARY_DIR}/version.f90
"module version
    character(*), parameter :: VERSION = \"${PROJECT_VERSION}\"
end module")
```

### Embed git hash:
```cmake
execute_process(
    COMMAND git rev-parse --short HEAD
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
```

### Run after successful build:
```cmake
add_custom_command(TARGET myexe POST_BUILD
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
    COMMENT "Running tests..."
)
```

## Next Steps
In Lesson 12, we'll learn to set different compile flags for specific files.
