# =============================================================================
# Lesson 11: Custom Commands
# =============================================================================
# Sometimes you need to run external scripts or tools as part of the build.
# CMake provides add_custom_command() and add_custom_target() for this.
#
# This is based on GAMESS's copy_and_convert_sources.cmake pattern.
#
# Build:
#   cmake -B build
#   cmake --build build
# =============================================================================

cmake_minimum_required(VERSION 3.18)
project(custom_commands_demo LANGUAGES Fortran)

# -----------------------------------------------------------------------------
# Example 1: Generate a source file at configure time
# -----------------------------------------------------------------------------
# This runs during `cmake ..` not during `make`

set(VERSION_FILE "${CMAKE_BINARY_DIR}/version_info.f90")

file(WRITE ${VERSION_FILE}
"module version_info
    implicit none
    character(len=*), parameter :: PROJECT_VERSION = \"${PROJECT_VERSION}\"
    character(len=*), parameter :: BUILD_TYPE = \"${CMAKE_BUILD_TYPE}\"
    character(len=*), parameter :: COMPILER_ID = \"${CMAKE_Fortran_COMPILER_ID}\"
    character(len=*), parameter :: COMPILER_VERSION = \"${CMAKE_Fortran_COMPILER_VERSION}\"
    character(len=*), parameter :: BUILD_TIME = \"${CMAKE_CURRENT_SOURCE_DIR}\"
end module version_info
")

# -----------------------------------------------------------------------------
# Example 2: Copy and process source files (like GAMESS's addomp.sh)
# -----------------------------------------------------------------------------
# This pattern is used when source files need preprocessing before compilation

# A helper function that copies and optionally processes files
function(copy_and_process_sources src_files new_extension output_var)
    set(processed_files)

    foreach(src_file IN LISTS src_files)
        get_filename_component(src_filename ${src_file} NAME)
        string(REGEX REPLACE "[.]src$" "${new_extension}" new_filename ${src_filename})

        set(source_path "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
        set(dest_path "${CMAKE_BINARY_DIR}/processed/${new_filename}")

        # add_custom_command creates a rule to generate output files
        add_custom_command(
            OUTPUT ${dest_path}                    # What this command produces
            COMMAND ${CMAKE_COMMAND} -E copy ${source_path} ${dest_path}
            COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/tools/process.sh ${dest_path}
            DEPENDS ${source_path}                 # Rebuild if source changes
            COMMENT "Processing ${src_filename} -> ${new_filename}"
        )

        list(APPEND processed_files ${dest_path})
    endforeach()

    set(${output_var} ${processed_files} PARENT_SCOPE)
endfunction()

# -----------------------------------------------------------------------------
# Example 3: Simple copy without processing
# -----------------------------------------------------------------------------
function(copy_sources src_files new_extension output_var)
    set(copied_files)

    foreach(src_file IN LISTS src_files)
        get_filename_component(src_filename ${src_file} NAME)
        string(REGEX REPLACE "[.]src$" "${new_extension}" new_filename ${src_filename})

        set(source_path "${CMAKE_CURRENT_SOURCE_DIR}/${src_file}")
        set(dest_path "${CMAKE_BINARY_DIR}/source/${new_filename}")

        add_custom_command(
            OUTPUT ${dest_path}
            COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/source"
            COMMAND ${CMAKE_COMMAND} -E copy ${source_path} ${dest_path}
            DEPENDS ${source_path}
            COMMENT "Copying ${src_filename}"
        )

        list(APPEND copied_files ${dest_path})
    endforeach()

    set(${output_var} ${copied_files} PARENT_SCOPE)
endfunction()

# Use the function
set(SOURCE_FILES src/mylib.src)
copy_sources("${SOURCE_FILES}" ".f90" PROCESSED_SOURCES)

# -----------------------------------------------------------------------------
# Build the library from processed sources
# -----------------------------------------------------------------------------
add_library(mylib STATIC
    ${PROCESSED_SOURCES}
    ${VERSION_FILE}
)

set_target_properties(mylib PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

# -----------------------------------------------------------------------------
# Example 4: add_custom_target - always runs
# -----------------------------------------------------------------------------
# Unlike add_custom_command, this creates a target you can build explicitly

add_custom_target(show_info
    COMMAND ${CMAKE_COMMAND} -E echo "Build type: ${CMAKE_BUILD_TYPE}"
    COMMAND ${CMAKE_COMMAND} -E echo "Compiler: ${CMAKE_Fortran_COMPILER}"
    COMMAND ${CMAKE_COMMAND} -E echo "Flags: ${CMAKE_Fortran_FLAGS}"
    COMMENT "Showing build information"
)

# -----------------------------------------------------------------------------
# Example 5: Post-build command
# -----------------------------------------------------------------------------
add_executable(demo app/main.f90)
target_link_libraries(demo PRIVATE mylib)
target_include_directories(demo PRIVATE ${CMAKE_BINARY_DIR}/modules)

# Run a command after building the target
add_custom_command(
    TARGET demo
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Build completed successfully!"
    COMMAND ${CMAKE_COMMAND} -E echo "Executable: $<TARGET_FILE:demo>"
)

# -----------------------------------------------------------------------------
# Example 6: Generate documentation (custom target with dependencies)
# -----------------------------------------------------------------------------
find_program(FORD_EXECUTABLE ford)

if(FORD_EXECUTABLE)
    add_custom_target(docs
        COMMAND ${FORD_EXECUTABLE} ${CMAKE_SOURCE_DIR}/ford.md
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating documentation with FORD"
    )
endif()
