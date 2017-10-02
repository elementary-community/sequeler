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
# add_gir: CMake wrapper around g-ir-scanner to create .gir files
#
# TARGET
#   Variable to store the name of the cmake target. The GIR_FILE_NAME property
#   of this target will be set to the name of the generated file.
#
# SHARED_LIBRARY_TARGET
#   The shared library target that this gir will be generated from.
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
#   Additional arguments to pass directly to g-ir-scanner
#
# FILES
#   List of files to be scanned.
#
# The following call is a simple example to the add_gir macro showing
# an example to every of the optional sections:
#
#   add_gir (MY_GIR ${MY_LIBRARY} MyGir 1.0
#       INCLUDES
#           GLib-2.0
#       INCLUDE_DIRS
#           /usr/include/glib-2.0/
#       ARGS
#           --warn-error
#       FILES
#           my_gir.h
#           my_gir.c
#   )
##

macro(add_gir TARGET SHARED_LIBRARY_TARGET NAMESPACE VERSION)
    cmake_parse_arguments (ARGS "" "" "INCLUDES;INCLUDE_DIRS;ARGS;FILES" ${ARGN})

    set (GIR_FILE_NAME ${NAMESPACE}-${VERSION}.gir)

    set (INCLUDES "")
    foreach (PKG ${ARGS_INCLUDES})
        list (APPEND INCLUDES "--include=${PKG}")
    endforeach ()

    set (INCLUDE_DIRS "")
    foreach (DIR ${ARGS_INCLUDE_DIRS})
        list (APPEND INCLUDE_DIRS "-I${DIR}")
    endforeach ()

    set (FILES "")
    foreach (FILE ${ARGS_FILES})
        get_filename_component (ABS_FILE ${FILE} ABSOLUTE)
        list (APPEND FILES "${ABS_FILE}")
    endforeach ()

    add_custom_command (OUTPUT ${GIR_FILE_NAME}
        COMMAND ${G_IR_SCANNER_EXECUTABLE}
        ARGS
            ${INCLUDES}
            --verbose
            --library=$<TARGET_PROPERTY:${SHARED_LIBRARY_TARGET},OUTPUT_NAME>
            --library-path=$<TARGET_SONAME_FILE_DIR:${SHARED_LIBRARY_TARGET}>
            --namespace=${NAMESPACE}
            --nsversion=${VERSION}
            --no-libtool
            --output=${GIR_FILE_NAME}
            ${INCLUDE_DIRS}
            ${ARGS_ARGS}
            ${FILES}
        DEPENDS
            ${SHARED_LIBRARY_TARGET}
            ${FILES}
    )

    add_custom_target (${TARGET} ALL DEPENDS ${GIR_FILE_NAME})
    set_target_properties (${TARGET}
        PROPERTIES
            GIR_NAMESPACE ${NAMESPACE}
            GIR_VERSION ${VERSION}
            GIR_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/${GIR_FILE_NAME}
    )

    set (${TARGET} ${TARGET})
endmacro()
