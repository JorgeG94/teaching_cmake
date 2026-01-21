program build_types_demo
    implicit none

    real(8) :: result
    integer :: i
    real(8) :: sum

    print '(A)', "=== Build Types Demo ==="
    print '(A)', ""

    ! This computation will be optimized differently based on build type
    sum = 0.0d0
    do i = 1, 1000000
        sum = sum + 1.0d0 / real(i, 8)
    end do

    result = sum

    print '(A, F20.15)', "Harmonic sum (1M terms): ", result
    print '(A)', ""

#ifdef NDEBUG
    print '(A)', "Built in RELEASE mode (NDEBUG defined)"
    print '(A)', "  - Optimizations enabled"
    print '(A)', "  - Debug checks disabled"
#else
    print '(A)', "Built in DEBUG mode (NDEBUG not defined)"
    print '(A)', "  - Optimizations disabled"
    print '(A)', "  - Debug checks enabled"
#endif

    print '(A)', ""
    print '(A)', "Program completed successfully!"

end program build_types_demo
