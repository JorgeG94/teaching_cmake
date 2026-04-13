module math_funcs
    implicit none
    private
    public :: add, multiply, pi

    real, parameter :: pi = 3.14159265358979323846

contains

    pure function add(a, b) result(c)
        real, intent(in) :: a, b
        real :: c
        c = a + b
    end function add

    pure function multiply(a, b) result(c)
        real, intent(in) :: a, b
        real :: c
        c = a * b
    end function multiply

end module math_funcs
