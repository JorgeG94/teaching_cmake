program calculator
    use math_funcs, only: add, multiply, pi
    implicit none

    print '(A)', "=== Installing Demo ==="
    print '(A)', ""
    print '(A, F8.4)', "add(2, 3)      = ", add(2.0, 3.0)
    print '(A, F8.4)', "multiply(2, 3) = ", multiply(2.0, 3.0)
    print '(A, F12.10)', "pi             = ", pi
    print '(A)', ""
    print '(A)', "This program was installed using CMake!"

end program calculator
