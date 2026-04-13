module test_statistics
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use statistics, only: mean, variance, std_dev, median, dp
    implicit none
    private

    public :: collect_statistics_tests

    real(dp), parameter :: tol = 1.0e-10_dp

contains

    subroutine collect_statistics_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("mean_simple", test_mean_simple), &
            new_unittest("mean_negative", test_mean_negative), &
            new_unittest("variance_uniform", test_variance_uniform), &
            new_unittest("variance_spread", test_variance_spread), &
            new_unittest("std_dev_known", test_std_dev_known), &
            new_unittest("median_odd", test_median_odd), &
            new_unittest("median_even", test_median_even), &
            new_unittest("median_unsorted", test_median_unsorted) &
        ]
    end subroutine collect_statistics_tests

    subroutine test_mean_simple(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(5), m

        x = [1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp, 5.0_dp]
        m = mean(x)

        call check(error, abs(m - 3.0_dp) < tol, &
            "Mean of [1,2,3,4,5] should be 3")
    end subroutine test_mean_simple

    subroutine test_mean_negative(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(4), m

        x = [-2.0_dp, -1.0_dp, 1.0_dp, 2.0_dp]
        m = mean(x)

        call check(error, abs(m) < tol, &
            "Mean of [-2,-1,1,2] should be 0")
    end subroutine test_mean_negative

    subroutine test_variance_uniform(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(4), v

        x = [5.0_dp, 5.0_dp, 5.0_dp, 5.0_dp]
        v = variance(x)

        call check(error, abs(v) < tol, &
            "Variance of constant array should be 0")
    end subroutine test_variance_uniform

    subroutine test_variance_spread(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(4), v

        ! Sample variance of [1,2,3,4]:
        ! mean = 2.5
        ! sum of squared deviations = (1-2.5)^2 + (2-2.5)^2 + (3-2.5)^2 + (4-2.5)^2
        !                           = 2.25 + 0.25 + 0.25 + 2.25 = 5
        ! sample variance = 5 / (4-1) = 5/3 = 1.6666...
        x = [1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp]
        v = variance(x)

        call check(error, abs(v - 5.0_dp/3.0_dp) < tol, &
            "Variance of [1,2,3,4] should be 5/3")
    end subroutine test_variance_spread

    subroutine test_std_dev_known(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(4), s, expected

        x = [1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp]
        s = std_dev(x)
        expected = sqrt(5.0_dp/3.0_dp)

        call check(error, abs(s - expected) < tol, &
            "Std dev should be sqrt(variance)")
    end subroutine test_std_dev_known

    subroutine test_median_odd(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(5), m

        x = [1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp, 5.0_dp]
        m = median(x)

        call check(error, abs(m - 3.0_dp) < tol, &
            "Median of [1,2,3,4,5] should be 3")
    end subroutine test_median_odd

    subroutine test_median_even(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(4), m

        x = [1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp]
        m = median(x)

        call check(error, abs(m - 2.5_dp) < tol, &
            "Median of [1,2,3,4] should be 2.5")
    end subroutine test_median_even

    subroutine test_median_unsorted(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: x(5), m

        x = [5.0_dp, 1.0_dp, 3.0_dp, 2.0_dp, 4.0_dp]
        m = median(x)

        call check(error, abs(m - 3.0_dp) < tol, &
            "Median should work on unsorted input")
    end subroutine test_median_unsorted

end module test_statistics
