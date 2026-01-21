#include "math_utils.h"

double c_add(double a, double b) {
    return a + b;
}

double c_multiply(double a, double b) {
    return a * b;
}

int c_factorial(int n) {
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    return result;
}

double c_dot_product(const double *a, const double *b, int n) {
    double sum = 0.0;
    for (int i = 0; i < n; i++) {
        sum += a[i] * b[i];
    }
    return sum;
}

void c_scale_array(double *arr, int n, double factor) {
    for (int i = 0; i < n; i++) {
        arr[i] *= factor;
    }
}
