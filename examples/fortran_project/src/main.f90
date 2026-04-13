program wave_simulation
  use wave_solver, only: wp, WaveState, wave_init, wave_step, wave_energy, wave_write
  implicit none

  type(WaveState) :: state
  integer  :: n_points, n_steps, step
  real(wp) :: length, wave_speed, dt, cfl, energy

  n_points   = 200
  length     = 1.0_wp
  wave_speed = 1.0_wp
  n_steps    = 2000

  call wave_init(state, n_points, length, wave_speed)

  ! CFL condition: dt <= dx / c
  cfl = 0.9_wp
  dt  = cfl * state%dx / state%c

  write(*,'(A,I6,A,ES10.3,A,I6,A)') &
    'Grid: ', n_points, ' points, dt = ', dt, ', running ', n_steps, ' steps'

  do step = 1, n_steps
    call wave_step(state, dt)

    if (mod(step, 500) == 0) then
      energy = wave_energy(state)
      write(*,'(A,I6,A,ES12.5)') '  step ', step, ': energy = ', energy
    end if
  end do

  call wave_write(state, 'wave_output.csv')
  write(*,'(A)') 'Wrote wave_output.csv'

end program wave_simulation
