module utils_module
    implicit none
    private
    public :: print_header, print_result

contains

    subroutine print_header(title)
        character(len=*), intent(in) :: title
        print '(A)', "================================"
        print '(A)', title
        print '(A)', "================================"
    end subroutine print_header

    subroutine print_result(label, value)
        character(len=*), intent(in) :: label
        real(8), intent(in) :: value
        print '(A, A, F12.6)', label, " = ", value
    end subroutine print_result

end module utils_module
