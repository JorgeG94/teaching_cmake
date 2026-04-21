# /roast_my_cmake

Review the CMake build system in the current repository and provide a brutally honest assessment of what is wrong, what is outdated, and what will cause pain for anyone trying to use this project as a dependency. Be direct but constructive --- every roast comes with the fix.

## What to Review

Read ALL `CMakeLists.txt` files in the repository, plus any files in `cmake/`, any `*.cmake` files, and `CMakePresets.json` / `CMakeUserPresets.json` if they exist.

## Roast Categories

Score each category as one of:
- **GOOD** --- nothing to complain about
- **MEH** --- works but not ideal, minor issues
- **BAD** --- will cause problems, needs fixing
- **CURSED** --- actively harmful, fix immediately

### 1. Modern CMake Compliance

Check for use of deprecated global commands. Every one of these is a roast:

- `include_directories()` --- should be `target_include_directories()`
- `link_directories()` --- should not exist at all
- `link_libraries()` --- should be `target_link_libraries()`
- `add_definitions()` --- should be `target_compile_definitions()`
- `add_compile_options()` at directory scope --- should be `target_compile_options()`
- Variables like `CMAKE_CXX_FLAGS` being appended to --- should use `target_compile_options()` or presets
- `set(CMAKE_CXX_STANDARD 17)` as a global variable --- should be `target_compile_features(target PUBLIC cxx_std_17)`

### 2. Target Hygiene

- Are PUBLIC / PRIVATE / INTERFACE used correctly?
  - Headers only used internally but marked PUBLIC?
  - Dependencies that appear in public headers but marked PRIVATE?
- Are there ALIAS targets for namespace-qualified names?
- Are there IMPORTED targets for found libraries, or just raw variables?
- Is `BUILD_INTERFACE` / `INSTALL_INTERFACE` used for include directories?

### 3. Installability and Exportability

This is the big one. Check:

- Does `install(TARGETS ... EXPORT ...)` exist?
- Is there a `Config.cmake.in` or `Config.cmake` file?
- Is there a `ConfigVersion.cmake` (via `write_basic_package_version_file`)?
- Does the config file re-find PUBLIC dependencies with `find_dependency()`?
- Can another project do `find_package(ThisProject REQUIRED)` and link via `ThisProject::target`?
- Can another project use `FetchContent` to pull this in?

If install/export is missing entirely, this is **CURSED** --- it means the project is a dead end that nobody can depend on without vendoring or hacking.

### 4. Fortran-Specific (if applicable)

- Is `Fortran_MODULE_DIRECTORY` set?
- Are `.mod` files installed?
- Are `.mod` files included in `target_include_directories` with `BUILD_INTERFACE`?
- Are Fortran module dependencies ordered correctly (or is CMake handling it)?

### 5. Dependency Management

- Are dependencies found with `find_package()` using imported targets (`Foo::Foo`), or are raw variables used (`${FOO_LIBRARIES}`, `${FOO_INCLUDE_DIRS}`)?
- Are optional dependencies handled with `if(TARGET ...)` or `if(Foo_FOUND)`?
- Is `FetchContent` used sensibly (pinned versions, not fetching the entire world)?

### 6. Hardcoded Sins

Look for:
- Hardcoded compiler paths: `/usr/bin/gcc`, `/opt/intel/...`
- Hardcoded library paths: `/usr/lib/libfoo.so`
- Hardcoded flags: `-O3`, `-march=native` baked into CMakeLists.txt instead of presets
- Platform-specific `if(UNIX)` / `if(WIN32)` blocks that could be generator expressions
- Hardcoded install paths instead of using `GNUInstallDirs`

### 7. Presets

- Does `CMakePresets.json` exist?
- If yes, does it use inheritance to avoid repetition?
- Are multiple compilers covered (GCC, Clang, Intel if scientific)?
- Do build and test presets exist?

### 8. Testing

- Is `enable_testing()` / `include(CTest)` present?
- Are tests guarded behind `PROJECT_IS_TOP_LEVEL` or an option?
- Are tests actually linked against the library target (not compiled separately from the same sources)?

## Output Format

```
# CMake Roast: <project name>

## Score Card

| Category                | Rating |
|------------------------|--------|
| Modern CMake           | GOOD / MEH / BAD / CURSED |
| Target Hygiene         | GOOD / MEH / BAD / CURSED |
| Installability         | GOOD / MEH / BAD / CURSED |
| Fortran Handling       | GOOD / MEH / BAD / CURSED / N/A |
| Dependency Management  | GOOD / MEH / BAD / CURSED |
| Hardcoded Sins         | GOOD / MEH / BAD / CURSED |
| Presets                | GOOD / MEH / BAD / CURSED |
| Testing                | GOOD / MEH / BAD / CURSED |

Overall: <one-line summary>

## Roast

### <Category> --- <RATING>

<What is wrong>

**The fix:**

```cmake
<the corrected code>
```

[repeat for each category with issues]

## What You Did Right

[genuine praise for things done well --- this section is mandatory]
```

## Output File

After completing the roast, **write the full report to `.cmake_roast_report.md`** in the repository root. This file will be read by `/fix_my_cmake` to automatically apply fixes.

The report must include a machine-parseable `## Fixes` section at the end:

```markdown
## Fixes

Each fix below can be applied by `/fix_my_cmake`.

### Fix 1
- **File**: `path/to/CMakeLists.txt`
- **Line**: 42
- **Severity**: CURSED | BAD | MEH
- **Find**: `include_directories(${SOME_INCLUDE})`
- **Replace**: `target_include_directories(mylib PRIVATE ${SOME_INCLUDE})`
- **Explanation**: Use target-specific commands instead of global state.

### Fix 2
...
```

After writing the report, tell the user:
1. Where the report was saved (`.cmake_roast_report.md`)
2. The overall score summary
3. That they can run `/fix_my_cmake` to automatically apply the fixes

## Rules

- Read every CMake file before forming opinions --- do not roast based on a single file if there are multiple
- Be specific --- cite file paths and line numbers, show the bad code and the fix
- Do not invent problems --- if something is genuinely fine, say so
- The roast should be fun but the fixes should be production-quality
- Prioritize issues by impact: installability and exportability problems are worse than style issues
- If there is no CMake at all, do not roast --- suggest running `/add_cmake_build_system` instead
- Always write the report to `.cmake_roast_report.md` so `/fix_my_cmake` can consume it
