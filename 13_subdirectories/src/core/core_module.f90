module core_module
    implicit none
    private
    public :: core_init, core_compute

contains

    subroutine core_init()
        print '(A)', "[core] Initialized"
    end subroutine core_init

    function core_compute(x) result(y)
        real(8), intent(in) :: x
        real(8) :: y
        y = x * x
    end function core_compute

end module core_module
