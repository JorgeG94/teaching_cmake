# Lesson 15: Unit Testing with test-drive and CTest

Comprehensive unit testing for Fortran using test-drive framework integrated with CTest.

## What You'll Learn
- Setting up test-drive with FetchContent
- Writing test modules with test suites
- Registering tests with CTest (multiple approaches)
- Running specific test suites
- Separating unit tests and integration tests
- Test labels and filtering

## Build & Test

```bash
# Build everything
cmake -B build
cmake --build build

# Run all tests
ctest --test-dir build --output-on-failure

# Run only unit tests (by label)
ctest --test-dir build -L unit

# Run only integration tests
ctest --test-dir build -L integration

# Run tests matching a pattern
ctest --test-dir build -R "vector"
ctest --test-dir build -R "matrix"

# Verbose output
ctest --test-dir build -V
```

## Project Structure

```
15_test_drive/
├── CMakeLists.txt
├── src/
│   ├── vector_ops.f90      # Module to test
│   ├── matrix_ops.f90
│   └── statistics.f90
└── test/
    ├── main.f90            # Test driver
    ├── test_vector_ops.f90 # Test suite
    ├── test_matrix_ops.f90
    ├── test_statistics.f90
    └── integration/
        ├── main.f90        # Integration test driver
        └── test_full_workflow.f90
```

## Key Concepts

### test-drive Test Structure

**Test module pattern:**
```fortran
module test_mymodule
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use mymodule, only: myfunction, dp
    implicit none
    private
    public :: collect_tests

    real(dp), parameter :: tol = 1.0e-12_dp

contains
    subroutine collect_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)
        testsuite = [ &
            new_unittest("test_name", test_function), &
            new_unittest("another_test", another_test_function) &
        ]
    end subroutine

    subroutine test_function(error)
        type(error_type), allocatable, intent(out) :: error
        call check(error, myfunction(1) == expected, "message")
    end subroutine
end module
```

**Test driver (main.f90):**
```fortran
program tests
    use testdrive, only: run_testsuite, new_testsuite, testsuite_type
    use test_mymodule, only: collect_tests
    implicit none

    type(testsuite_type), allocatable :: testsuites(:)
    integer :: stat

    stat = 0
    testsuites = [new_testsuite("mymodule", collect_tests)]

    call run_testsuite(testsuites(1)%collect, error_unit, stat)

    if (stat > 0) error stop
end program
```

### CTest Integration Approaches

**Approach 1: Single test executable**
```cmake
add_test(NAME all_tests COMMAND unit_tests)
```
Simple, but CI shows only pass/fail for entire suite.

**Approach 2: Separate CTest entries per module**
```cmake
add_test(NAME test_vector COMMAND unit_tests --filter "vector")
add_test(NAME test_matrix COMMAND unit_tests --filter "matrix")
```
Better CI reporting - each module shows separately.

### Test Labels

Group tests for selective running:

```cmake
set_tests_properties(test_vector test_matrix
    PROPERTIES LABELS "unit")

set_tests_properties(integration_tests
    PROPERTIES LABELS "integration")
```

Run by label:
```bash
ctest -L unit           # Only unit tests
ctest -L integration    # Only integration tests
ctest -LE integration   # Exclude integration tests
```

### Test Properties

```cmake
# Timeout
set_tests_properties(my_test PROPERTIES TIMEOUT 60)

# Environment variables
set_tests_properties(my_test PROPERTIES
    ENVIRONMENT "OMP_NUM_THREADS=4")

# Working directory
set_tests_properties(my_test PROPERTIES
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/data)

# Expected failure
set_tests_properties(known_broken PROPERTIES WILL_FAIL TRUE)
```

### Using iso_fortran_env for Precision

Always use proper kind parameters:

```fortran
use, intrinsic :: iso_fortran_env, only: dp => real64

real(dp), parameter :: tol = 1.0e-12_dp
real(dp) :: x = 1.0_dp
```

Export `dp` from your modules so tests can use it:
```fortran
public :: myfunction, dp
```

## test-drive Check Functions

```fortran
! Boolean check
call check(error, condition, "message")

! Equality (with tolerance for reals)
call check(error, computed, expected)

! Skip a test
call skip_test(error, "reason to skip")
```

## CTest Useful Commands

| Command | Description |
|---------|-------------|
| `ctest` | Run all tests |
| `ctest -N` | List tests without running |
| `ctest -R pattern` | Run tests matching regex |
| `ctest -E pattern` | Exclude tests matching regex |
| `ctest -L label` | Run tests with label |
| `ctest -LE label` | Exclude tests with label |
| `ctest -j N` | Run N tests in parallel |
| `ctest --output-on-failure` | Show output only for failures |
| `ctest -V` | Verbose output |
| `ctest --rerun-failed` | Rerun only failed tests |
| `ctest --timeout N` | Override timeout (seconds) |

## CI Integration Example

```yaml
# .github/workflows/test.yml
- name: Build
  run: |
    cmake -B build
    cmake --build build

- name: Unit Tests
  run: ctest --test-dir build -L unit --output-on-failure

- name: Integration Tests
  run: ctest --test-dir build -L integration --output-on-failure
```
