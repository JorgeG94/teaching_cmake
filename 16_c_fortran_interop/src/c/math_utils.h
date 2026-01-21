#ifndef MATH_UTILS_H
#define MATH_UTILS_H

// Simple scalar functions
double c_add(double a, double b);
double c_multiply(double a, double b);
int c_factorial(int n);

// Array function: compute dot product
double c_dot_product(const double *a, const double *b, int n);

// Function that modifies an array in-place: scale by factor
void c_scale_array(double *arr, int n, double factor);

#endif
