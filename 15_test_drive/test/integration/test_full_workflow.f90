module test_full_workflow
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use vector_ops, only: vec_norm, vec_normalize, dp
    use matrix_ops, only: mat_multiply, mat_identity
    use statistics, only: mean, std_dev
    implicit none
    private

    public :: collect_workflow_tests

    real(dp), parameter :: tol = 1.0e-10_dp

contains

    subroutine collect_workflow_tests(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("vector_statistics", test_vector_statistics), &
            new_unittest("matrix_vector_ops", test_matrix_vector_ops), &
            new_unittest("full_pipeline", test_full_pipeline) &
        ]
    end subroutine collect_workflow_tests

    !> Test combining vector operations with statistics
    subroutine test_vector_statistics(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: vectors(3, 4)  ! 4 vectors of dimension 3
        real(dp) :: norms(4), mean_norm, expected
        integer :: i

        ! Create some test vectors
        vectors(:, 1) = [3.0_dp, 4.0_dp, 0.0_dp]   ! norm = 5
        vectors(:, 2) = [0.0_dp, 3.0_dp, 4.0_dp]   ! norm = 5
        vectors(:, 3) = [1.0_dp, 0.0_dp, 0.0_dp]   ! norm = 1
        vectors(:, 4) = [0.0_dp, 0.0_dp, 3.0_dp]   ! norm = 3

        ! Compute norms
        do i = 1, 4
            norms(i) = vec_norm(vectors(:, i))
        end do

        ! Mean of norms
        mean_norm = mean(norms)
        expected = (5.0_dp + 5.0_dp + 1.0_dp + 3.0_dp) / 4.0_dp  ! = 3.5

        call check(error, abs(mean_norm - expected) < tol, &
            "Mean of vector norms should be 3.5")
    end subroutine test_vector_statistics

    !> Test matrix-vector operations together
    subroutine test_matrix_vector_ops(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: A(3, 3), I(3, 3), result(3, 3)
        real(dp) :: v(3), v_norm

        ! Identity matrix multiplication
        I = mat_identity(3)
        A(1, :) = [1.0_dp, 2.0_dp, 3.0_dp]
        A(2, :) = [4.0_dp, 5.0_dp, 6.0_dp]
        A(3, :) = [7.0_dp, 8.0_dp, 9.0_dp]

        result = mat_multiply(I, A)

        call check(error, all(abs(result - A) < tol), &
            "I * A should equal A")
        if (allocated(error)) return

        ! Normalize a column of A
        v = A(:, 1)  ! [1, 4, 7]
        v = vec_normalize(v)
        v_norm = vec_norm(v)

        call check(error, abs(v_norm - 1.0_dp) < tol, &
            "Normalized column should have unit norm")
    end subroutine test_matrix_vector_ops

    !> Full pipeline test: normalize vectors, compute stats on norms
    subroutine test_full_pipeline(error)
        type(error_type), allocatable, intent(out) :: error
        real(dp) :: data(5)
        real(dp) :: normalized(5)
        real(dp) :: m, s
        integer :: i

        ! Treat data as a 1D "vector" and normalize element-wise
        data = [10.0_dp, 20.0_dp, 30.0_dp, 40.0_dp, 50.0_dp]

        ! Normalize using vector operations
        normalized = vec_normalize(data)

        ! The normalized vector should have unit norm
        call check(error, abs(vec_norm(normalized) - 1.0_dp) < tol, &
            "Normalized data should have unit norm")
        if (allocated(error)) return

        ! Statistics on original data
        m = mean(data)
        s = std_dev(data)

        call check(error, abs(m - 30.0_dp) < tol, &
            "Mean of [10,20,30,40,50] should be 30")
        if (allocated(error)) return

        ! std_dev = sqrt(variance) = sqrt(250) = 15.811...
        call check(error, abs(s - sqrt(250.0_dp)) < tol, &
            "Std dev calculation incorrect")
    end subroutine test_full_pipeline

end module test_full_workflow
