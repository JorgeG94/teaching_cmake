module another_problem
    ! Another module that needs reduced optimization
    implicit none
    private
    public :: also_tricky

contains

    function also_tricky(n) result(res)
        integer, intent(in) :: n
        real(8) :: res
        real(8) :: a, b, c
        integer :: i

        a = 1.0d0
        b = 0.0d0
        c = 0.0d0

        ! Code pattern that might be numerically sensitive
        do i = 1, n
            c = a + b
            a = b
            b = c
        end do

        res = c
    end function also_tricky

end module another_problem
