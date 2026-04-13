# =============================================================================
# Lesson 13: Subdirectories
# =============================================================================
# As projects grow, organizing code into subdirectories keeps things manageable.
# This lesson shows how to structure a multi-component project.
#
# Project structure:
#   13_subdirectories/
#   ├── CMakeLists.txt          (this file - root)
#   ├── cmake/
#   │   └── CMakeLists.txt      (compiler flags, options)
#   ├── src/
#   │   ├── CMakeLists.txt      (library sources)
#   │   ├── core/
#   │   │   └── CMakeLists.txt
#   │   └── utils/
#   │       └── CMakeLists.txt
#   ├── app/
#   │   └── CMakeLists.txt      (executable)
#   └── test/
#       └── CMakeLists.txt      (tests)
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(subdirectories_demo
    VERSION 1.0.0
    LANGUAGES Fortran
)

# -----------------------------------------------------------------------------
# Include cmake/ subdirectory first (sets up flags, options)
# -----------------------------------------------------------------------------
# This is processed before other subdirectories, so variables set here
# (like compiler flags) affect everything else.
add_subdirectory(cmake)

# -----------------------------------------------------------------------------
# Options defined at the top level
# -----------------------------------------------------------------------------
option(BUILD_TESTING "Build tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)

# Variables that child CMakeLists.txt can use
set(PROJECT_MODULE_DIR ${CMAKE_BINARY_DIR}/modules)

# -----------------------------------------------------------------------------
# Add the main library (src/)
# -----------------------------------------------------------------------------
# The src/CMakeLists.txt defines the library and its sources
add_subdirectory(src)

# -----------------------------------------------------------------------------
# Add the executable (app/)
# -----------------------------------------------------------------------------
add_subdirectory(app)

# -----------------------------------------------------------------------------
# Add tests (test/) - conditional
# -----------------------------------------------------------------------------
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
endif()

# -----------------------------------------------------------------------------
# Scope and PARENT_SCOPE explained
# -----------------------------------------------------------------------------
# Variables set in a subdirectory are NOT visible in the parent by default.
# Use PARENT_SCOPE to propagate them up:
#
#   # In subdirectory:
#   set(MY_VAR "value" PARENT_SCOPE)
#
# After add_subdirectory(subdir), MY_VAR is available in the parent.
#
# Note: When using PARENT_SCOPE, the variable is NOT set in the current
# scope, only in the parent. If you need it in both:
#   set(MY_VAR "value")
#   set(MY_VAR "value" PARENT_SCOPE)

# -----------------------------------------------------------------------------
# Variables available in subdirectories
# -----------------------------------------------------------------------------
# CMAKE_CURRENT_SOURCE_DIR - source dir of current CMakeLists.txt
# CMAKE_CURRENT_BINARY_DIR - build dir for current CMakeLists.txt
# CMAKE_SOURCE_DIR         - top-level source directory
# CMAKE_BINARY_DIR         - top-level build directory
# PROJECT_SOURCE_DIR       - source dir of most recent project()
# PROJECT_BINARY_DIR       - build dir of most recent project()

message(STATUS "")
message(STATUS "=== Directory Structure Demo ===")
message(STATUS "CMAKE_SOURCE_DIR:         ${CMAKE_SOURCE_DIR}")
message(STATUS "CMAKE_BINARY_DIR:         ${CMAKE_BINARY_DIR}")
message(STATUS "PROJECT_SOURCE_DIR:       ${PROJECT_SOURCE_DIR}")
message(STATUS "")
