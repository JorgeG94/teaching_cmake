# =============================================================================
# src/CMakeLists.txt - Main Library
# =============================================================================
# This creates the main library by combining sources from sub-components.
# =============================================================================

# Process sub-components first
# Each sets a SOURCES variable that we'll collect
add_subdirectory(core)
add_subdirectory(utils)

# Create the main library
add_library(myproject STATIC)

# Add sources from this directory and sub-components
target_sources(myproject PRIVATE
    ${CORE_SOURCES}
    ${UTILS_SOURCES}
)

# Set module output directory
set_target_properties(myproject PROPERTIES
    Fortran_MODULE_DIRECTORY ${PROJECT_MODULE_DIR}
)

# Make module directory available to consumers
target_include_directories(myproject PUBLIC
    $<BUILD_INTERFACE:${PROJECT_MODULE_DIR}>
    $<INSTALL_INTERFACE:include/${PROJECT_NAME}>
)

# Create alias for consistent naming
add_library(myproject::myproject ALIAS myproject)

message(STATUS "Library myproject configured with:")
message(STATUS "  Core sources: ${CORE_SOURCES}")
message(STATUS "  Utils sources: ${UTILS_SOURCES}")
