module math_funcs
    implicit none
    private
    public :: add, multiply, factorial, is_prime

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

    pure recursive function factorial(n) result(res)
        integer, intent(in) :: n
        integer :: res
        if (n <= 1) then
            res = 1
        else
            res = n * factorial(n - 1)
        end if
    end function factorial

    pure function is_prime(n) result(res)
        integer, intent(in) :: n
        logical :: res
        integer :: i

        if (n < 2) then
            res = .false.
            return
        end if

        if (n == 2) then
            res = .true.
            return
        end if

        if (mod(n, 2) == 0) then
            res = .false.
            return
        end if

        do i = 3, int(sqrt(real(n))), 2
            if (mod(n, i) == 0) then
                res = .false.
                return
            end if
        end do

        res = .true.
    end function is_prime

end module math_funcs
