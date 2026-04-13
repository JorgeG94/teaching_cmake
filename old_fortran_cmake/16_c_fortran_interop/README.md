# Lesson 16: Fortran-C Interoperability

Call C functions from Fortran using `iso_c_binding` and build mixed-language projects with CMake.

## What You'll Learn
- Enabling multiple languages in CMake (`LANGUAGES C Fortran`)
- Using `iso_c_binding` to create Fortran interfaces to C functions
- Passing scalars by value vs. arrays by reference
- Linking C and Fortran code together

## Build & Run

```bash
cmake -B build
cmake --build build
./build/c_fortran_demo
```

## Project Structure

```
16_c_fortran_interop/
├── CMakeLists.txt
├── README.md
└── src/
    ├── c/
    │   ├── math_utils.c        # C implementation
    │   └── math_utils.h        # C header
    └── fortran/
        ├── c_math_interface.f90  # iso_c_binding interface module
        └── main.f90              # Fortran program using C functions
```

## Key Concepts

### Enabling Multiple Languages

```cmake
project(myproject
    LANGUAGES C Fortran
)
```

CMake automatically:
- Finds both compilers
- Uses the correct compiler based on file extension
- Handles linking between languages

### iso_c_binding Basics

Fortran 2003 introduced `iso_c_binding` for portable C interoperability:

```fortran
use, intrinsic :: iso_c_binding, only: c_int, c_double, c_ptr, c_char
```

| C Type | Fortran Kind |
|--------|--------------|
| `int` | `c_int` |
| `double` | `c_double` |
| `float` | `c_float` |
| `char` | `c_char` |
| `void*` | `c_ptr` |

### Binding a C Function

**C function:**
```c
double c_add(double a, double b);
```

**Fortran interface:**
```fortran
interface
    function c_add(a, b) result(res) bind(C, name="c_add")
        import :: c_double
        real(c_double), value, intent(in) :: a, b
        real(c_double) :: res
    end function
end interface
```

Key elements:
- `bind(C, name="c_add")` - links to the C function by name
- `import :: c_double` - brings the kind parameter into the interface block
- `value` attribute - pass by value (C's default for scalars)

### Pass by Value vs. Reference

**By value** (C default for scalars):
```fortran
integer(c_int), value, intent(in) :: n   ! Fortran passes the value
```

**By reference** (C pointers / arrays):
```fortran
real(c_double), intent(inout) :: arr(*)  ! Fortran passes address
```

C sees this as `double *arr`.

### Array Interoperability

**C function expecting a pointer:**
```c
double c_dot_product(const double *a, const double *b, int n);
```

**Fortran interface:**
```fortran
function c_dot_product(a, b, n) result(res) bind(C, name="c_dot_product")
    import :: c_double, c_int
    real(c_double), intent(in) :: a(*)    ! Assumed-size array
    real(c_double), intent(in) :: b(*)
    integer(c_int), value, intent(in) :: n
    real(c_double) :: res
end function
```

**Calling from Fortran:**
```fortran
real(c_double) :: vec_a(5), vec_b(5), result
result = c_dot_product(vec_a, vec_b, 5_c_int)
```

### CMake Linking

```cmake
# C library
add_library(c_math STATIC src/c/math_utils.c)

# Fortran interface (links to C)
add_library(fortran_interface STATIC src/fortran/c_interface.f90)
target_link_libraries(fortran_interface PUBLIC c_math)

# Fortran executable
add_executable(myapp src/fortran/main.f90)
target_link_libraries(myapp PRIVATE fortran_interface)
```

CMake handles the mixed-language linking automatically.

## Common Patterns

### Strings

C strings are null-terminated; Fortran strings are not:

```fortran
use, intrinsic :: iso_c_binding, only: c_char, c_null_char

character(len=*), parameter :: fortran_str = "hello"
character(kind=c_char, len=6) :: c_str

c_str = fortran_str // c_null_char  ! Add null terminator
```

### Opaque Pointers (Handles)

For C structs you don't need to access from Fortran:

```fortran
use, intrinsic :: iso_c_binding, only: c_ptr

type(c_ptr) :: handle  ! Opaque pointer to C struct

interface
    function create_thing() result(h) bind(C)
        import :: c_ptr
        type(c_ptr) :: h
    end function

    subroutine destroy_thing(h) bind(C)
        import :: c_ptr
        type(c_ptr), value :: h
    end subroutine
end interface
```

### Calling Fortran from C

You can also call Fortran from C using `bind(C)`:

```fortran
subroutine fortran_sub(x, y, result) bind(C, name="fortran_sub")
    real(c_double), intent(in) :: x, y
    real(c_double), intent(out) :: result
    result = x + y
end subroutine
```

```c
// C code
extern void fortran_sub(double *x, double *y, double *result);

double a = 1.0, b = 2.0, c;
fortran_sub(&a, &b, &c);  // Note: pass by reference
```

## Troubleshooting

### Linker errors ("undefined reference")

- Check that `name="..."` in `bind(C)` matches the C function name exactly
- Ensure the C library is linked: `target_link_libraries(fortran_target PRIVATE c_library)`
- C++ functions need `extern "C"` to avoid name mangling

### Wrong results

- Check `value` attribute: missing it means pass-by-reference
- Ensure kind parameters match: `real(c_double)` not just `real`
- Array indexing: C is 0-based, Fortran is 1-based (but the memory is contiguous)

### Segmentation fault

- Usually a `value` vs. reference mismatch
- Or array size mismatch between C and Fortran

## Next Steps

Common extensions to explore:
- Wrapping C libraries (HDF5, NetCDF C API)
- Calling C++ from Fortran (requires `extern "C"` wrappers)
- Using `c_f_pointer` to convert C pointers to Fortran arrays
