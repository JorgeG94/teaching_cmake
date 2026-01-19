# =============================================================================
# Lesson 10: Testing
# =============================================================================
# CMake has built-in support for testing via CTest. This lesson shows
# how to add tests and integrate with test-drive (a Fortran testing framework).
#
# Build & Test:
#   cmake -B build
#   cmake --build build
#   ctest --test-dir build --output-on-failure
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(testing_demo LANGUAGES Fortran)

include(FetchContent)

# -----------------------------------------------------------------------------
# Build the library to be tested
# -----------------------------------------------------------------------------
add_library(mathlib STATIC src/math_funcs.f90)
set_target_properties(mathlib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Enable testing
# -----------------------------------------------------------------------------
# This must be called in the root CMakeLists.txt (not a subdirectory)
# to enable the 'test' target and CTest integration.

option(BUILD_TESTING "Build the testing tree" ON)

if(BUILD_TESTING)
    enable_testing()

    # -------------------------------------------------------------------------
    # Fetch test-drive (Fortran unit testing framework)
    # -------------------------------------------------------------------------
    FetchContent_Declare(
        test-drive
        GIT_REPOSITORY https://github.com/fortran-lang/test-drive
        GIT_TAG        v0.5.0
    )
    FetchContent_MakeAvailable(test-drive)

    # -------------------------------------------------------------------------
    # Create test executable
    # -------------------------------------------------------------------------
    add_executable(test_mathlib
        test/main.f90
        test/test_math_funcs.f90
    )

    target_link_libraries(test_mathlib PRIVATE
        mathlib
        test-drive::test-drive
    )

    target_include_directories(test_mathlib PRIVATE
        ${CMAKE_BINARY_DIR}/modules
    )

    # -------------------------------------------------------------------------
    # Register tests with CTest
    # -------------------------------------------------------------------------
    # Simple: register the whole test executable as one test
    add_test(
        NAME mathlib_tests
        COMMAND test_mathlib
    )

    # You can also run specific test suites:
    # add_test(NAME test_add COMMAND test_mathlib --filter="test_add*")

    # -------------------------------------------------------------------------
    # Test properties
    # -------------------------------------------------------------------------
    # Set a timeout (in seconds)
    set_tests_properties(mathlib_tests PROPERTIES TIMEOUT 60)

    # Set environment variables for tests
    # set_tests_properties(mathlib_tests PROPERTIES
    #     ENVIRONMENT "OMP_NUM_THREADS=4"
    # )

    # Mark a test as expected to fail
    # set_tests_properties(known_failing_test PROPERTIES WILL_FAIL TRUE)

    # -------------------------------------------------------------------------
    # Basic tests without a framework
    # -------------------------------------------------------------------------
    # You can also add simple executable tests without test-drive

    add_executable(test_basic test/test_basic.f90)
    target_link_libraries(test_basic PRIVATE mathlib)
    target_include_directories(test_basic PRIVATE ${CMAKE_BINARY_DIR}/modules)

    add_test(
        NAME basic_sanity_test
        COMMAND test_basic
    )

endif()

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "=== Test Configuration ===")
message(STATUS "BUILD_TESTING: ${BUILD_TESTING}")
if(BUILD_TESTING)
    message(STATUS "Run tests with: ctest --test-dir build --output-on-failure")
endif()
message(STATUS "")
