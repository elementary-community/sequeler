##
# Copyright 2009-2010 Jakob Westhoff. All rights reserved.
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
# Find module for the Gir scanner (g-ir-scanner)
#
# This module determines wheter a Gir scanner is installed on the current
# system and where its executable is.
#
# Call the module using "find_package(GirScanner) from within your CMakeLists.txt.
#
# The following variables will be set after an invocation:
#
#  G_IR_SCANNER_FOUND       Whether the g-ir-scanner scanner has been found or not
#  G_IR_SCANNER_EXECUTABLE  Full path to the g-ir-scanner executable if it has been found
##


# Search for the g-ir-scanner executable in the usual system paths.
find_program (G_IR_SCANNER_EXECUTABLE NAMES g-ir-scanner)

# Handle the QUIETLY and REQUIRED arguments, which may be given to the find call.
# Furthermore set G_IR_SCANNER_FOUND to TRUE if the g-ir-scanner has been found (aka.
# G_IR_SCANNER_EXECUTABLE is set)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (GirScanner DEFAULT_MSG G_IR_SCANNER_EXECUTABLE)

mark_as_advanced (G_IR_SCANNER_EXECUTABLE)
