! =============================================================================
! Fortran interface to C math_utils library using iso_c_binding
! =============================================================================
! This module demonstrates how to create Fortran bindings for C functions.
! Key concepts:
!   - use, intrinsic :: iso_c_binding
!   - c_double, c_int (kind parameters matching C types)
!   - bind(C, name="...") to specify the C function name
!   - value attribute for pass-by-value (C default)
!   - No value attribute = pass-by-reference (pointer in C)
! =============================================================================

module c_math_interface
    use, intrinsic :: iso_c_binding, only: c_double, c_int
    implicit none
    private

    ! Public interface
    public :: c_add, c_multiply, c_factorial
    public :: c_dot_product, c_scale_array

    interface

        ! ---------------------------------------------------------------------
        ! Simple scalar functions - pass by value
        ! ---------------------------------------------------------------------
        ! C: double c_add(double a, double b)
        function c_add(a, b) result(res) bind(C, name="c_add")
            import :: c_double
            real(c_double), value, intent(in) :: a, b
            real(c_double) :: res
        end function

        ! C: double c_multiply(double a, double b)
        function c_multiply(a, b) result(res) bind(C, name="c_multiply")
            import :: c_double
            real(c_double), value, intent(in) :: a, b
            real(c_double) :: res
        end function

        ! C: int c_factorial(int n)
        function c_factorial(n) result(res) bind(C, name="c_factorial")
            import :: c_int
            integer(c_int), value, intent(in) :: n
            integer(c_int) :: res
        end function

        ! ---------------------------------------------------------------------
        ! Array functions - arrays passed as pointers (no value attribute)
        ! ---------------------------------------------------------------------
        ! C: double c_dot_product(const double *a, const double *b, int n)
        ! Note: Arrays in Fortran are passed by reference, which maps to
        ! pointers in C. The 'n' is passed by value.
        function c_dot_product(a, b, n) result(res) bind(C, name="c_dot_product")
            import :: c_double, c_int
            real(c_double), intent(in) :: a(*)    ! Assumed-size array
            real(c_double), intent(in) :: b(*)
            integer(c_int), value, intent(in) :: n
            real(c_double) :: res
        end function

        ! C: void c_scale_array(double *arr, int n, double factor)
        ! This modifies the array in-place
        subroutine c_scale_array(arr, n, factor) bind(C, name="c_scale_array")
            import :: c_double, c_int
            real(c_double), intent(inout) :: arr(*)
            integer(c_int), value, intent(in) :: n
            real(c_double), value, intent(in) :: factor
        end subroutine

    end interface

end module c_math_interface
