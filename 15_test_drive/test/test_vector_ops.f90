module test_vector_ops
    use testdrive, only: new_unittest, unittest_type, error_type, check, skip_test
    use vector_ops, only: vec_add, vec_dot, vec_norm, vec_normalize, dp
    implicit none
    private

    public :: collect_vector_tests

    ! Tolerance for floating point comparisons
    real(dp), parameter :: tol = 1.0e-12_dp

contains

    subroutine collect_vector_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("vec_add_basic", test_vec_add_basic), &
            new_unittest("vec_add_zeros", test_vec_add_zeros), &
            new_unittest("vec_dot_orthogonal", test_vec_dot_orthogonal), &
            new_unittest("vec_dot_parallel", test_vec_dot_parallel), &
            new_unittest("vec_norm_unit", test_vec_norm_unit), &
            new_unittest("vec_norm_3d", test_vec_norm_3d), &
            new_unittest("vec_normalize", test_vec_normalize), &
            new_unittest("vec_normalize_zero", test_vec_normalize_zero) &
        ]
    end subroutine collect_vector_tests

    subroutine test_vec_add_basic(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), b(3), c(3), expected(3)

        a = [1.0_dp, 2.0_dp, 3.0_dp]
        b = [4.0_dp, 5.0_dp, 6.0_dp]
        expected = [5.0_dp, 7.0_dp, 9.0_dp]

        c = vec_add(a, b)

        call check(error, all(abs(c - expected) < tol), &
            "vec_add([1,2,3], [4,5,6]) should equal [5,7,9]")
    end subroutine test_vec_add_basic

    subroutine test_vec_add_zeros(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), zeros(3), c(3)

        a = [1.0_dp, 2.0_dp, 3.0_dp]
        zeros = [0.0_dp, 0.0_dp, 0.0_dp]

        c = vec_add(a, zeros)

        call check(error, all(abs(c - a) < tol), &
            "vec_add(a, 0) should equal a")
    end subroutine test_vec_add_zeros

    subroutine test_vec_dot_orthogonal(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), b(3), d

        a = [1.0_dp, 0.0_dp, 0.0_dp]
        b = [0.0_dp, 1.0_dp, 0.0_dp]

        d = vec_dot(a, b)

        call check(error, abs(d) < tol, &
            "Orthogonal vectors should have zero dot product")
    end subroutine test_vec_dot_orthogonal

    subroutine test_vec_dot_parallel(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), d

        a = [1.0_dp, 2.0_dp, 3.0_dp]

        d = vec_dot(a, a)

        call check(error, abs(d - 14.0_dp) < tol, &
            "vec_dot([1,2,3], [1,2,3]) should equal 14")
    end subroutine test_vec_dot_parallel

    subroutine test_vec_norm_unit(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), n

        a = [1.0_dp, 0.0_dp, 0.0_dp]
        n = vec_norm(a)

        call check(error, abs(n - 1.0_dp) < tol, &
            "Norm of unit vector should be 1")
    end subroutine test_vec_norm_unit

    subroutine test_vec_norm_3d(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), n

        a = [3.0_dp, 4.0_dp, 0.0_dp]
        n = vec_norm(a)

        call check(error, abs(n - 5.0_dp) < tol, &
            "Norm of [3,4,0] should be 5")
    end subroutine test_vec_norm_3d

    subroutine test_vec_normalize(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: a(3), n(3), norm_result

        a = [3.0_dp, 4.0_dp, 0.0_dp]
        n = vec_normalize(a)
        norm_result = vec_norm(n)

        call check(error, abs(norm_result - 1.0_dp) < tol, &
            "Normalized vector should have unit norm")
    end subroutine test_vec_normalize

    subroutine test_vec_normalize_zero(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: zeros(3), n(3)

        zeros = [0.0_dp, 0.0_dp, 0.0_dp]
        n = vec_normalize(zeros)

        call check(error, all(abs(n) < tol), &
            "Normalizing zero vector should return zero vector")
    end subroutine test_vec_normalize_zero

end module test_vector_ops
