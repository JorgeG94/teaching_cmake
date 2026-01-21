program test_c_interop
    use, intrinsic :: iso_c_binding, only: c_double, c_int
    use c_math_interface
    implicit none

    real(c_double) :: x, y, result
    integer(c_int) :: n, fact
    real(c_double) :: vec_a(5), vec_b(5), dot
    integer :: i

    print '(A)', '============================================='
    print '(A)', 'Fortran-C Interoperability Demo'
    print '(A)', '============================================='
    print *

    ! -------------------------------------------------------------------------
    ! Test scalar functions
    ! -------------------------------------------------------------------------
    print '(A)', '--- Scalar Functions ---'

    x = 3.5_c_double
    y = 2.5_c_double

    result = c_add(x, y)
    print '(A, F6.2, A, F6.2, A, F6.2)', 'c_add(', x, ',', y, ') = ', result

    result = c_multiply(x, y)
    print '(A, F6.2, A, F6.2, A, F6.2)', 'c_multiply(', x, ',', y, ') = ', result

    n = 5
    fact = c_factorial(n)
    print '(A, I0, A, I0)', 'c_factorial(', n, ') = ', fact
    print *

    ! -------------------------------------------------------------------------
    ! Test array functions
    ! -------------------------------------------------------------------------
    print '(A)', '--- Array Functions ---'

    ! Initialize arrays
    vec_a = [1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double]
    vec_b = [2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double, 6.0_c_double]

    print '(A)', 'vec_a = [1.0, 2.0, 3.0, 4.0, 5.0]'
    print '(A)', 'vec_b = [2.0, 3.0, 4.0, 5.0, 6.0]'

    ! Dot product
    dot = c_dot_product(vec_a, vec_b, 5_c_int)
    print '(A, F8.2)', 'c_dot_product(vec_a, vec_b) = ', dot
    print '(A)', '  (Expected: 1*2 + 2*3 + 3*4 + 4*5 + 5*6 = 70.0)'
    print *

    ! Scale array in-place
    print '(A)', '--- In-place Array Modification ---'
    print '(A)', 'Before c_scale_array(vec_a, 5, 2.0):'
    print '(A, 5F8.2)', '  vec_a = ', vec_a

    call c_scale_array(vec_a, 5_c_int, 2.0_c_double)

    print '(A)', 'After:'
    print '(A, 5F8.2)', '  vec_a = ', vec_a
    print *

    print '(A)', '============================================='
    print '(A)', 'All tests completed successfully!'
    print '(A)', '============================================='

end program test_c_interop
