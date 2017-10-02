################################################################################
# FindValaDoc.cmake
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

find_package (Valac REQUIRED)

find_program(VALADOC_EXE NAMES valadoc)
mark_as_advanced(VALADOC_EXE)
include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(ValaDoc DEFAULT_MSG VALADOC_EXE)


#
# valadoc - generate valadoc from source files
#
# Usage:
#
# add_valadoc(<target> PACKAGE_NAME <name> [PACKAGE_VERSION <version>]
#   SOURCE_FILES <file1> [<file2> ...]
#   [PACKAGES <pkg1> [<pkg2> ...]]
#   [OUTPUT_DIR <dir>]
#   [IMPORT_DIRS <dir1> [<dir2> ...]]
#   [IMPORTS <NAMESPACE-VERSION> | <GIRTARGET> [<NAMESPACE-VERSION> | <GIRTARGET> ...]]
# )
#
# <target> is the name of the generated target
# PACKAGE_NAME is the name of the vala package we are documenting.
# PACKAGE_VERSION  is the version of the vala package we are documenting.
# SOURCE_FILES is a list of the source (.vala/.vapi) files.
# PACKAGES is a list of vala package dependencies (e.g. glib-2.0).
# OUTPUT_DIR is the location where the generated files will be written. The
#   default is ${CMAKE_CURRENT_BINARY_DIR}/valadoc
# IMPORT_DIRS is a list of additional search directories for IMPORTS
# IMPORTS is a list of repositories to import; it can either be a GIR name in
#   the form NAMESPACE-VERSION or it can be a GIR target created with add_gir()
#
function(add_valadoc TARGET)
    set(optionArgs "")
    set(oneValueArgs PACKAGE_NAME PACKAGE_VERSION)
    set(multiValueArgs SOURCE_FILES PACKAGES IMPORT_DIRS IMPORTS)
    cmake_parse_arguments(VALADOC "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # determine the output directory
    if(VALADOC_OUTPUT_DIR)
        if(IS_ABSOLUTE "${VALADOC_OUTPUT_DIR}")
            set(outputDir "${VALADOC_OUTPUT_DIR}")
        else()
            set(outputDir "${CMAKE_CURRENT_BINARY_DIR}/${VALADOC_OUTPUT_DIR}")
        endif()
    else()
        set(outputDir "${CMAKE_CURRENT_BINARY_DIR}/valadoc")
    endif()

    if(VALADOC_PACKAGE_NAME)
        set(packageNameArg "--package-name=${VALADOC_PACKAGE_NAME}")
    else()
        message(FATAL_ERROR "Missing PACKAGE_NAME argument for valadoc")
    endif()

    if(VALADOC_PACKAGE_VERSION)
        set(packageVersionArg "--package-version=${VALADOC_PACKAGE_VERSION}")
    endif()

    if(NOT VALADOC_SOURCE_FILES)
        message(FATAL_ERROR "Missing SOURCE_FILES argument for valadoc")
    endif()

    # optional PACKAGES argument
    foreach(package ${VALADOC_PACKAGES})
        list(APPEND pkgArgs "--pkg=${package}")
    endforeach()

    # optional IMPORTS argument
    foreach(import ${VALADOC_IMPORTS})
        # if any of IMPORTS is a GIR target, we need to also depend on the .gir
        # file in addition to the target itself and add the directory to the
        # search path
        if(TARGET ${import})
            get_target_property(girFile ${import} GIR_FILE_NAME)
            list(APPEND importDeps ${import})
            list(APPEND importDeps ${girFile})

            get_filename_component(girDirectory ${girFile} DIRECTORY)
            list(APPEND VALADOC_IMPORT_DIRS ${girDirectory})

            get_target_property(girNamespace ${import} GIR_NAMESPACE)
            get_target_property(girVersion ${import} GIR_VERSION)
            set(import ${girNamespace}-${girVersion})
        endif()
        list(APPEND importArgs "--import=${import}")
    endforeach()

    # optional IMPORT_DIRS argument
    foreach(dir ${VALADOC_IMPORT_DIRS})
        list(APPEND importDirArgs "--importdir=${dir}")
    endforeach()

    add_custom_command(OUTPUT ${outputDir}.stamp
        COMMAND ${CMAKE_COMMAND} -E remove_directory
            ${outputDir}
        COMMAND ${VALADOC_EXE}
            --driver=${VALAC_VERSION}
            --directory=${outputDir}
            ${packageNameArg}
            ${packageVersionArg}
            ${pkgArgs}
            ${importDirArgs}
            ${importArgs}
            ${VALADOC_SOURCE_FILES}
        COMMAND ${CMAKE_COMMAND} -E touch
            ${outputDir}.stamp
        DEPENDS
            ${VALADOC_SOURCE_FILES}
            ${importDeps}
        VERBATIM
    )

    add_custom_target(${TARGET} DEPENDS ${outputDir}.stamp)
endfunction()
