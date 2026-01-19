program compiler_flags_demo
    implicit none

    real :: x, y, result
    integer :: i

    print '(A)', "=== Compiler Flags Demo ==="
    print '(A)', "If this runs, your compiler flags are working!"
    print '(A)', ""

    ! Some operations that might trigger FPE traps in debug mode
    x = 1.0
    y = 3.0
    result = x / y

    print '(A, F12.8)', "1/3 = ", result

    ! Array bounds checking demo (if enabled in debug)
    do i = 1, 5
        print '(A, I0, A, I0)', "Loop iteration ", i, " of ", 5
    end do

    print '(A)', ""
    print '(A)', "Program completed successfully!"

end program compiler_flags_demo
