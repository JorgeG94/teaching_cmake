program find_package_demo
    implicit none

    ! LAPACK/BLAS parameters
    integer, parameter :: n = 3
    real(8) :: A(n, n), B(n), work(3*n)
    integer :: ipiv(n), info, lwork

    ! OpenMP
    integer :: num_threads

#ifdef USE_MPI
    ! MPI variables
    integer :: ierr, rank, size
#endif

    print '(A)', "=== find_package Demo ==="
    print '(A)', ""

    ! -------------------------------------------------------------------------
    ! OpenMP demonstration
    ! -------------------------------------------------------------------------
    num_threads = 1
    !$ use omp_lib
    !$ num_threads = omp_get_max_threads()
    print '(A, I0, A)', "OpenMP: ", num_threads, " thread(s) available"

    ! -------------------------------------------------------------------------
    ! BLAS/LAPACK demonstration - solve Ax = B
    ! -------------------------------------------------------------------------
    print '(A)', ""
    print '(A)', "LAPACK Demo: Solving linear system Ax = B"

    ! Matrix A (3x3)
    A(1,:) = [1.0d0, 2.0d0, 3.0d0]
    A(2,:) = [4.0d0, 5.0d0, 6.0d0]
    A(3,:) = [7.0d0, 8.0d0, 10.0d0]

    ! Right-hand side B
    B = [14.0d0, 32.0d0, 50.0d0]

    print '(A)', "  A = [1 2 3; 4 5 6; 7 8 10]"
    print '(A)', "  B = [14, 32, 50]"

    ! Solve using LAPACK's dgesv
    call dgesv(n, 1, A, n, ipiv, B, n, info)

    if (info == 0) then
        print '(A)', "  Solution x:"
        print '(A, 3F8.4)', "    ", B(1), B(2), B(3)
        print '(A)', "  (Expected: x = [1, 2, 3])"
    else
        print '(A, I0)', "  LAPACK dgesv failed with info = ", info
    end if

    ! -------------------------------------------------------------------------
    ! MPI demonstration (if available)
    ! -------------------------------------------------------------------------
#ifdef USE_MPI
    print '(A)', ""
    print '(A)', "MPI Demo:"
    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)
    print '(A, I0, A, I0)', "  Rank ", rank, " of ", size
    call MPI_Finalize(ierr)
#else
    print '(A)', ""
    print '(A)', "MPI: Not compiled with MPI support"
#endif

    print '(A)', ""
    print '(A)', "Program completed successfully!"

end program find_package_demo
