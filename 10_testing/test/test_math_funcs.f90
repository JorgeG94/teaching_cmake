module test_math_funcs
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use math_funcs, only: add, multiply, factorial, is_prime
    implicit none
    private

    public :: collect_math_tests

contains

    !> Collect all tests in this module
    subroutine collect_math_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("add_positive", test_add_positive), &
            new_unittest("add_negative", test_add_negative), &
            new_unittest("multiply_basic", test_multiply_basic), &
            new_unittest("multiply_by_zero", test_multiply_by_zero), &
            new_unittest("factorial_base", test_factorial_base), &
            new_unittest("factorial_five", test_factorial_five), &
            new_unittest("is_prime_small", test_is_prime_small), &
            new_unittest("is_prime_composite", test_is_prime_composite) &
        ]
    end subroutine collect_math_tests

    !> Test addition of positive numbers
    subroutine test_add_positive(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, add(2.0d0, 3.0d0), 5.0d0)
        if (allocated(error)) return

        call check(error, add(0.0d0, 5.0d0), 5.0d0)
    end subroutine test_add_positive

    !> Test addition with negative numbers
    subroutine test_add_negative(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, add(-2.0d0, 3.0d0), 1.0d0)
        if (allocated(error)) return

        call check(error, add(-2.0d0, -3.0d0), -5.0d0)
    end subroutine test_add_negative

    !> Test basic multiplication
    subroutine test_multiply_basic(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, multiply(2.0d0, 3.0d0), 6.0d0)
        if (allocated(error)) return

        call check(error, multiply(4.0d0, 5.0d0), 20.0d0)
    end subroutine test_multiply_basic

    !> Test multiplication by zero
    subroutine test_multiply_by_zero(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, multiply(100.0d0, 0.0d0), 0.0d0)
    end subroutine test_multiply_by_zero

    !> Test factorial base cases
    subroutine test_factorial_base(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, factorial(0), 1)
        if (allocated(error)) return

        call check(error, factorial(1), 1)
    end subroutine test_factorial_base

    !> Test factorial of 5
    subroutine test_factorial_five(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, factorial(5), 120)
    end subroutine test_factorial_five

    !> Test prime detection for small primes
    subroutine test_is_prime_small(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, is_prime(2), .true.)
        if (allocated(error)) return

        call check(error, is_prime(3), .true.)
        if (allocated(error)) return

        call check(error, is_prime(17), .true.)
    end subroutine test_is_prime_small

    !> Test prime detection for composite numbers
    subroutine test_is_prime_composite(error)
        type(error_type), allocatable, intent(out) :: error

        call check(error, is_prime(1), .false.)
        if (allocated(error)) return

        call check(error, is_prime(4), .false.)
        if (allocated(error)) return

        call check(error, is_prime(100), .false.)
    end subroutine test_is_prime_composite

end module test_math_funcs
