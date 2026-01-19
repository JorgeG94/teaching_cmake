# =============================================================================
# app/CMakeLists.txt - Executable
# =============================================================================

add_executable(demo main.f90)

# Link to the library (defined in src/)
target_link_libraries(demo PRIVATE myproject::myproject)
