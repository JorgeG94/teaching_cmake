program integration_tests
    use, intrinsic :: iso_fortran_env, only: error_unit
    use testdrive, only: run_testsuite, new_testsuite, testsuite_type
    use test_full_workflow, only: collect_workflow_tests
    implicit none

    type(testsuite_type), allocatable :: testsuites(:)
    integer :: stat, is
    character(len=*), parameter :: fmt = '("#", *(1x, a))'

    stat = 0

    testsuites = [ &
        new_testsuite("full_workflow", collect_workflow_tests) &
    ]

    do is = 1, size(testsuites)
        write(error_unit, fmt) "Integration Testing:", testsuites(is)%name
        call run_testsuite(testsuites(is)%collect, error_unit, stat)
    end do

    if (stat > 0) then
        write(error_unit, '(i0, 1x, a)') stat, "integration test(s) failed!"
        error stop
    else
        write(error_unit, '(a)') "All integration tests passed!"
    end if

end program integration_tests
