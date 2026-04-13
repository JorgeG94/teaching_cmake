program test_mylib
    use mylib, only: compute_sum
    implicit none

    real(8) :: result
    logical :: passed

    passed = .true.

    ! Test: sum of first 3 terms should be 1 + 0.5 + 0.333... = 1.833...
    result = compute_sum(3)
    if (abs(result - 1.8333333333333333d0) > 1.0d-10) then
        print '(A, F15.10)', "[FAIL] compute_sum(3) = ", result
        passed = .false.
    else
        print '(A)', "[PASS] compute_sum(3)"
    end if

    ! Test: sum of 0 terms should be 0
    result = compute_sum(0)
    if (abs(result) > 1.0d-10) then
        print '(A, F15.10)', "[FAIL] compute_sum(0) = ", result
        passed = .false.
    else
        print '(A)', "[PASS] compute_sum(0)"
    end if

    if (passed) then
        print '(A)', "All tests passed!"
        stop 0
    else
        print '(A)', "Some tests failed!"
        stop 1
    end if

end program test_mylib
