# =============================================================================
# test/CMakeLists.txt - Tests
# =============================================================================

add_executable(test_core test_core.f90)
target_link_libraries(test_core PRIVATE myproject::myproject)

add_test(NAME core_tests COMMAND test_core)
