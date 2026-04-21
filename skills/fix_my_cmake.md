# /fix_my_cmake

Diagnose and fix CMake build errors in the current repository. This skill handles configure errors, build errors, link errors, find_package failures, and install/export issues.

It also reads the roast report from `/roast_my_cmake` and applies fixes automatically.

## Step 0: Check for Roast Report

**First**, check if `.cmake_roast_report.md` exists in the repository root.

### If the roast report exists

1. Read the report and parse the `## Fixes` section
2. For each fix:
   - Read the target file
   - Find the code specified in **Find**
   - Replace it with the code specified in **Replace**
   - Log the fix as applied
3. After applying all fixes, verify the build (see Step 3)
4. Update the report: add a `## Applied` section at the top listing what was fixed and when
5. Tell the user what was fixed

### If the roast report does not exist

Proceed to Step 1 to diagnose issues directly.

---

## Step 1: Identify the Problem

Ask the user what is happening, or check for yourself:

### If the user provides an error message

Parse the error and classify it:

- **Configure error** --- happens during `cmake -B build` (CMake language errors, missing packages, policy warnings)
- **Build error** --- happens during `cmake --build build` (compiler errors, linker errors)
- **Install error** --- happens during `cmake --install build`
- **Consumer error** --- happens when another project tries to `find_package()` or link against this one

### If no error is provided

Try to reproduce the issue:

1. Check if `CMakePresets.json` exists and try `cmake --preset <first-preset>`
2. Otherwise try `cmake -B build -G Ninja` (or `-G "Unix Makefiles"` if Ninja is not available)
3. If configure succeeds, try `cmake --build build`
4. Report what failed

## Step 2: Diagnose by Error Category

### Configure Errors

#### "Could not find package X" / "find_package(X) failed"

1. Check if the package is installed on the system:
   - Search for headers: `find / -name "X.h" 2>/dev/null` or check common prefixes
   - Search for cmake configs: `find / -name "XConfig.cmake" -o -name "x-config.cmake" 2>/dev/null`
2. Check if `CMAKE_PREFIX_PATH` or `X_ROOT` needs to be set
3. Check if a `FindX.cmake` module is needed in the `cmake/` directory
4. Check if the package name is correct (case-sensitive on some platforms)
5. If on HPC, check if a `module load` is needed

**Common fixes:**

```bash
# Point to the install location
cmake -B build -DX_ROOT=/path/to/X

# Or add to prefix path
cmake -B build -DCMAKE_PREFIX_PATH="/path/to/X;/path/to/Y"
```

If the package exists but does not ship a Config.cmake, offer to generate a `FindX.cmake` module.

#### "Policy CMPXXXX" warnings or errors

1. Identify which policy is involved and what it does
2. Check the `cmake_minimum_required` version --- bumping it usually resolves the warning
3. If the minimum version cannot be bumped, explain the policy and set it explicitly

#### "Target X not found" / "ALIAS target X does not exist"

1. Check if the target is being created before it is referenced
2. Check `add_subdirectory` order
3. Check for typos in target names
4. If it is a dependency target, check that `find_package()` or `FetchContent_MakeAvailable()` ran first

### Build Errors

#### Compiler errors in generated code or configuration headers

1. Check `target_compile_features` --- is the right standard being required?
2. Check `target_compile_definitions` --- are required defines missing?
3. Check include paths --- run `cmake --build build -- VERBOSE=1` (Make) or `cmake --build build -v` (Ninja) to see actual compiler invocations

#### Linker errors: "undefined reference to X"

1. Check `target_link_libraries` --- is the library providing X actually linked?
2. Check PUBLIC vs PRIVATE --- if a header uses symbols from library Y, the link must be PUBLIC
3. For Fortran + C interop: check `iso_c_binding` names, check `bind(C, name="...")` matches
4. For C++: check for missing `extern "C"` wrappers
5. Check link order --- some linkers need dependencies after dependents

#### Fortran module errors: "Cannot open module file X.mod"

1. Check that `Fortran_MODULE_DIRECTORY` is set and included in `target_include_directories`
2. Check that the module-defining source file is in the same target or a target that is linked
3. Check compilation order --- CMake tracks Fortran module dependencies, but only within a target. Cross-target module dependencies require proper `target_link_libraries`

### Install / Export Errors

#### "install TARGETS given target X which does not exist"

1. Check that the target name in `install(TARGETS ...)` matches the `add_library` / `add_executable` call exactly
2. Check that the target is not conditional on an option that is OFF

#### "Target X has INTERFACE_INCLUDE_DIRECTORIES with absolute path"

This means a `BUILD_INTERFACE` / `INSTALL_INTERFACE` generator expression is missing:

```cmake
# BROKEN --- absolute path leaks into export
target_include_directories(mylib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# FIXED
target_include_directories(mylib
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
```

### Consumer Errors

#### "find_package(X) found X but targets were not created"

1. Check the `Config.cmake` file --- does it `include()` the targets file?
2. Check that `install(EXPORT ...)` was done during the library's install

#### "Target X:Y was not found" after find_package succeeds

1. Check the namespace in `install(EXPORT ... NAMESPACE X::)`
2. Check that the target name matches between `add_library` and `install(TARGETS)`

#### Consumer gets linker errors for transitive dependencies

1. Check the `Config.cmake.in` --- PUBLIC dependencies must be re-found with `find_dependency()`
2. Check that the original library used PUBLIC (not PRIVATE) for dependencies that appear in its interface

## Step 3: Fix

After diagnosing, apply the fix directly to the CMake files:

1. Edit the relevant `CMakeLists.txt` or `cmake/*.cmake` files
2. If the fix requires creating a new file (e.g., a Find module), create it
3. If the fix requires changes to how CMake is invoked (e.g., setting a variable), tell the user the correct command

After fixing, attempt to reproduce the build to verify the fix works:

```bash
cmake -B build-fix -G Ninja && cmake --build build-fix
```

If the fix introduces new warnings or errors, iterate.

## Step 4: Explain

After fixing, briefly explain:

1. **What was wrong** --- one sentence
2. **Why it was wrong** --- the underlying CMake concept
3. **What was changed** --- the specific edit
4. **How to prevent it** --- a rule or pattern to follow going forward

## Rules

- Always read the full error message before jumping to conclusions --- CMake errors often have the actual cause buried after several lines of context
- Check `CMakeCache.txt` in the build directory for cached stale values --- a stale cache is a common cause of "but I fixed that and it still fails"
- When in doubt, suggest a clean rebuild: `rm -rf build && cmake -B build ...`
- Do not suppress warnings with `cmake_policy(SET ... OLD)` --- that is hiding the problem
- Do not add `-Wno-*` flags to silence compiler warnings without understanding what they warn about
- If the project has no install/export rules and that is causing the consumer error, explain that the fix is to add them (not to hack around the consumer side) and suggest running `/add_cmake_build_system`
- If a `find_package` fails and the library genuinely is not installed, say so --- do not generate a fake Find module that pretends to find it
- After applying fixes from the roast report, update `.cmake_roast_report.md` with an `## Applied` section so running `/fix_my_cmake` again doesn't re-apply the same fixes
- If all fixes have been applied and the build passes, tell the user they can delete `.cmake_roast_report.md`
