module mylib
    implicit none
    private
    public :: compute_sum

contains

    function compute_sum(n) result(total)
        integer, intent(in) :: n
        real(8) :: total
        integer :: i

#ifdef ENABLE_ASSERTIONS
        if (n < 0) then
            print '(A)', "ERROR: n must be non-negative"
            error stop 1
        end if
#endif

        total = 0.0d0

#ifdef USE_OPENMP
        !$omp parallel do reduction(+:total)
#endif
        do i = 1, n
            total = total + 1.0d0 / real(i, 8)
        end do
#ifdef USE_OPENMP
        !$omp end parallel do
#endif

    end function compute_sum

end module mylib
