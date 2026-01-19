#!/bin/bash
# =============================================================================
# build_all.sh - Build all CMake teaching lessons
# =============================================================================
# Usage:
#   ./build_all.sh          # Build all lessons
#   ./build_all.sh clean    # Remove all build directories
#   ./build_all.sh test     # Build and run tests for all lessons
# =============================================================================

set -e  # Exit on first error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Lessons to build (in order)
LESSONS=(
    "01_hello_world"
    "02_library_and_exe"
    "03_compiler_flags"
    "04_build_types"
    "05_options"
    # "06_find_package"      # Requires BLAS/LAPACK/MPI installed
    # "07_fetchcontent"      # Requires network, takes longer
    "08_installing"
    "09_making_findable"
    # "10_testing"           # Requires network (fetches test-drive)
    "11_custom_commands"
    "12_per_file_flags"
    "13_subdirectories"
    # "14_presets"           # Uses presets, different workflow
    # "15_test_drive"        # Requires network (fetches test-drive)
)

# Lessons that need network access (FetchContent)
NETWORK_LESSONS=(
    "07_fetchcontent"
    "10_testing"
    "15_test_drive"
)

# Lessons that need external dependencies
DEPENDENCY_LESSONS=(
    "06_find_package"
)

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

build_lesson() {
    local lesson=$1
    local lesson_dir="$SCRIPT_DIR/$lesson"

    if [[ ! -d "$lesson_dir" ]]; then
        print_error "$lesson - directory not found"
        return 1
    fi

    if [[ ! -f "$lesson_dir/CMakeLists.txt" ]]; then
        print_error "$lesson - no CMakeLists.txt found"
        return 1
    fi

    echo -e "\n${YELLOW}Building: $lesson${NC}"

    cd "$lesson_dir"

    # Configure
    if cmake -B build -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1; then
        # Build
        if cmake --build build > /dev/null 2>&1; then
            print_success "$lesson"
            return 0
        else
            print_error "$lesson - build failed"
            return 1
        fi
    else
        print_error "$lesson - configure failed"
        return 1
    fi
}

build_lesson_verbose() {
    local lesson=$1
    local lesson_dir="$SCRIPT_DIR/$lesson"

    if [[ ! -d "$lesson_dir" ]]; then
        print_error "$lesson - directory not found"
        return 1
    fi

    cd "$lesson_dir"
    echo -e "\n${YELLOW}Building: $lesson${NC}"

    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build

    print_success "$lesson"
}

clean_lesson() {
    local lesson=$1
    local lesson_dir="$SCRIPT_DIR/$lesson"

    if [[ -d "$lesson_dir/build" ]]; then
        rm -rf "$lesson_dir/build"
        print_success "Cleaned $lesson"
    fi
}

test_lesson() {
    local lesson=$1
    local lesson_dir="$SCRIPT_DIR/$lesson"

    cd "$lesson_dir"

    if [[ -d "build" ]]; then
        if ctest --test-dir build --output-on-failure > /dev/null 2>&1; then
            print_success "$lesson tests passed"
        else
            print_error "$lesson tests failed"
            return 1
        fi
    fi
}

# =============================================================================
# Main
# =============================================================================

case "${1:-build}" in
    build)
        print_header "Building All Lessons"

        success=0
        failed=0
        skipped=0

        for lesson in "${LESSONS[@]}"; do
            if build_lesson "$lesson"; then
                ((success++))
            else
                ((failed++))
            fi
        done

        # Report skipped lessons
        echo -e "\n${YELLOW}Skipped (require network):${NC}"
        for lesson in "${NETWORK_LESSONS[@]}"; do
            print_skip "$lesson"
            ((skipped++))
        done

        echo -e "\n${YELLOW}Skipped (require dependencies):${NC}"
        for lesson in "${DEPENDENCY_LESSONS[@]}"; do
            print_skip "$lesson"
            ((skipped++))
        done

        print_header "Summary"
        echo -e "${GREEN}Success: $success${NC}"
        echo -e "${RED}Failed:  $failed${NC}"
        echo -e "${YELLOW}Skipped: $skipped${NC}"

        if [[ $failed -gt 0 ]]; then
            exit 1
        fi
        ;;

    all)
        print_header "Building ALL Lessons (including network-dependent)"

        ALL_LESSONS=(
            "01_hello_world"
            "02_library_and_exe"
            "03_compiler_flags"
            "04_build_types"
            "05_options"
            "07_fetchcontent"
            "08_installing"
            "09_making_findable"
            "10_testing"
            "11_custom_commands"
            "12_per_file_flags"
            "13_subdirectories"
            "15_test_drive"
        )

        for lesson in "${ALL_LESSONS[@]}"; do
            build_lesson_verbose "$lesson"
        done

        print_header "All builds completed!"
        ;;

    clean)
        print_header "Cleaning All Build Directories"

        for dir in */; do
            lesson="${dir%/}"
            clean_lesson "$lesson"
        done

        print_success "All build directories removed"
        ;;

    test)
        print_header "Running Tests for All Lessons"

        # Build first
        for lesson in "${LESSONS[@]}"; do
            build_lesson "$lesson"
        done

        # Then test
        for lesson in "${LESSONS[@]}"; do
            test_lesson "$lesson"
        done
        ;;

    verbose)
        print_header "Building All Lessons (Verbose)"

        for lesson in "${LESSONS[@]}"; do
            build_lesson_verbose "$lesson"
        done
        ;;

    help|--help|-h)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  build    Build offline lessons (default)"
        echo "  all      Build ALL lessons including network-dependent ones"
        echo "  clean    Remove all build directories"
        echo "  test     Build and run tests"
        echo "  verbose  Build with full output"
        echo "  help     Show this help"
        ;;

    *)
        echo "Unknown command: $1"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac
