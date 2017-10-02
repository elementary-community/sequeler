################################################################################
# FindGLibGenMarshal.cmake
################################################################################

# MIT License
#
# Copyright (c) 2017 David Lechner <david@lechnology.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


find_program (GLIB_GENMARSHAL_EXE NAMES glib-genmarshal)
mark_as_advanced (GLIB_GENMARSHAL_EXE)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (GLibGenMarshal DEFAULT_MSG GLIB_GENMARSHAL_EXE)

include (CMakeParseArguments)

#
# Usage:
#
# glib_genmarshal (HEADER_FILE <file.h> CODE_FILE <file.c>
#   [INTERNAL] [WARNINGS_FATAL] [VALIST] [PREFIX <prefix>] [STANDARD_INCLUDE <yes/no>]
#   LIST_FILES <file1> [<file2> [...]])
#
function (glib_genmarshal)
    set (_option_args "INTERNAL" "WARNINGS_FATAL" "VALIST")
    set (_one_value_args "HEADER_FILE" "CODE_FILE" "PREFIX" "STANDARD_INCLUDE")
    set (_multi_value_args "LIST_FILES")
    cmake_parse_arguments ("GLIB_GENMARSHAL" "${_option_args}" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if (GLIB_GENMARSHAL_HEADER_FILE)
        if (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_HEADER_FILE}")
            set (GLIB_GENMARSHAL_HEADER_FILE "${CMAKE_CURRENT_BINARY_DIR}/${GLIB_GENMARSHAL_HEADER_FILE}")
        endif (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_HEADER_FILE}")
        get_filename_component (GLIB_GENMARSHAL_HEADER_DIR "${GLIB_GENMARSHAL_HEADER_FILE}" DIRECTORY)
    else (GLIB_GENMARSHAL_HEADER_FILE)
        message (FATAL_ERROR "Missing HEADER_FILE argument")
    endif (GLIB_GENMARSHAL_HEADER_FILE)

    if (GLIB_GENMARSHAL_CODE_FILE)
        if (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_CODE_FILE}")
            set (GLIB_GENMARSHAL_CODE_FILE "${CMAKE_CURRENT_BINARY_DIR}/${GLIB_GENMARSHAL_CODE_FILE}")
        endif (NOT IS_ABSOLUTE "${GLIB_GENMARSHAL_CODE_FILE}")
        get_filename_component (GLIB_GENMARSHAL_CODE_DIR "${GLIB_GENMARSHAL_CODE_FILE}" DIRECTORY)
    else (GLIB_GENMARSHAL_CODE_FILE)
        message (FATAL_ERROR "Missing CODE_FILE argument")
    endif (GLIB_GENMARSHAL_CODE_FILE)

    if (GLIB_GENMARSHAL_LIST_FILES)
        foreach (_file ${GLIB_GENMARSHAL_LIST_FILES})
            if (NOT IS_ABSOLUTE "${_file}")
                set (_file "${CMAKE_CURRENT_SOURCE_DIR}/${_file}")
            endif (NOT IS_ABSOLUTE "${_file}")
            list (APPEND _list_files "${_file}")
        endforeach (_file GLIB_GENMARSHAL_LIST_FILES)
        
    else (GLIB_GENMARSHAL_LIST_FILES)
        message (FATAL_ERROR "Missing LIST_FILES argument")
    endif (GLIB_GENMARSHAL_LIST_FILES)

    if (GLIB_GENMARSHAL_PREFIX)
        set (_prefix_arg "--prefix=${GLIB_GENMARSHAL_PREFIX}")
    endif (GLIB_GENMARSHAL_PREFIX)

    if (GLIB_GENMARSHAL_INTERNAL)
        set (_internal_arg "--internal")
    endif (GLIB_GENMARSHAL_INTERNAL)
    
    if (GLIB_GENMARSHAL_WARNINGS_FATAL)
        set (_warnings_fatal_arg "--g-fatal-warnings")
    endif (GLIB_GENMARSHAL_WARNINGS_FATAL)

    if (GLIB_GENMARSHAL_WARNINGS_VALIST)
        set (_valist_arg "--valist-marshallers")
    endif (GLIB_GENMARSHAL_WARNINGS_VALIST)

    if (GLIB_GENMARSHAL_STANDARD_INCLUDE)
        if (${GLIB_GENMARSHAL_STANDARD_INCLUDE})
            set (_stdinc_arg "--stdinc")
        else (${GLIB_GENMARSHAL_STANDARD_INCLUDE})
            set (_stdinc_arg "--nostdinc")
        endif (${GLIB_GENMARSHAL_STANDARD_INCLUDE})
    endif (GLIB_GENMARSHAL_STANDARD_INCLUDE)

    add_custom_command (OUTPUT ${GLIB_GENMARSHAL_HEADER_FILE}
        COMMAND ${CMAKE_COMMAND} -E make_directory
            ${GLIB_GENMARSHAL_HEADER_DIR}
        COMMAND ${GLIB_GENMARSHAL_EXE}
            --header
            ${_prefix_arg}
            ${_internal_arg}
            ${_warnings_fatal_arg}
            ${_stdinc_arg}
            ${_valist_arg}
            ${_list_files}
            > ${GLIB_GENMARSHAL_HEADER_FILE}
        DEPENDS ${_list_files}
    )

    add_custom_command (OUTPUT ${GLIB_GENMARSHAL_CODE_FILE}
        COMMAND ${CMAKE_COMMAND} -E make_directory
            ${GLIB_GENMARSHAL_CODE_DIR}
        COMMAND ${GLIB_GENMARSHAL_EXE}
            --body
            ${_prefix_arg}
            ${_internal_arg}
            ${_warnings_fatal_arg}
            ${_stdinc_arg}
            ${_valist_arg}
            ${_list_files}
            > ${GLIB_GENMARSHAL_CODE_FILE}
        DEPENDS ${_list_files}
    )

endfunction (glib_genmarshal)
