module math_operations
    implicit none
    private
    public :: add, multiply, factorial

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

    pure recursive function factorial(n) result(fact)
        integer, intent(in) :: n
        integer :: fact
        if (n <= 1) then
            fact = 1
        else
            fact = n * factorial(n - 1)
        end if
    end function factorial

end module math_operations
