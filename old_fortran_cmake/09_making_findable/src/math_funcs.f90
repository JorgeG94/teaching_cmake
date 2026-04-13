module math_funcs
    implicit none
    private
    public :: add, multiply, power, factorial

contains

    pure function add(a, b) result(c)
        real(8), intent(in) :: a, b
        real(8) :: c
        c = a + b
    end function add

    pure function multiply(a, b) result(c)
        real(8), intent(in) :: a, b
        real(8) :: c
        c = a * b
    end function multiply

    pure function power(base, exp) result(res)
        real(8), intent(in) :: base
        integer, intent(in) :: exp
        real(8) :: res
        res = base ** exp
    end function power

    pure recursive function factorial(n) result(res)
        integer, intent(in) :: n
        integer :: res
        if (n <= 1) then
            res = 1
        else
            res = n * factorial(n - 1)
        end if
    end function factorial

end module math_funcs
