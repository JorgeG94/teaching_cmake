program main
    use core_module, only: core_init, core_compute
    use utils_module, only: print_header, print_result
    implicit none

    real(8) :: x, y

    call print_header("Subdirectories Demo")
    call core_init()

    x = 5.0d0
    y = core_compute(x)

    call print_result("core_compute(5.0)", y)

    print '(A)', ""
    print '(A)', "Project organized with subdirectories!"

end program main
