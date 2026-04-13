module matrix_ops
    use, intrinsic :: iso_fortran_env, only: dp => real64
    implicit none
    private

    public :: mat_trace, mat_transpose, mat_multiply, mat_identity, dp

contains

    pure function mat_trace(A) result(tr)
        real(dp), intent(in) :: A(:,:)
        real(dp) :: tr
        integer :: i, n
        n = min(size(A, 1), size(A, 2))
        tr = 0.0_dp
        do i = 1, n
            tr = tr + A(i, i)
        end do
    end function mat_trace

    pure function mat_transpose(A) result(AT)
        real(dp), intent(in) :: A(:,:)
        real(dp), allocatable :: AT(:,:)
        AT = transpose(A)
    end function mat_transpose

    pure function mat_multiply(A, B) result(C)
        real(dp), intent(in) :: A(:,:), B(:,:)
        real(dp), allocatable :: C(:,:)
        C = matmul(A, B)
    end function mat_multiply

    pure function mat_identity(n) result(I)
        integer, intent(in) :: n
        real(dp), allocatable :: I(:,:)
        integer :: j
        allocate(I(n, n))
        I = 0.0_dp
        do j = 1, n
            I(j, j) = 1.0_dp
        end do
    end function mat_identity

end module matrix_ops
