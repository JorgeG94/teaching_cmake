#ifndef HEATMAP_H
#define HEATMAP_H

#ifdef __cplusplus
extern "C" {
#endif

/* A 2D grid for heat diffusion */
typedef struct {
    int    nx;
    int    ny;
    double dx;
    double dy;
    double *data;
} HeatGrid;

/* Allocate and initialize a grid to zero */
HeatGrid *heatgrid_create(int nx, int ny, double lx, double ly);

/* Free a grid */
void heatgrid_destroy(HeatGrid *grid);

/* Set a rectangular hot region */
void heatgrid_set_region(HeatGrid *grid,
                         int x0, int y0, int x1, int y1,
                         double value);

/* Advance one time step of explicit diffusion (FTCS scheme)
 * Returns the maximum temperature change (for convergence checking) */
double heatgrid_step(HeatGrid *grid, double alpha, double dt);

/* Write the grid to a CSV file */
int heatgrid_write_csv(const HeatGrid *grid, const char *filename);

#ifdef __cplusplus
}
#endif

#endif /* HEATMAP_H */
