program fetchcontent_demo
    ! Use modules from the fetched stdlib
    use stdlib_kinds, only: dp
    use stdlib_math, only: linspace
    implicit none

    real(dp), allocatable :: x(:)
    integer :: i

    print '(A)', "=== FetchContent Demo ==="
    print '(A)', ""
    print '(A)', "Using fortran-stdlib (fetched automatically by CMake)"
    print '(A)', ""

    ! Use stdlib's linspace function
    x = linspace(0.0_dp, 1.0_dp, 11)

    print '(A)', "linspace(0, 1, 11) ="
    do i = 1, size(x)
        print '(A, I2, A, F6.3)', "  x(", i, ") = ", x(i)
    end do

    print '(A)', ""
    print '(A)', "Program completed successfully!"
    print '(A)', ""
    print '(A)', "Note: stdlib was downloaded and built automatically"
    print '(A)', "      during the CMake configuration step!"

end program fetchcontent_demo
