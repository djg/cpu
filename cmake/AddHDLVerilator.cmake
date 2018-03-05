# Copyright 2018 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Modifed by Dan Glastonbury <dan.glastonbury@gmail.com>
# - Remove support for SystemC

if (COMMAND add_hdl_verilator)
    return()
endif()

if (NOT DEFINED _HDL_CMAKE_ROOT_DIR)
    set(_HDL_CMAKE_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL
        "HDL CMake root directory" FORCE)
endif()

include(GetHDLDepends)
include(GetHDLProperty)

find_package(Verilator)

if (VERILATOR_FOUND)
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/verilator/configurations")
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/verilator/unit_tests")
    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/verilator/coverage")

    add_custom_target(verilator-coverage
        ${VERILATOR_COVERAGE_EXECUTABLE}
            --annotate-all
            --annotate "${CMAKE_BINARY_DIR}/verilator/coverage"
            "${CMAKE_BINARY_DIR}/verilator/unit_tests/*/*.dat"
    )

    if (NOT TARGET verilator-compile-all)
        add_custom_target(verilator-compile-all ALL)
    endif()

    if (NOT TARGET verilator-analysis-all)
        add_custom_target(verilator-analysis-all)
    endif()
endif()

function(add_hdl_verilator hdl_name)
    if (NOT VERILATOR_FOUND)
        return()
    endif()

    cmake_parse_arguments(ARG "" "${_HDL_ONE_VALUE_ARGUMENTS}"
        "${_HDL_MULTI_VALUE_ARGUMENTS}" ${_HDL_${hdl_name}} ${ARGN})

    if (NOT DEFINED ARG_SYNTHESIZABLE OR NOT ARG_SYNTHESIZABLE)
        return()
    endif()

    if (DEFINED ARG_ANALYSIS)
        if (ARG_ANALYSIS MATCHES ALL OR ARG_ANALYSIS MATCHES Verilator)
            set(verilator_analysis TRUE)
        else()
            set(verilator_analysis FALSE)
        endif()
    endif()

    if (DEFINED ARG_ANALYSIS_EXCLUDE MATCHES Verilator)
        if (ARG_ANALYSIS_EXCLUDE MATCHES Verilator)
            set(verilator_analysis FALSE)
        endif()
    endif()

    if (DEFINED ARG_COMPILE)
        if (ARG_COMPILE MATCHES ALL OR ARG_COMPILE MATCHES Verilator)
            set(verilator_compile TRUE)
        else()
            set(verilator_compile FALSE)
        endif()
    endif()

    if (DEFINED ARG_COMPILE_EXCLUDE MATCHES Verilator)
        if (ARG_COMPILE_EXCLUDE MATCHES Verilator)
            set(verilator_compile FALSE)
        endif()
    endif()

    if (NOT verilator_analysis AND NOT verilator_compile)
        return()
    endif()

    if (NOT DEFINED ARG_TARGET)
        set(ARG_TARGET ${ARG_NAME})
    endif()

    set(verilator_target ${ARG_TARGET})
    set(verilator_sources "")
    set(verilator_defines "")
    set(verilator_includes "")
    set(verilator_parameters "")
    set(verilator_configurations "")
    set(verilator_output_directory
        "${CMAKE_BINARY_DIR}/verilator/libraries/${verilator_target}")

    list(APPEND verilator_defines ${ARG_DEFINES})
    list(APPEND verilator_parameters ${ARG_PARAMETERS})

    get_hdl_depends(${ARG_NAME} hdl_depends)

    foreach (name ${hdl_depends} ${ARG_NAME})
        get_hdl_property(hdl_type "${name}" TYPE)

        if (hdl_type MATCHES Verilog)
            get_hdl_property(hdl_sources "${name}" SOURCES)
            list(APPEND verilator_sources ${hdl_sources})

            get_hdl_property(hdl_source "${name}" SOURCE)
            list(APPEND verilator_sources ${hdl_source})

            get_hdl_property(hdl_defines "${name}" DEFINES)
            list(APPEND verilator_defines ${hdl_defines})

            get_hdl_property(hdl_includes "${name}" INCLUDES)
            list(APPEND verilator_includes ${hdl_includes})

            get_hdl_property(hdl_configs "${name}" VERILATOR_CONFIGURATIONS)
            list(APPEND verilator_configurations ${hdl_configs})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES verilator_defines)
    list(REMOVE_DUPLICATES verilator_includes)
    list(REMOVE_DUPLICATES verilator_parameters)
    list(REMOVE_DUPLICATES verilator_configurations)

    set(verilator_configuration_file
        "${CMAKE_BINARY_DIR}/verilator/configurations/${ARG_TARGET}.vlt")

    set(verilator_config "")
    foreach (config ${verilator_configurations})
        set(verilator_config "${verilator_config}${config}\n")
    endforeach()

    configure_file("${_HDL_CMAKE_ROOT_DIR}/VerilatorConfig.cmake.in"
        "${verilator_configuration_file}")

    set(verilator_flags "")

    list(APPEND verilator_flags --top-module ${ARG_NAME})

    foreach (verilator_parameter ${verilator_parameters})
        list(APPEND verilator_flags -G${verilator_parameter})
    endforeach()

    foreach (verilator_define ${verilator_defines})
        list(APPEND verilator_flags -D${verilator_define})
    endforeach()

    foreach (verilator_include ${verilator_includes})
        list(APPEND verilator_flags -I${verilator_include})
    endforeach()

    list(APPEND verilator_flags ${verilator_configuration_file})
    list(APPEND verilator_flags ${verilator_sources})

    if (verilator_analysis AND
            NOT TARGET verilator-analysis-${verilator_target})
        set(analysis_flags "")
        list(APPEND analysis_flags -Wall)
        list(APPEND analysis_flags --lint-only)

        add_custom_target(verilator-analysis-${verilator_target}
                ${VERILATOR_EXECUTABLE}
                ${analysis_flags}
                ${verilator_flags}
            DEPENDS
                ${verilator_sources}
                ${verilator_includes}
                ${verilator_configuration_file}
        )

        add_dependencies(verilator-analysis-all
            verilator-analysis-${verilator_target})

        if (TARGET ${ARG_TARGET})
            add_dependencies(${ARG_TARGET}
                verilator-analysis-${verilator_target})
        endif()
    endif()

    if (verilator_compile AND NOT TARGET verilator-compile-${verilator_target})
        file(MAKE_DIRECTORY "${verilator_output_directory}")
        file(MAKE_DIRECTORY
            "${CMAKE_BINARY_DIR}/verilator/unit_tests/${verilator_target}")

        set(compile_flags "")

        list(APPEND compile_flags --cc)
#        list(APPEND compile_flags -O2)
#        list(APPEND compile_flags -Wall)
        list(APPEND compile_flags --trace)
        list(APPEND compile_flags --coverage)
        list(APPEND compile_flags --prefix ${verilator_target})
        list(APPEND compile_flags -Mdir .)

#        if (CMAKE_CXX_COMPILER_ID MATCHES GNU OR
#                CMAKE_CXX_COMPILER_ID MATCHES Clang)
#            set(flags
#                -std=c++11
#                -O2
#                -fdata-sections
#                -ffunction-sections
#            )

#            list(APPEND compile_flags -CFLAGS '${flags}')
#        endif()

#        set(verilator_library ${verilator_target}__ALL.a)

        add_custom_command(
            OUTPUT
                ${verilator_output_directory}/${verilator_target}.cpp
                ${verilator_output_directory}/${verilator_target}.h
                ${verilator_output_directory}/${verilator_target}__Syms.cpp
                ${verilator_output_directory}/${verilator_target}__Syms.h
                ${verilator_output_directory}/${verilator_target}__Trace.cpp
                ${verilator_output_directory}/${verilator_target}__Trace__Slow.cpp
            COMMAND
                ${VERILATOR_EXECUTABLE}
            ARGS
                ${compile_flags}
                ${verilator_flags}
#            COMMAND
#                make
#            ARGS
#                -f ${verilator_target}.mk
            DEPENDS
                ${verilator_depends}
                ${verilator_sources}
                ${verilator_includes}
                ${verilator_configuration_file}
            WORKING_DIRECTORY
                ${verilator_output_directory}
            COMMENT
                "Creating CPP ${verilator_target} module"
        )

        add_custom_target(verilator-compile-${verilator_target}
            DEPENDS
                ${verilator_output_directory}/${verilator_target}.cpp
                ${verilator_output_directory}/${verilator_target}.h
                ${verilator_output_directory}/${verilator_target}__Syms.cpp
                ${verilator_output_directory}/${verilator_target}__Syms.h
                ${verilator_output_directory}/${verilator_target}__Trace.cpp
                ${verilator_output_directory}/${verilator_target}__Trace__Slow.cpp
        )
              
        add_dependencies(verilator-compile-all
            verilator-compile-${verilator_target})

        add_library(verilated_${verilator_target} STATIC
            ${verilator_output_directory}/${verilator_target}.cpp
            ${verilator_output_directory}/${verilator_target}.h
            ${verilator_output_directory}/${verilator_target}__Syms.cpp
            ${verilator_output_directory}/${verilator_target}__Syms.h
            ${verilator_output_directory}/${verilator_target}__Trace.cpp
            ${verilator_output_directory}/${verilator_target}__Trace__Slow.cpp
            )

        add_dependencies(verilated_${verilator_target}
            verilator-compile-${verilator_target})

#        set_target_properties(verilated_${verilator_target} PROPERTIES
#            IMPORTED_LOCATION
#                ${verilator_output_directory}/${verilator_library}
#       )

        target_compile_definitions(verilated_${verilator_target}
            PRIVATE
                VL_PRINTF=printf
                VM_COVERAGE=1
                VM_TRACE=1
        )

        target_compile_options(verilated_${verilator_target}
            PRIVATE
                -Wno-char-subscripts
                -Wno-sign-compare
                -Wno-uninitialized
                -Wno-unused-but-set-variable
                -Wno-unused-parameter
                -Wno-unused-variable
                )
      
        target_include_directories(verilated_${verilator_target}
            PUBLIC
                ${VERILATOR_INCLUDE_DIR}
                ${VERILATOR_INCLUDE_DIR}/vltstd
                ${verilator_output_directory}
        )

        target_link_libraries(verilated_${verilator_target}
            verilated
        )

      
        if (ARG_OUTPUT_LIBRARIES)
            set(${ARG_OUTPUT_LIBRARIES}
                verilated_${verilator_target}
                verilated
                ${SYSTEMC_LIBRARIES}
                PARENT_SCOPE
            )
        endif()

        if (ARG_OUTPUT_INCLUDES)
            set(${ARG_OUTPUT_INCLUDES}
                ${VERILATOR_INCLUDE_DIR}
                ${SYSTEMC_INCLUDE_DIRS}
                ${verilator_output_directory}
                PARENT_SCOPE
            )
        endif()

        if (ARG_OUTPUT_WORKING_DIRECTORY)
            set(${ARG_OUTPUT_WORKING_DIRECTORY}
                "${CMAKE_BINARY_DIR}/verilator/unit_tests/${verilator_target}"
                PARENT_SCOPE
            )
        endif()
    endif()
endfunction()
