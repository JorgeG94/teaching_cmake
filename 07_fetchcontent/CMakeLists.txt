# =============================================================================
# Lesson 07: FetchContent
# =============================================================================
# FetchContent downloads and builds dependencies automatically during
# CMake configuration. No need for users to manually install dependencies!
#
# Build instructions:
#   cmake -B build          # Downloads dependencies here
#   cmake --build build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(fetchcontent_demo LANGUAGES Fortran)

# Include the FetchContent module
include(FetchContent)

# -----------------------------------------------------------------------------
# Basic FetchContent usage
# -----------------------------------------------------------------------------
# 1. Declare where to get the dependency
# 2. Make it available (downloads and configures it)

# Example: Fetch stdlib (Fortran standard library)
FetchContent_Declare(
    fortran_stdlib                          # Name to reference this dependency
    GIT_REPOSITORY https://github.com/fortran-lang/stdlib.git
    GIT_TAG        v0.6.1                   # Use a specific tag/branch/commit
)

# This downloads and runs the dependency's CMakeLists.txt
# After this, all targets from stdlib are available
FetchContent_MakeAvailable(fortran_stdlib)

# -----------------------------------------------------------------------------
# Verbose/quiet control
# -----------------------------------------------------------------------------
# During development, you might want to see download progress.
# In CI, you might want it quiet.

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(FETCHCONTENT_QUIET FALSE)
else()
    set(FETCHCONTENT_QUIET TRUE)
endif()

# -----------------------------------------------------------------------------
# Create a helper macro for cleaner fetching
# -----------------------------------------------------------------------------
# This pattern is used in metalquicha's sample_utils.cmake

macro(fetch_fortran_package name url tag)
    message(STATUS "Fetching ${name} from ${url} (${tag})")

    FetchContent_Declare(
        ${name}
        GIT_REPOSITORY ${url}
        GIT_TAG        ${tag}
    )
    FetchContent_MakeAvailable(${name})

    # Create a namespaced alias if one doesn't exist
    # This makes usage consistent: always use name::name
    if(NOT TARGET ${name}::${name})
        if(TARGET ${name})
            add_library(${name}::${name} ALIAS ${name})
        endif()
    endif()
endmacro()

# -----------------------------------------------------------------------------
# Using the helper macro
# -----------------------------------------------------------------------------
# Uncomment to fetch additional packages:
#
# fetch_fortran_package(
#     "test-drive"
#     "https://github.com/fortran-lang/test-drive"
#     "v0.5.0"
# )

# -----------------------------------------------------------------------------
# Create the executable
# -----------------------------------------------------------------------------
add_executable(demo main.f90)

# Link to the fetched stdlib
# The target name depends on what the fetched project defines
# stdlib provides: fortran_stdlib (or check their CMakeLists.txt)
target_link_libraries(demo PRIVATE fortran_stdlib)

# Need to tell our code where to find the .mod files
# FetchContent provides ${<name>_BINARY_DIR} for this
target_include_directories(demo PRIVATE
    ${fortran_stdlib_BINARY_DIR}/src/stdlib
)

# -----------------------------------------------------------------------------
# FetchContent options and tips
# -----------------------------------------------------------------------------

# 1. Use specific tags, not "main" - for reproducible builds
#    GIT_TAG v1.2.3        # Good: specific version
#    GIT_TAG main          # Bad: can change unexpectedly

# 2. For large repos, use shallow clone:
#    GIT_SHALLOW TRUE

# 3. Download from URL instead of git (for releases):
#    FetchContent_Declare(
#        mylib
#        URL https://github.com/org/repo/archive/v1.0.0.tar.gz
#        URL_HASH SHA256=abc123...
#    )

# 4. Check if already fetched (avoid duplicate work):
#    FetchContent_GetProperties(mylib)
#    if(NOT mylib_POPULATED)
#        FetchContent_Populate(mylib)
#        add_subdirectory(${mylib_SOURCE_DIR} ${mylib_BINARY_DIR})
#    endif()

# 5. Override with local copy (for development):
#    cmake -B build -DFETCHCONTENT_SOURCE_DIR_MYLIB=/path/to/local/mylib
