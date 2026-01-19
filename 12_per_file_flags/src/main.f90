program main
    use stable_code, only: stable_computation
    use problematic_code, only: tricky_computation
    use another_problem, only: also_tricky
    implicit none

    real(8) :: result1, result2, result3

    print '(A)', "=== Per-File Flags Demo ==="
    print '(A)', ""
    print '(A)', "This demo shows how different files can have different"
    print '(A)', "optimization levels for compiler compatibility."
    print '(A)', ""

    result1 = stable_computation(10)
    result2 = tricky_computation(10)
    result3 = also_tricky(10)

    print '(A, F15.6)', "stable_computation(10)  = ", result1
    print '(A, F15.6)', "tricky_computation(10)  = ", result2
    print '(A, F15.6)', "also_tricky(10)         = ", result3
    print '(A)', ""
    print '(A)', "All computations completed successfully!"

end program main
