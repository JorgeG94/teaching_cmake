program calculator
    use math_operations, only: add, multiply, factorial
    implicit none

    real :: x, y
    integer :: n

    x = 3.0
    y = 4.0
    n = 5

    print '(A)', "=== Calculator Demo ==="
    print '(A, F6.2, A, F6.2, A, F6.2)', "add(", x, ",", y, ") = ", add(x, y)
    print '(A, F6.2, A, F6.2, A, F6.2)', "multiply(", x, ",", y, ") = ", multiply(x, y)
    print '(A, I0, A, I0)', "factorial(", n, ") = ", factorial(n)

end program calculator
