program unit_tests
    use, intrinsic :: iso_fortran_env, only: error_unit
    use testdrive, only: run_testsuite, new_testsuite, testsuite_type
    use test_vector_ops, only: collect_vector_tests
    use test_matrix_ops, only: collect_matrix_tests
    use test_statistics, only: collect_statistics_tests
    implicit none

    type(testsuite_type), allocatable :: testsuites(:)
    character(len=256) :: arg
    integer :: stat, is
    character(len=*), parameter :: fmt = '("#", *(1x, a))'

    stat = 0

    ! Collect all test suites
    testsuites = [ &
        new_testsuite("vector_ops", collect_vector_tests), &
        new_testsuite("matrix_ops", collect_matrix_tests), &
        new_testsuite("statistics", collect_statistics_tests) &
    ]

    ! Check for --filter argument
    if (command_argument_count() >= 2) then
        call get_command_argument(1, arg)
        if (trim(arg) == "--filter") then
            call get_command_argument(2, arg)
            ! Run only matching suites
            do is = 1, size(testsuites)
                if (index(testsuites(is)%name, trim(arg)) > 0) then
                    write(error_unit, fmt) "Testing:", testsuites(is)%name
                    call run_testsuite(testsuites(is)%collect, error_unit, stat)
                end if
            end do
        else
            call run_all_suites()
        end if
    else
        call run_all_suites()
    end if

    if (stat > 0) then
        write(error_unit, '(i0, 1x, a)') stat, "test(s) failed!"
        error stop
    else
        write(error_unit, '(a)') "All tests passed!"
    end if

contains

    subroutine run_all_suites()
        integer :: i
        do i = 1, size(testsuites)
            write(error_unit, fmt) "Testing:", testsuites(i)%name
            call run_testsuite(testsuites(i)%collect, error_unit, stat)
        end do
    end subroutine run_all_suites

end program unit_tests
