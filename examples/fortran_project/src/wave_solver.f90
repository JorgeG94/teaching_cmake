module wave_solver
  use iso_fortran_env, only: wp => real64
  implicit none
  private
  public :: wp, WaveState, wave_init, wave_step, wave_energy, wave_write

  type :: WaveState
    integer  :: n          ! number of grid points
    real(wp) :: dx         ! grid spacing
    real(wp) :: c          ! wave speed
    real(wp), allocatable :: u(:)      ! displacement at current time
    real(wp), allocatable :: u_prev(:) ! displacement at previous time
  end type WaveState

contains

  subroutine wave_init(state, n, length, wave_speed)
    type(WaveState), intent(out) :: state
    integer, intent(in)          :: n
    real(wp), intent(in)         :: length
    real(wp), intent(in)         :: wave_speed

    integer  :: i
    real(wp) :: x, pi

    pi = 4.0_wp * atan(1.0_wp)

    state%n  = n
    state%dx = length / real(n - 1, wp)
    state%c  = wave_speed

    allocate(state%u(n))
    allocate(state%u_prev(n))

    ! Initial condition: single sine pulse
    do i = 1, n
      x = real(i - 1, wp) * state%dx
      state%u(i) = sin(pi * x / length)
    end do

    ! Start from rest: u_prev = u (zero initial velocity)
    state%u_prev(:) = state%u(:)
  end subroutine wave_init

  subroutine wave_step(state, dt)
    type(WaveState), intent(inout) :: state
    real(wp), intent(in)           :: dt

    integer  :: i
    real(wp) :: r2
    real(wp), allocatable :: u_new(:)

    r2 = (state%c * dt / state%dx)**2

    allocate(u_new(state%n))

    ! Boundaries fixed at zero (Dirichlet)
    u_new(1)       = 0.0_wp
    u_new(state%n) = 0.0_wp

    ! Interior: central difference in space and time
    do i = 2, state%n - 1
      u_new(i) = 2.0_wp * state%u(i) - state%u_prev(i) &
               + r2 * (state%u(i+1) - 2.0_wp*state%u(i) + state%u(i-1))
    end do

    state%u_prev(:) = state%u(:)
    state%u(:)      = u_new(:)

    deallocate(u_new)
  end subroutine wave_step

  function wave_energy(state) result(energy)
    type(WaveState), intent(in) :: state
    real(wp) :: energy

    integer  :: i
    real(wp) :: potential, du_dx

    potential = 0.0_wp

    do i = 2, state%n - 1
      du_dx = (state%u(i+1) - state%u(i-1)) / (2.0_wp * state%dx)
      potential = potential + 0.5_wp * state%c**2 * du_dx**2 * state%dx
    end do

    energy = potential
  end function wave_energy

  subroutine wave_write(state, filename)
    type(WaveState), intent(in)  :: state
    character(len=*), intent(in) :: filename

    integer :: i, unit_num

    unit_num = 20
    open(unit=unit_num, file=filename, status='replace', action='write')

    do i = 1, state%n
      write(unit_num, '(F12.6, A, F12.6)') &
        real(i-1, wp) * state%dx, ',', state%u(i)
    end do

    close(unit_num)
  end subroutine wave_write

end module wave_solver
