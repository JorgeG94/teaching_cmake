program gpu_demo
    implicit none

    integer, parameter :: n = 10000000
    real, allocatable :: a(:), b(:), c(:)
    integer :: i
    real :: sum_result

    allocate(a(n), b(n), c(n))

    ! Initialize arrays
    do i = 1, n
        a(i) = real(i)
        b(i) = real(i) * 2.0
    end do

#ifdef USE_OMP_GPU
    ! OpenMP GPU offloading example
    print *, "Running with OpenMP GPU offloading..."

    !$omp target teams distribute parallel do map(to: a, b) map(from: c)
    do i = 1, n
        c(i) = a(i) + b(i)
    end do
    !$omp end target teams distribute parallel do

#elif defined(USE_DO_CONCURRENT_GPU)
    ! Do concurrent with stdpar - the compiler handles offloading
    print *, "Running with do concurrent (stdpar)..."

    do concurrent (i = 1:n)
        c(i) = a(i) + b(i)
    end do

#else
    ! CPU-only fallback
    print *, "Running on CPU only..."

    do i = 1, n
        c(i) = a(i) + b(i)
    end do

#endif

    ! Verify result
    sum_result = sum(c)
    print *, "Sum of result array: ", sum_result
    print *, "Expected: ", real(n) * (real(n) + 1.0) * 1.5

    deallocate(a, b, c)

end program gpu_demo
