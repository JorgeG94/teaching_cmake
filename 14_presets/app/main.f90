program main
    use mylib, only: compute_sum
    implicit none

    integer :: n
    real(8) :: result

    print '(A)', "=== CMake Presets Demo ==="
    print '(A)', ""

#ifdef USE_OPENMP
    print '(A)', "OpenMP: ENABLED"
#else
    print '(A)', "OpenMP: DISABLED"
#endif

#ifdef ENABLE_ASSERTIONS
    print '(A)', "Assertions: ENABLED"
#else
    print '(A)', "Assertions: DISABLED"
#endif

    print '(A)', ""

    n = 1000000
    result = compute_sum(n)

    print '(A, I0, A, F15.10)', "Sum of 1/i for i=1 to ", n, ": ", result
    print '(A)', ""
    print '(A)', "Build this with different presets to compare!"

end program main
