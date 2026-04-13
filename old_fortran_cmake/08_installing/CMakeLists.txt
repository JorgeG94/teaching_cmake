# =============================================================================
# Lesson 08: Installing
# =============================================================================
# Installing makes your library/executable available system-wide (or to a
# custom prefix). This is how you distribute compiled software.
#
# Build & Install:
#   cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local
#   cmake --build build
#   cmake --install build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(installing_demo
    VERSION 1.2.3
    LANGUAGES Fortran
)

# Include GNUInstallDirs for standard directory variables
# This provides: CMAKE_INSTALL_LIBDIR, CMAKE_INSTALL_BINDIR, etc.
include(GNUInstallDirs)

# Show where things will be installed
message(STATUS "")
message(STATUS "=== Installation Directories ===")
message(STATUS "CMAKE_INSTALL_PREFIX:     ${CMAKE_INSTALL_PREFIX}")
message(STATUS "CMAKE_INSTALL_BINDIR:     ${CMAKE_INSTALL_BINDIR}")
message(STATUS "CMAKE_INSTALL_LIBDIR:     ${CMAKE_INSTALL_LIBDIR}")
message(STATUS "CMAKE_INSTALL_INCLUDEDIR: ${CMAKE_INSTALL_INCLUDEDIR}")
message(STATUS "")

# -----------------------------------------------------------------------------
# Create a library
# -----------------------------------------------------------------------------
add_library(mathlib STATIC src/math_funcs.f90)

# Fortran module output directory
set_target_properties(mathlib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Create an executable
# -----------------------------------------------------------------------------
add_executable(calculator app/main.f90)
target_link_libraries(calculator PRIVATE mathlib)
target_include_directories(calculator PRIVATE ${CMAKE_BINARY_DIR}/modules)

# -----------------------------------------------------------------------------
# Install the library
# -----------------------------------------------------------------------------
install(
    TARGETS mathlib
    EXPORT mathlibTargets           # Create an export set (for CMake config)
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}  # .a files go here
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}  # .so files go here
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}  # .dll files go here (Windows)
)

# -----------------------------------------------------------------------------
# Install the executable
# -----------------------------------------------------------------------------
install(
    TARGETS calculator
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# -----------------------------------------------------------------------------
# Install Fortran module files (.mod)
# -----------------------------------------------------------------------------
# Fortran modules are like C++ headers - needed for compilation
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/modules/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    FILES_MATCHING PATTERN "*.mod"
)

# -----------------------------------------------------------------------------
# Install header/include files (if any)
# -----------------------------------------------------------------------------
# For a Fortran project, you might have .inc files or interface files
# install(
#     DIRECTORY include/
#     DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
#     FILES_MATCHING PATTERN "*.inc"
# )

# -----------------------------------------------------------------------------
# What gets installed where (with CMAKE_INSTALL_PREFIX=/usr/local):
# -----------------------------------------------------------------------------
#
# /usr/local/
# ├── bin/
# │   └── calculator              # Executable
# ├── lib/
# │   └── libmathlib.a            # Static library
# └── include/
#     └── installing_demo/
#         └── math_funcs.mod      # Fortran module file
#
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# RPATH handling (for shared libraries)
# -----------------------------------------------------------------------------
# When using shared libraries, the executable needs to find them at runtime.
# These settings help with that:

# Use full RPATH for build tree (so tests work without installing)
set(CMAKE_SKIP_BUILD_RPATH FALSE)

# Don't use install RPATH during build
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

# Set RPATH for installed executable
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_FULL_LIBDIR}")

# Add build tree directories to RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
