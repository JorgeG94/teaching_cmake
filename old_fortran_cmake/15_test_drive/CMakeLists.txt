# =============================================================================
# Lesson 15: Unit Testing with test-drive and CTest
# =============================================================================
# This lesson shows how to properly integrate test-drive (the modern Fortran
# unit testing framework) with CMake's CTest for comprehensive testing.
#
# Build & Test:
#   cmake -B build
#   cmake --build build
#   ctest --test-dir build --output-on-failure
#
# Or run specific tests:
#   ctest --test-dir build -R "vector"
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(test_drive_demo
    VERSION 1.0.0
    LANGUAGES Fortran
)

include(FetchContent)

# -----------------------------------------------------------------------------
# Build the library to be tested
# -----------------------------------------------------------------------------
add_library(mathlib STATIC
    src/vector_ops.f90
    src/matrix_ops.f90
    src/statistics.f90
)

set_target_properties(mathlib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Testing configuration
# -----------------------------------------------------------------------------
option(BUILD_TESTING "Build unit tests" ON)

if(BUILD_TESTING)
    enable_testing()

    # -------------------------------------------------------------------------
    # Fetch test-drive
    # -------------------------------------------------------------------------
    FetchContent_Declare(
        test-drive
        GIT_REPOSITORY https://github.com/fortran-lang/test-drive
        GIT_TAG        v0.5.0
    )
    FetchContent_MakeAvailable(test-drive)

    # -------------------------------------------------------------------------
    # Create test executable with all test suites
    # -------------------------------------------------------------------------
    add_executable(unit_tests
        test/main.f90
        test/test_vector_ops.f90
        test/test_matrix_ops.f90
        test/test_statistics.f90
    )

    target_link_libraries(unit_tests PRIVATE
        mathlib
        test-drive
    )

    target_include_directories(unit_tests PRIVATE
        ${CMAKE_BINARY_DIR}/modules
    )

    # -------------------------------------------------------------------------
    # Register with CTest - Multiple approaches
    # -------------------------------------------------------------------------

    # Approach 1: Single test for all suites (simple)
    add_test(
        NAME all_unit_tests
        COMMAND unit_tests
    )

    # Approach 2: Separate tests per module (better CI reporting)
    # test-drive supports --filter to run specific test suites
    add_test(
        NAME test_vector_ops
        COMMAND unit_tests --filter "vector_ops"
    )
    add_test(
        NAME test_matrix_ops
        COMMAND unit_tests --filter "matrix_ops"
    )
    add_test(
        NAME test_statistics
        COMMAND unit_tests --filter "statistics"
    )

    # -------------------------------------------------------------------------
    # Test properties
    # -------------------------------------------------------------------------

    # Set timeout for all tests
    set_tests_properties(
        all_unit_tests
        test_vector_ops
        test_matrix_ops
        test_statistics
        PROPERTIES TIMEOUT 60
    )

    # Label tests for selective running (ctest -L unit)
    set_tests_properties(
        test_vector_ops
        test_matrix_ops
        test_statistics
        PROPERTIES LABELS "unit"
    )

    # Mark the "all" test as a comprehensive test
    set_tests_properties(all_unit_tests PROPERTIES LABELS "comprehensive")

    # -------------------------------------------------------------------------
    # Optional: Add a separate integration test executable
    # -------------------------------------------------------------------------
    add_executable(integration_tests
        test/integration/main.f90
        test/integration/test_full_workflow.f90
    )

    target_link_libraries(integration_tests PRIVATE
        mathlib
        test-drive
    )

    target_include_directories(integration_tests PRIVATE
        ${CMAKE_BINARY_DIR}/modules
    )

    add_test(
        NAME integration_tests
        COMMAND integration_tests
    )

    set_tests_properties(integration_tests
        PROPERTIES
            LABELS "integration"
            TIMEOUT 120
    )

endif()

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "=== Test Configuration ===")
message(STATUS "BUILD_TESTING: ${BUILD_TESTING}")
if(BUILD_TESTING)
    message(STATUS "")
    message(STATUS "Run all tests:        ctest --test-dir build")
    message(STATUS "Run unit tests:       ctest --test-dir build -L unit")
    message(STATUS "Run integration:      ctest --test-dir build -L integration")
    message(STATUS "Run specific suite:   ctest --test-dir build -R vector")
    message(STATUS "Verbose output:       ctest --test-dir build -V")
endif()
message(STATUS "")
