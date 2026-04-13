# "It mostly works" Makefile for wave simulation

FC = gfortran
FFLAGS = -O2 -Wall -Wextra

# Object files (ORDER MATTERS - wave_solver.f90 must compile first
# because main.f90 uses the module. Forget this and watch it break.)
OBJS = wave_solver.o main.o

wave_sim: $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

wave_solver.o: src/wave_solver.f90
	$(FC) $(FFLAGS) -c $< -o $@

main.o: src/main.f90 wave_solver.o
	$(FC) $(FFLAGS) -c $< -o $@

clean:
	rm -f *.o *.mod wave_sim

.PHONY: clean
