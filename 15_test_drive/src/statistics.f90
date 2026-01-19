module statistics
    use, intrinsic :: iso_fortran_env, only: dp => real64
    implicit none
    private

    public :: mean, variance, std_dev, median, dp

contains

    pure function mean(x) result(m)
        real(dp), intent(in) :: x(:)
        real(dp) :: m
        m = sum(x) / real(size(x), dp)
    end function mean

    pure function variance(x) result(v)
        real(dp), intent(in) :: x(:)
        real(dp) :: v, m
        m = mean(x)
        v = sum((x - m)**2) / real(size(x) - 1, dp)
    end function variance

    pure function std_dev(x) result(s)
        real(dp), intent(in) :: x(:)
        real(dp) :: s
        s = sqrt(variance(x))
    end function std_dev

    function median(x) result(m)
        real(dp), intent(in) :: x(:)
        real(dp) :: m
        real(dp), allocatable :: sorted(:)
        integer :: n

        n = size(x)
        allocate(sorted(n))
        sorted = x
        call sort(sorted)

        if (mod(n, 2) == 0) then
            m = (sorted(n/2) + sorted(n/2 + 1)) / 2.0_dp
        else
            m = sorted(n/2 + 1)
        end if
    end function median

    subroutine sort(x)
        real(dp), intent(inout) :: x(:)
        real(dp) :: temp
        integer :: i, j, n
        n = size(x)
        ! Simple bubble sort for demonstration
        do i = 1, n - 1
            do j = 1, n - i
                if (x(j) > x(j + 1)) then
                    temp = x(j)
                    x(j) = x(j + 1)
                    x(j + 1) = temp
                end if
            end do
        end do
    end subroutine sort

end module statistics
