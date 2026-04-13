module problematic_code
    ! This module might have issues with aggressive optimization
    ! In real codebases, this could be due to:
    ! - Aliasing issues
    ! - Compiler bugs at high optimization
    ! - Numerical precision sensitivity
    ! - Complex loop structures that confuse the optimizer
    implicit none
    private
    public :: tricky_computation

contains

    function tricky_computation(n) result(res)
        ! Imagine this function produces wrong results with -O3
        ! due to aggressive loop unrolling or vectorization
        integer, intent(in) :: n
        real(8) :: res
        real(8) :: temp(100)
        integer :: i, j

        temp = 0.0d0
        res = 0.0d0

        ! Complex nested loops that might confuse optimizers
        do i = 1, min(n, 100)
            do j = 1, i
                temp(i) = temp(i) + 1.0d0 / real(j, 8)
            end do
            res = res + temp(i)
        end do
    end function tricky_computation

end module problematic_code
