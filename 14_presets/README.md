# Lesson 14: CMake Presets

Standardize build configurations with CMakePresets.json.

## What You'll Learn
- `CMakePresets.json` - shared, version-controlled presets
- `CMakeUserPresets.json` - personal, local presets (gitignored)
- Configure, build, and test presets
- Preset inheritance and composition

## Build with Presets

```bash
# List available presets
cmake --list-presets

# Configure with a preset
cmake --preset debug

# Build with a preset
cmake --build --preset debug

# Test with a preset
ctest --preset debug

# One-liner for full build
cmake --preset release && cmake --build --preset release
```

## Key Concepts

### CMakePresets.json Structure

```json
{
  "version": 6,
  "configurePresets": [...],
  "buildPresets": [...],
  "testPresets": [...]
}
```

### Configure Presets

```json
{
  "name": "debug",
  "displayName": "Debug Build",
  "description": "Debug build with checks",
  "binaryDir": "${sourceDir}/build/${presetName}",
  "cacheVariables": {
    "CMAKE_BUILD_TYPE": "Debug",
    "ENABLE_ASSERTIONS": "ON"
  }
}
```

### Preset Inheritance

```json
{
  "name": "base",
  "hidden": true,
  "binaryDir": "${sourceDir}/build/${presetName}"
},
{
  "name": "debug",
  "inherits": "base",
  "cacheVariables": {
    "CMAKE_BUILD_TYPE": "Debug"
  }
},
{
  "name": "debug-omp",
  "inherits": "debug",
  "cacheVariables": {
    "ENABLE_OPENMP": "ON"
  }
}
```

### Build Presets

```json
{
  "name": "debug",
  "configurePreset": "debug",
  "jobs": 4,
  "targets": ["all"]
}
```

### Test Presets

```json
{
  "name": "debug",
  "configurePreset": "debug",
  "output": {
    "outputOnFailure": true,
    "verbosity": "verbose"
  }
}
```

### CMakeUserPresets.json (Personal, Gitignored)

For machine-specific settings:

```json
{
  "version": 6,
  "configurePresets": [
    {
      "name": "my-local",
      "inherits": "debug",
      "cacheVariables": {
        "CMAKE_PREFIX_PATH": "/opt/my-libs"
      }
    }
  ]
}
```

**Add to .gitignore:**
```
CMakeUserPresets.json
```

### Useful Variables in Presets

| Variable | Description |
|----------|-------------|
| `${sourceDir}` | Path to source directory |
| `${presetName}` | Name of the current preset |
| `${hostSystemName}` | OS name (Linux, Windows, Darwin) |
| `${dollar}` | Literal `$` character |
| `$env{VAR}` | Environment variable |

### Environment Variables

```json
{
  "name": "omp-debug",
  "inherits": "debug",
  "environment": {
    "OMP_NUM_THREADS": "4",
    "OMP_STACKSIZE": "512M"
  }
}
```

### Compiler Selection

```json
{
  "name": "intel",
  "inherits": "base",
  "cacheVariables": {
    "CMAKE_Fortran_COMPILER": "ifx"
  }
}
```

### Conditions (CMake 3.21+)

```json
{
  "name": "linux-only",
  "condition": {
    "type": "equals",
    "lhs": "${hostSystemName}",
    "rhs": "Linux"
  }
}
```

## Common Presets for Fortran Projects

```json
{
  "configurePresets": [
    {"name": "debug", "...": "development with checks"},
    {"name": "release", "...": "optimized production"},
    {"name": "omp", "...": "with OpenMP"},
    {"name": "mpi", "...": "with MPI"},
    {"name": "ci", "...": "for GitHub Actions/CI"},
    {"name": "coverage", "...": "for code coverage"}
  ]
}
```

## IDE Integration

Many IDEs read CMakePresets.json:
- **VS Code** (CMake Tools extension)
- **CLion**
- **Visual Studio 2022+**

## Migration from Command Line

Before (long command):
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DENABLE_OMP=ON -DBUILD_TESTING=ON
```

After (with presets):
```bash
cmake --preset debug-omp
```

## Best Practices

1. Keep `CMakePresets.json` in version control
2. Put personal settings in `CMakeUserPresets.json` (gitignored)
3. Use inheritance to avoid repetition
4. Name presets clearly: `debug`, `release`, `ci`, `coverage`
5. Document presets with `displayName` and `description`
