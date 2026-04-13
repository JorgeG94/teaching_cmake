program test_core
    use core_module, only: core_compute
    implicit none

    real(8) :: result
    logical :: passed

    passed = .true.

    ! Test core_compute
    result = core_compute(3.0d0)
    if (abs(result - 9.0d0) > 1.0d-10) then
        print '(A)', "[FAIL] core_compute(3.0) should be 9.0"
        passed = .false.
    else
        print '(A)', "[PASS] core_compute(3.0) = 9.0"
    end if

    if (passed) then
        print '(A)', "All tests passed!"
        stop 0
    else
        stop 1
    end if

end program test_core
