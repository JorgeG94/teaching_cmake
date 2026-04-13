# =============================================================================
# src/core/CMakeLists.txt - Core Component
# =============================================================================

# Define sources for this component
set(CORE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/core_module.f90
    PARENT_SCOPE    # Make available to parent (src/CMakeLists.txt)
)

# Note: We use CMAKE_CURRENT_SOURCE_DIR to get absolute paths
# This is important when the paths are used from a different directory
