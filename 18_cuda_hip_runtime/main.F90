program gpu_runtime_demo
    implicit none

    print *, "=== GPU Runtime Demo ==="
    print *, ""

#ifdef USE_CUDA
    print *, "Built with CUDA runtime"
    print *, "NVIDIA GPU support is available"
    ! In real code, you would use:
    ! - CUDA Fortran extensions (nvfortran)
    ! - ISO_C_BINDING to call CUDA C functions
    ! - OpenMP offloading with -mp=gpu

#elif defined(USE_HIP)
    print *, "Built with HIP runtime"
    print *, "AMD GPU support is available"
    ! In real code, you would use:
    ! - HIPFORT for Fortran HIP bindings
    ! - ISO_C_BINDING to call HIP C functions
    ! - OpenMP offloading (with Cray or AOMP compiler)

#else
    print *, "Built for CPU only"
    print *, "No GPU runtime linked"

#endif

    print *, ""
    print *, "Demo completed successfully!"

end program gpu_runtime_demo
