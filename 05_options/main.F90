program options_demo
    implicit none

#ifdef USE_DOUBLE_PRECISION
    integer, parameter :: wp = selected_real_kind(15, 307)  ! double precision
#else
    integer, parameter :: wp = selected_real_kind(6, 37)    ! single precision
#endif

    real(wp) :: x, y, result
    integer :: i, n_threads

    print '(A)', "=== Options Demo ==="
    print '(A)', ""

    ! Show precision being used
#ifdef USE_DOUBLE_PRECISION
    print '(A)', "Precision: DOUBLE (real*8)"
    print '(A, I0, A)', "           ", precision(1.0_wp), " decimal digits"
#else
    print '(A)', "Precision: SINGLE (real*4)"
    print '(A, I0, A)', "           ", precision(1.0_wp), " decimal digits"
#endif
    print '(A)', ""

    ! Show OpenMP status
#ifdef USE_OPENMP
    !$ use omp_lib
    n_threads = 1
    !$ n_threads = omp_get_max_threads()
    print '(A, I0, A)', "OpenMP: ENABLED (", n_threads, " threads available)"
#else
    print '(A)', "OpenMP: DISABLED"
#endif
    print '(A)', ""

    ! Do a simple computation
    x = 1.0_wp
    y = 3.0_wp
    result = x / y

    print '(A, E25.17)', "1/3 = ", result
    print '(A)', ""

    ! Verbose output if enabled
#ifdef VERBOSE_OUTPUT
    print '(A)', "[VERBOSE] Additional debug information:"
    print '(A, I0)', "[VERBOSE]   Working precision kind: ", wp
    print '(A, E15.8)', "[VERBOSE]   Machine epsilon: ", epsilon(1.0_wp)
    print '(A, E15.8)', "[VERBOSE]   Tiny: ", tiny(1.0_wp)
    print '(A, E15.8)', "[VERBOSE]   Huge: ", huge(1.0_wp)
    print '(A)', ""
#endif

    ! Experimental features
#ifdef EXPERIMENTAL_FEATURES
    print '(A)', "*** EXPERIMENTAL FEATURES ENABLED ***"
    print '(A)', "    Experimental code would go here..."
    print '(A)', ""
#endif

    print '(A)', "Program completed successfully!"

end program options_demo
