##
# Copyright 2014 David Lechner <david@lechnology.com>
#
# Copied from: ValaPrecompile.cmake
# Copyright 2009-2010 Jakob Westhoff. All rights reserved.
# Copyright 2012 elementary.
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
# THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of Jakob Westhoff
##

include(ParseArguments)
find_package(VapiGen REQUIRED)

##
# Generate Vala API file
#
# PACKAGES
#   A list of vala packages/libraries to be used during the generation. The
#   package names are exactly the same, as they would be passed to the vapigen
#   "--pkg=" option.
#
# OPTIONS
#   A list of optional options to be passed to the valac executable. This can be
#   used to pass "--thread" for example to enable multi-threading support.
#
# The following call is a simple example to the vala_precompile macro showing
# an example to every of the optional sections:
#
#   generate_vapi(mylibraryname
#       source1.gir
#       source2.gir
#       source3.gir
#   PACKAGES
#       gtk+-2.0
#       gio-1.0
#       posix
#   )
#
# Most important is the variable VALA_C which will contain all the generated c
# file names after the call.
##

macro(generate_vapi library_name)
    parse_arguments(ARGS "TARGET;PACKAGES;OPTIONS" "" ${ARGN})

    set(vala_pkg_opts "")
    foreach(pkg ${ARGS_PACKAGES})
        list(APPEND vala_pkg_opts "--pkg=${pkg}")
    endforeach(pkg ${ARGS_PACKAGES})
    set(in_files "")
    set(out_files "")
    set(out_files_display "")
    set(${output} "")

    add_custom_command(
    OUTPUT
        ${OUTPUT_STAMP}
    COMMAND
        ${VAPIGEN_EXECUTABLE}
    ARGS
        "-C"
        ${header_arguments}
        ${vapi_arguments}
        ${gir_arguments}
        ${symbols_arguments}
        "-b" ${CMAKE_CURRENT_SOURCE_DIR}
        "-d" ${DIRECTORY}
        ${vala_pkg_opts}
        ${ARGS_OPTIONS}
        "-g"
        "--save-temps"
        ${in_files}
        ${custom_vapi_arguments}
    COMMAND
        touch
    ARGS
        ${OUTPUT_STAMP}
    DEPENDS
        ${in_files}
        ${ARGS_CUSTOM_VAPIS}
    COMMENT
        "Generating ${out_files_display}"
    ${gircomp_command}
    )

endmacro(generate_vapi)
