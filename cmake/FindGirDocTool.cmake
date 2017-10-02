################################################################################
# FindFirDocTool.cmake
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

find_program (G_IR_DOC_TOOL_EXE NAMES g-ir-doc-tool)
mark_as_advanced (G_IR_DOC_TOOL_EXE)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (GirDocTool DEFAULT_MSG G_IR_DOC_TOOL_EXE)

include (CMakeParseArguments)

#
# Usage:
#
# add_gir_doc (<target-name> <python|gjs|c> GIR_FILE <file.gir> DESTINATION <directory>)
#
function (add_gir_doc TARGET LANGUAGE)
    set (_one_value_args "GIR_TARGET" "DESTINATION")
    cmake_parse_arguments (GIR_DOC "" "${_one_value_args}" "" "${ARGN}")

    if (GIR_DOC_GIR_TARGET)
        set (_gir_file $<TARGET_PROPERTY:${GIR_DOC_GIR_TARGET},GIR_FILE_NAME>)
    else ()
        message (FATAL_ERROR "Missing GIR_TARGET argument")
    endif ()

    if (NOT GIR_DOC_DESTINATION)
        message (FATAL_ERROR "Missing DESTINATION argument")
    endif ()

    add_custom_command (OUTPUT ${TARGET}.stamp
        COMMAND
            ${CMAKE_COMMAND} -E remove_directory ${GIR_DOC_DESTINATION}
        COMMAND ${G_IR_DOC_TOOL_EXE}
            --output ${GIR_DOC_DESTINATION}
            --language ${LANGUAGE}
            ${_gir_file}
        COMMAND
            ${CMAKE_COMMAND} -E touch ${TARGET}.stamp
        DEPENDS
            ${_gir_file}
    )

    add_custom_target (${TARGET} DEPENDS ${TARGET}.stamp)
    add_dependencies (${TARGET} ${GIR_DOC_GIR_TARGET})

endfunction ()
