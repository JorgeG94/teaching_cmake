#include "heatmap/heatmap.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

HeatGrid *heatgrid_create(int nx, int ny, double lx, double ly)
{
    HeatGrid *grid = malloc(sizeof(HeatGrid));
    if (!grid) return NULL;

    grid->nx   = nx;
    grid->ny   = ny;
    grid->dx   = lx / (nx - 1);
    grid->dy   = ly / (ny - 1);
    grid->data = calloc((size_t)nx * ny, sizeof(double));

    if (!grid->data) {
        free(grid);
        return NULL;
    }
    return grid;
}

void heatgrid_destroy(HeatGrid *grid)
{
    if (grid) {
        free(grid->data);
        free(grid);
    }
}

void heatgrid_set_region(HeatGrid *grid,
                         int x0, int y0, int x1, int y1,
                         double value)
{
    for (int j = y0; j <= y1 && j < grid->ny; j++) {
        for (int i = x0; i <= x1 && i < grid->nx; i++) {
            grid->data[j * grid->nx + i] = value;
        }
    }
}

double heatgrid_step(HeatGrid *grid, double alpha, double dt)
{
    int nx = grid->nx;
    int ny = grid->ny;
    double dx2 = grid->dx * grid->dx;
    double dy2 = grid->dy * grid->dy;

    double *old = malloc((size_t)nx * ny * sizeof(double));
    memcpy(old, grid->data, (size_t)nx * ny * sizeof(double));

    double max_delta = 0.0;

    /* Interior points only --- boundaries stay fixed (Dirichlet BC) */
    for (int j = 1; j < ny - 1; j++) {
        for (int i = 1; i < nx - 1; i++) {
            double laplacian =
                (old[(j)   * nx + (i+1)] - 2.0*old[j*nx+i] + old[(j)   * nx + (i-1)]) / dx2 +
                (old[(j+1) * nx + (i)]   - 2.0*old[j*nx+i] + old[(j-1) * nx + (i)])   / dy2;

            grid->data[j * nx + i] = old[j * nx + i] + alpha * dt * laplacian;

            double delta = fabs(grid->data[j * nx + i] - old[j * nx + i]);
            if (delta > max_delta) max_delta = delta;
        }
    }

    free(old);
    return max_delta;
}

int heatgrid_write_csv(const HeatGrid *grid, const char *filename)
{
    FILE *fp = fopen(filename, "w");
    if (!fp) return -1;

    for (int j = 0; j < grid->ny; j++) {
        for (int i = 0; i < grid->nx; i++) {
            if (i > 0) fprintf(fp, ",");
            fprintf(fp, "%.6f", grid->data[j * grid->nx + i]);
        }
        fprintf(fp, "\n");
    }

    fclose(fp);
    return 0;
}
