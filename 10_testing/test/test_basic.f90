program test_basic
    !> A simple test without any framework
    !> Returns exit code 0 on success, non-zero on failure
    use math_funcs, only: add, factorial
    implicit none

    logical :: all_passed
    integer :: failed_count

    all_passed = .true.
    failed_count = 0

    print '(A)', "=== Basic Tests (no framework) ==="
    print '(A)', ""

    ! Test 1: Addition
    if (abs(add(2.0d0, 3.0d0) - 5.0d0) < 1.0d-10) then
        print '(A)', "[PASS] add(2, 3) = 5"
    else
        print '(A)', "[FAIL] add(2, 3) = 5"
        all_passed = .false.
        failed_count = failed_count + 1
    end if

    ! Test 2: Factorial
    if (factorial(5) == 120) then
        print '(A)', "[PASS] factorial(5) = 120"
    else
        print '(A)', "[FAIL] factorial(5) = 120"
        all_passed = .false.
        failed_count = failed_count + 1
    end if

    ! Test 3: Factorial of 0
    if (factorial(0) == 1) then
        print '(A)', "[PASS] factorial(0) = 1"
    else
        print '(A)', "[FAIL] factorial(0) = 1"
        all_passed = .false.
        failed_count = failed_count + 1
    end if

    print '(A)', ""

    if (all_passed) then
        print '(A)', "All tests passed!"
        stop 0  ! Success exit code
    else
        print '(A, I0, A)', "FAILED: ", failed_count, " test(s) failed"
        stop 1  ! Failure exit code
    end if

end program test_basic
