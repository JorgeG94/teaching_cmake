module stable_code
    ! This module compiles fine with any optimization level
    implicit none
    private
    public :: stable_computation

contains

    function stable_computation(n) result(res)
        integer, intent(in) :: n
        real(8) :: res
        integer :: i

        res = 0.0d0
        do i = 1, n
            res = res + sqrt(real(i, 8))
        end do
    end function stable_computation

end module stable_code
