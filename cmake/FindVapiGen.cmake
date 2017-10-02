##
# Copyright 2014 David Lechner <david @lechnology.com>
#
# Copied from: FindVala.cmake
# Copyright 2009-2010 Jakob Westhoff. All rights reserved.
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

##
# Find module for the Vala API generator (vapigen)
#
# This module determines wheter a Vala API generator is installed on the current
# system and where its executable is.
#
# Call the module using "find_package(VapiGen) from within your CMakeLists.txt.
#
# The following variables will be set after an invocation:
#
#  VAPIGEN_FOUND       Whether the vala API generator has been found or not
#  VAPIGEN_EXECUTABLE  Full path to the vapigen executable if it has been found
#  VAPIGEN_VERSION     Version number of the available vapigen
##


# Search for the vapigen executable in the usual system paths.
find_program(VAPIGEN_EXECUTABLE
  NAMES vapigen)

# Handle the QUIETLY and REQUIRED arguments, which may be given to the find call.
# Furthermore set VAPIGEN_FOUND to TRUE if Vala API generator has been found (aka.
# VAPIGEN_EXECUTABLE is set)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(VapiGen DEFAULT_MSG VAPIGEN_EXECUTABLE)

mark_as_advanced(VAPIGEN_EXECUTABLE)

# Determine the vapigen version
if(VAPIGEN_FOUND)
    execute_process(COMMAND ${VAPIGEN_EXECUTABLE} "--version"
                    OUTPUT_VARIABLE "VAPIGEN_VERSION")
    string(REPLACE "Vala API Generator" "" "VAPIGEN_VERSION" ${VAPIGEN_VERSION})
    string(STRIP ${VAPIGEN_VERSION} "VAPIGEN_VERSION")
endif(VAPIGEN_FOUND)
