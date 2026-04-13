program main
    use mylib, only: greet
    use version_info
    implicit none

    print '(A)', "=== Custom Commands Demo ==="
    print '(A)', ""

    ! Use the generated version info module
    print '(A, A)', "Project Version:   ", PROJECT_VERSION
    print '(A, A)', "Build Type:        ", BUILD_TYPE
    print '(A, A)', "Compiler:          ", COMPILER_ID
    print '(A, A)', "Compiler Version:  ", COMPILER_VERSION
    print '(A)', ""

    ! Use the copied/processed library
    call greet("CMake User")

end program main
