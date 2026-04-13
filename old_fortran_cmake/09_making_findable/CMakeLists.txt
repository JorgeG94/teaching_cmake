# =============================================================================
# Lesson 09: Making Your Library Findable
# =============================================================================
# After installing, other projects should be able to do:
#   find_package(mathlib REQUIRED)
#   target_link_libraries(myapp PRIVATE mathlib::mathlib)
#
# This lesson shows how to create the CMake config files that enable this.
#
# Build & Install:
#   cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local
#   cmake --build build
#   cmake --install build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(mathlib
    VERSION 2.0.0
    DESCRIPTION "A simple math library for demonstration"
    LANGUAGES Fortran
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# -----------------------------------------------------------------------------
# Create the library
# -----------------------------------------------------------------------------
add_library(mathlib STATIC src/math_funcs.f90)

# Add an alias so it can be used as mathlib::mathlib even in this project
add_library(mathlib::mathlib ALIAS mathlib)

set_target_properties(mathlib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

# Set include directories for consumers
# BUILD_INTERFACE: when building this project
# INSTALL_INTERFACE: when installed and consumed by another project
target_include_directories(mathlib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
)

# -----------------------------------------------------------------------------
# Install the library
# -----------------------------------------------------------------------------
install(
    TARGETS mathlib
    EXPORT mathlibTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
)

# Install Fortran modules
install(
    DIRECTORY ${CMAKE_BINARY_DIR}/modules/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
    FILES_MATCHING PATTERN "*.mod"
)

# -----------------------------------------------------------------------------
# Install the export set (Targets file)
# -----------------------------------------------------------------------------
# This creates mathlibTargets.cmake which defines the mathlib::mathlib target
install(
    EXPORT mathlibTargets
    FILE mathlibTargets.cmake
    NAMESPACE mathlib::                    # Prefix all targets with mathlib::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# -----------------------------------------------------------------------------
# Create and install the Config file
# -----------------------------------------------------------------------------
# This is the main file that find_package() looks for.
# It should include the Targets file and handle dependencies.

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/mathlibConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/mathlibConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# -----------------------------------------------------------------------------
# Create and install the Version file
# -----------------------------------------------------------------------------
# This enables version checking: find_package(mathlib 2.0 REQUIRED)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/mathlibConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion    # 2.x compatible with 2.0, not 3.0
)

# Install both config files
install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/mathlibConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/mathlibConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

# -----------------------------------------------------------------------------
# What gets installed:
# -----------------------------------------------------------------------------
#
# $PREFIX/lib/cmake/mathlib/
# ├── mathlibConfig.cmake         # Main config (includes Targets)
# ├── mathlibConfigVersion.cmake  # Version info
# └── mathlibTargets.cmake        # Defines mathlib::mathlib target
#
# Now other projects can do:
#   find_package(mathlib 2.0 REQUIRED)
#   target_link_libraries(myapp PRIVATE mathlib::mathlib)
# -----------------------------------------------------------------------------
