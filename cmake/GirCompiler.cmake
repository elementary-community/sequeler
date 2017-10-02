##
# Copyright 2016 David Lechner <david@lechnology.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
##

##
# add_typelib: CMake wrapper around g-ir-compiler to create .typelib files
#
# TARGET
#   The name of the cmake target. The TYPELIB_FILE_NAME property of this target
#   will be set to the name of the generated file.
#
# NAMESPACE
#   Namespace used in the generated file.
#
# VERSION
#   Namespace version used in the generated file.
#
# INCLUDES
#   List of other Girs that this depends on.
#
# INCLUDE_DIRS
#   List of directories in which to search for header files.
#
# ARGS
#   Additional arguments to pass directly to g-ir-compiler
#
# FILES
#   List of files to be scanned.
#
# The following call is a simple example to the add_typelib macro showing
# an example to every of the optional sections:
#
#   add_typelib (MY_TYPELIB ${MY_LIBRARY} ${MY_GIR}
#       ARGS
#           --include-dir=/private/gir/dir/
#   )
##

macro(add_typelib TARGET GIR_TARGET)
    cmake_parse_arguments (ARGS "" "" "ARGS" ${ARGN})

    get_target_property (GIR_FILE_NAME ${GIR_TARGET} GIR_FILE_NAME)
    string (REPLACE ".gir" ".typelib" TYPELIB_FILE_NAME ${GIR_FILE_NAME})

    add_custom_command (OUTPUT ${TYPELIB_FILE_NAME}
        COMMAND ${G_IR_COMPILER_EXECUTABLE}
        ARGS
            --output=${TYPELIB_FILE_NAME}
            ${ARGS_ARGS}
            ${GIR_FILE_NAME}
        DEPENDS
            ${GIR_TARGET}
            ${GIR_FILE_NAME}
    )

    add_custom_target (${TARGET} ALL DEPENDS ${TYPELIB_FILE_NAME})
    set_property (TARGET ${TARGET} PROPERTY TYPELIB_FILE_NAME
        ${CMAKE_CURRNET_BINARY_DIR}/${TYPELIB_FILE_NAME})
endmacro()
