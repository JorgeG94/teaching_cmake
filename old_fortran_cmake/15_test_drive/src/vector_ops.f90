module vector_ops
    use, intrinsic :: iso_fortran_env, only: dp => real64
    implicit none
    private

    public :: vec_add, vec_dot, vec_norm, vec_normalize, dp

contains

    pure function vec_add(a, b) result(c)
        real(dp), intent(in) :: a(:), b(:)
        real(dp), allocatable :: c(:)
        c = a + b
    end function vec_add

    pure function vec_dot(a, b) result(d)
        real(dp), intent(in) :: a(:), b(:)
        real(dp) :: d
        d = dot_product(a, b)
    end function vec_dot

    pure function vec_norm(a) result(n)
        real(dp), intent(in) :: a(:)
        real(dp) :: n
        n = sqrt(dot_product(a, a))
    end function vec_norm

    pure function vec_normalize(a) result(n)
        real(dp), intent(in) :: a(:)
        real(dp), allocatable :: n(:)
        real(dp) :: magnitude
        magnitude = vec_norm(a)
        if (magnitude > 0.0_dp) then
            n = a / magnitude
        else
            n = a
        end if
    end function vec_normalize

end module vector_ops
