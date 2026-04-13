# Lesson 10: Testing

Add automated tests to your project using CTest and test-drive.

## What You'll Learn
- `enable_testing()` - enable CTest integration
- `add_test()` - register test executables
- `set_tests_properties()` - configure test behavior
- Using test-drive (Fortran unit testing framework)
- Running tests with CTest

## Build & Test

```bash
# Build the project and tests
cmake -B build
cmake --build build

# Run all tests
ctest --test-dir build

# Run with verbose output
ctest --test-dir build --output-on-failure

# Run specific tests (by name regex)
ctest --test-dir build -R "math"

# Run tests in parallel
ctest --test-dir build -j4
```

## Key Concepts

### Enabling Tests

```cmake
option(BUILD_TESTING "Build tests" ON)

if(BUILD_TESTING)
    enable_testing()  # Must be in root CMakeLists.txt!
    # ... add test targets ...
endif()
```

### Adding a Test

```cmake
# Create test executable
add_executable(my_test test/test_something.f90)
target_link_libraries(my_test PRIVATE mylib)

# Register with CTest
add_test(NAME my_test_name COMMAND my_test)
```

### Test Properties

```cmake
# Set timeout (seconds)
set_tests_properties(my_test PROPERTIES TIMEOUT 60)

# Set environment variables
set_tests_properties(my_test PROPERTIES
    ENVIRONMENT "OMP_NUM_THREADS=4"
)

# Mark as expected to fail
set_tests_properties(known_broken PROPERTIES WILL_FAIL TRUE)

# Set working directory
set_tests_properties(my_test PROPERTIES
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test
)
```

### Using test-drive

[test-drive](https://github.com/fortran-lang/test-drive) is a modern Fortran testing framework:

```cmake
FetchContent_Declare(
    test-drive
    GIT_REPOSITORY https://github.com/fortran-lang/test-drive
    GIT_TAG        v0.5.0
)
FetchContent_MakeAvailable(test-drive)

add_executable(tests test/main.f90 test/test_mymodule.f90)
target_link_libraries(tests PRIVATE test-drive::test-drive)
```

### test-drive Test Structure

```fortran
module test_mymodule
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use mymodule, only: myfunction
    implicit none

contains
    subroutine collect_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)
        testsuite = [new_unittest("test_name", test_function)]
    end subroutine

    subroutine test_function(error)
        type(error_type), allocatable, intent(out) :: error
        call check(error, myfunction(1), expected_value)
    end subroutine
end module
```

## CTest Commands

| Command | Description |
|---------|-------------|
| `ctest` | Run all tests |
| `ctest -N` | List tests without running |
| `ctest -R regex` | Run tests matching regex |
| `ctest -E regex` | Exclude tests matching regex |
| `ctest -j N` | Run N tests in parallel |
| `ctest --output-on-failure` | Show output only for failures |
| `ctest -V` | Verbose output |
| `ctest --rerun-failed` | Rerun only failed tests |

## Disabling Tests

```bash
# Build without tests
cmake -B build -DBUILD_TESTING=OFF
```

## Next Steps
In Lesson 11, we'll use custom commands to run external scripts.
