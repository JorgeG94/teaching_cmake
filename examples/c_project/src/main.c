#include "heatmap/heatmap.h"

#include <stdio.h>

int main(void)
{
    int    nx    = 100;
    int    ny    = 100;
    double lx    = 1.0;
    double ly    = 1.0;
    double alpha = 0.01;   /* thermal diffusivity */
    int    steps = 5000;

    HeatGrid *grid = heatgrid_create(nx, ny, lx, ly);
    if (!grid) {
        fprintf(stderr, "Failed to allocate grid\n");
        return 1;
    }

    /* Hot square in the center */
    heatgrid_set_region(grid, 40, 40, 60, 60, 100.0);

    /* Stable time step for FTCS: dt <= dx^2 / (4 * alpha) */
    double dt = 0.25 * grid->dx * grid->dx / alpha;

    printf("Grid: %dx%d, dt=%.6e, running %d steps\n", nx, ny, dt, steps);

    for (int n = 0; n < steps; n++) {
        double max_delta = heatgrid_step(grid, alpha, dt);
        if (n % 1000 == 0) {
            printf("  step %5d: max delta = %.6e\n", n, max_delta);
        }
    }

    heatgrid_write_csv(grid, "heat_output.csv");
    printf("Wrote heat_output.csv\n");

    heatgrid_destroy(grid);
    return 0;
}
