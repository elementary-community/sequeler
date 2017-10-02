################################################################################
# FindValac.cmake
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

find_program(VALAC_EXE NAMES valac)
mark_as_advanced(VALAC_EXE)
include (FindPackageHandleStandardArgs)
find_package_handle_standard_args(Valac DEFAULT_MSG VALAC_EXE)

execute_process(COMMAND ${VALAC_EXE} --version OUTPUT_VARIABLE VALAC_VERSION)
string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" VALAC_VERSION ${VALAC_VERSION})

#
# vala2c - compile Vala source files into C source files
#
# Usage:
#
# vala2c(<target> SOURCE_FILES <file1> [<file2> ...]
#   [SOURCE_VAPIS <vapi1> [<vapi2> ...]]
#   [PACKAGES <pkg1> [<pkg2> ...]]
#   [VAPI_DIRS <dir1> [<dir2> ...]]
#   [TARGET_GLIB <major>.<minor>]
#   [OUTPUT_DIR <dir>]
#   [DEPENDS <file1> [<file2 ...]]
# )
#
# <target> is a variable to hold a list of generated C files.
# SOURCE_FILES is a list of the source (.vala) files.
# SOURCE_VAPIS is a list of local .vapi files to compile.
# PACKAGES is a list of vala package dependencies (e.g. glib-2.0).
# VAPI_DIRS is a list of additional vapi search directories
# TARGET_GLIB is the target glib version.
# OUTPUT_DIR is the location where the generated files will be written. The
#   default is ${CMAKE_CURRENT_BINARY_DIR}
# DEPENDS is a list of additional dependencies (such as a .vapi file that is
#   used via VAPI_DIRS)
#
# The generated C files can then be used with add_library() or add_executable()
# to generate the usual CMake targets.
#
function(vala2c TARGET)
    set(optionArgs "")
    set(oneValueArgs VAPI LIBRARY SHARED_LIBRARY OUTPUT_DIR TARGET_GLIB)
    set(multiValueArgs SOURCE_FILES SOURCE_VAPIS VAPI_DIRS GIR_DIRS METADATA_DIRS PACKAGES DEPENDS)
    cmake_parse_arguments(VALA2C "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # determine the output directory
    set(outputDir "${CMAKE_CURRENT_BINARY_DIR}")
    if(VALA2C_OUTPUT_DIR)
        if(IS_ABSOLUTE "${VALA2C_OUTPUT_DIR}")
            set(outputDir "${VALA2C_OUTPUT_DIR}")
        else()
            set(outputDir "${outputDir}/${VALA2C_OUTPUT_DIR}")
        endif()
    endif()

    # make a list of generated c files
    if(VALA2C_SOURCE_FILES)
        foreach(sourceFile ${VALA2C_SOURCE_FILES})
            get_filename_component(cFile "${sourceFile}" NAME_WE)
            set(cFile "${outputDir}/${cFile}.c")
            list(APPEND outputFiles "${cFile}")
            get_filename_component(sourceFile "${sourceFile}" ABSOLUTE)
            list(APPEND sourceFiles "${sourceFile}")
        endforeach()
    else()
        message(FATAL_ERROR "Missing SOURCE_FILES argument for vala2c")
    endif()

    # optional SOURCE_VAPIS argument
    foreach(vapiFile ${VALA2C_SOURCE_VAPIS})
        get_filename_component(vapiFile "${vapiFile}" ABSOLUTE)
        message(${vapiFile})
        list(APPEND sourceFiles "${vapiFile}")
    endforeach()

    # optional PACKAGES argument
    foreach(package ${VALA2C_PACKAGES})
        list(APPEND pkgArgs "--pkg=${package}")
    endforeach()

    # optional VAPI_DIRS argument
    foreach(vapiDir ${VALA2C_VAPI_DIRS})
        list(APPEND vapiDirArgs "--vapidir=${vapiDir}")
    endforeach()

    # optional TARGET_GLIB argument
    if(VALA2C_TARGET_GLIB)
        set(targetGLibArg "--target-glib=${VALA2C_TARGET_GLIB}")
    endif()

    # debug argument
    if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
        set(debugArg "--debug")
    endif()

    add_custom_command(OUTPUT ${outputFiles}
        COMMAND ${CMAKE_COMMAND} -E make_directory
            ${outputDir}
        COMMAND ${VALAC_EXE}
            ${pkgArgs}
            --directory=${outputDir}
            --ccode
            ${debugArg}
            ${vapiDirArgs}
            ${targetGLibArg}
            ${sourceFiles}
        # valac does not always touch generated files if there were no changes,
        # so we have to do that to keep CMake happy, otherwise there will be
        # dependency problems because OUTPUT is older than DEPENDS
        COMMAND ${CMAKE_COMMAND} -E touch_nocreate
            ${outputFiles}
        DEPENDS
            ${VALA2C_SOURCE_FILES}
            ${VALA2C_SOURCE_VAPIS}
            ${VALA2C_DEPENDS}
        VERBATIM
    )

    set(${TARGET} ${outputFiles} PARENT_SCOPE)

endfunction()
