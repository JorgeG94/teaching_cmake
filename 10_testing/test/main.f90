program test_main
    use, intrinsic :: iso_fortran_env, only: error_unit
    use testdrive, only: run_testsuite, new_testsuite, testsuite_type
    use test_math_funcs, only: collect_math_tests
    implicit none

    type(testsuite_type), allocatable :: testsuites(:)
    integer :: stat, is
    character(len=*), parameter :: fmt = '("#", *(1x, a))'

    stat = 0

    ! Collect all test suites
    testsuites = [ &
        new_testsuite("math_funcs", collect_math_tests) &
    ]

    ! Run each test suite
    do is = 1, size(testsuites)
        write(error_unit, fmt) "Testing:", testsuites(is)%name
        call run_testsuite(testsuites(is)%collect, error_unit, stat)
    end do

    if (stat > 0) then
        write(error_unit, '(i0, 1x, a)') stat, "test(s) failed!"
        error stop
    end if

end program test_main
