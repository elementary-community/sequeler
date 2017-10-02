################################################################################
# FindPandoc.cmake
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

find_program(PANDOC_EXE NAMES pandoc)
mark_as_advanced(PANDOC_EXE)
include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pandoc DEFAULT_MSG PANDOC_EXE)

#
# add_man_page - Create a man page from another file using pandoc
#
# Usage:
#
# add_man_page(<output-file> [SECTION <section>] [HEADER <header>] [FOOTER <footer>] <source1> [<source2> ...])
#
# <output-file> is the name of the file to create.
# <source*> is one or more source file (any pandoc compatible format).
# SECTION is the man page section number.
# HEADER is the header for the man page.
# FOOTER is the footer for the man page.
#
function(add_man_page outputFile)
    set(oneValueArgs SOURCE SECTION HEADER FOOTER)
    cmake_parse_arguments(MAN "" "${oneValueArgs}" "" ${ARGN})

    if(outputFile)
        if(NOT IS_ABSOLUTE "${outputFile}")
            set(outputFile "${CMAKE_CURRENT_BINARY_DIR}/${outputFile}")
        endif()
    else()
        message(FATAL_ERROR "No arguments give for add_man_page()")
    endif()

    if(MAN_UNPARSED_ARGUMENTS)
        set(sourceFiles ${MAN_UNPARSED_ARGUMENTS})
    else()
        message(FATAL_ERROR "No source files given for add_man_page()")
    endif()

    if(MAN_SECTION)
        set(sectionArg "--variable=section:${MAN_SECTION}")
    endif()

    if(MAN_HEADER)
        set(headerArg "--variable=header:${MAN_HEADER}")
    endif()

    if(MAN_FOOTER)
        set(footerArg "--variable=footer:${MAN_FOOTER}")
    endif()

    add_custom_command(OUTPUT "${outputFile}"
        COMMAND ${PANDOC_EXE}
            --output=${outputFile}
            --standalone
            ${sectionArg}
            ${headerArg}
            ${footerArg}
            --to=man
            ${sourceFiles}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS
            ${sourceFiles}
        VERBATIM
    )
endfunction()
