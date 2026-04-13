module test_matrix_ops
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use matrix_ops, only: mat_trace, mat_transpose, mat_multiply, mat_identity, dp
    implicit none
    private

    public :: collect_matrix_tests

    real(dp), parameter :: tol = 1.0e-12_dp

contains

    subroutine collect_matrix_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("mat_trace_identity", test_trace_identity), &
            new_unittest("mat_trace_diagonal", test_trace_diagonal), &
            new_unittest("mat_transpose_symmetric", test_transpose_symmetric), &
            new_unittest("mat_transpose_general", test_transpose_general), &
            new_unittest("mat_multiply_identity", test_multiply_identity), &
            new_unittest("mat_multiply_2x2", test_multiply_2x2), &
            new_unittest("mat_identity_3x3", test_identity_3x3) &
        ]
    end subroutine collect_matrix_tests

    subroutine test_trace_identity(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp), allocatable :: I(:,:)
        real(dp) :: tr

        I = mat_identity(4)
        tr = mat_trace(I)

        call check(error, abs(tr - 4.0_dp) < tol, &
            "Trace of 4x4 identity should be 4")
    end subroutine test_trace_identity

    subroutine test_trace_diagonal(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: A(3, 3), tr

        A = 0.0_dp
        A(1, 1) = 1.0_dp
        A(2, 2) = 2.0_dp
        A(3, 3) = 3.0_dp

        tr = mat_trace(A)

        call check(error, abs(tr - 6.0_dp) < tol, &
            "Trace of diag(1,2,3) should be 6")
    end subroutine test_trace_diagonal

    subroutine test_transpose_symmetric(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: A(2, 2), AT(2, 2)

        A(1, :) = [1.0_dp, 2.0_dp]
        A(2, :) = [2.0_dp, 1.0_dp]

        AT = mat_transpose(A)

        call check(error, all(abs(AT - A) < tol), &
            "Transpose of symmetric matrix should equal itself")
    end subroutine test_transpose_symmetric

    subroutine test_transpose_general(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: A(2, 3), AT(3, 2)
        real(dp) :: expected(3, 2)

        A(1, :) = [1.0_dp, 2.0_dp, 3.0_dp]
        A(2, :) = [4.0_dp, 5.0_dp, 6.0_dp]

        expected(1, :) = [1.0_dp, 4.0_dp]
        expected(2, :) = [2.0_dp, 5.0_dp]
        expected(3, :) = [3.0_dp, 6.0_dp]

        AT = mat_transpose(A)

        call check(error, all(abs(AT - expected) < tol), &
            "Transpose of 2x3 matrix should be 3x2")
    end subroutine test_transpose_general

    subroutine test_multiply_identity(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: A(3, 3), I(3, 3), result(3, 3)

        A(1, :) = [1.0_dp, 2.0_dp, 3.0_dp]
        A(2, :) = [4.0_dp, 5.0_dp, 6.0_dp]
        A(3, :) = [7.0_dp, 8.0_dp, 9.0_dp]

        I = mat_identity(3)
        result = mat_multiply(A, I)

        call check(error, all(abs(result - A) < tol), &
            "A * I should equal A")
    end subroutine test_multiply_identity

    subroutine test_multiply_2x2(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: A(2, 2), B(2, 2), C(2, 2), expected(2, 2)

        A(1, :) = [1.0_dp, 2.0_dp]
        A(2, :) = [3.0_dp, 4.0_dp]

        B(1, :) = [5.0_dp, 6.0_dp]
        B(2, :) = [7.0_dp, 8.0_dp]

        ! Expected: [1*5+2*7, 1*6+2*8; 3*5+4*7, 3*6+4*8] = [19, 22; 43, 50]
        expected(1, :) = [19.0_dp, 22.0_dp]
        expected(2, :) = [43.0_dp, 50.0_dp]

        C = mat_multiply(A, B)

        call check(error, all(abs(C - expected) < tol), &
            "2x2 matrix multiplication incorrect")
    end subroutine test_multiply_2x2

    subroutine test_identity_3x3(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp), allocatable :: I(:,:)
        real(dp) :: expected(3, 3)

        expected = 0.0_dp
        expected(1, 1) = 1.0_dp
        expected(2, 2) = 1.0_dp
        expected(3, 3) = 1.0_dp

        I = mat_identity(3)

        call check(error, all(abs(I - expected) < tol), &
            "3x3 identity matrix incorrect")
    end subroutine test_identity_3x3

end module test_matrix_ops
