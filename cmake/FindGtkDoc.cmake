# CMake macros to use the GtkDoc documentation system
#
# See the GTK-Doc manual (help/manual/C/index.docbook) for an example of how to
# use this.

# Output variables:
#
#   GTKDOC_FOUND            ... set to 1
#
#   GTKDOC_SCAN_EXE         ... the location of the gtkdoc-scan executable
#   GTKDOC_SCANGOBJ_EXE     ... the location of the gtkdoc-scangobj executable
#   GTKDOC_MKDB_EXE         ... the location of the gtkdoc-mkdb executable
#   GTKDOC_MKHTML_EXE       ... the location of the gtkdoc-mkhtml executable
#   GTKDOC_REBASE_EXE       ... the location of the gtkdoc-rebase executable
#   GTKDOC_FIXXREF_EXE      ... the location of the gtkdoc-fixxref executable


#=============================================================================
# Copyright 2009 Rich Wareham
# Copyright 2015 Lautsprecher Teufel GmbH
# Copyright 2016 David Lechner <david@lechnology.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#=============================================================================

find_program (GTKDOC_SCAN_EXE NAMES gtkdoc-scan)
find_program (GTKDOC_SCANGOBJ_EXE NAMES gtkdoc-scangobj)
find_program (GTKDOC_MKDB_EXE NAMES gtkdoc-mkdb)
find_program (GTKDOC_MKHTML_EXE NAMES gtkdoc-mkhtml)
find_program (GTKDOC_REBASE_EXE NAMES gtkdoc-rebase)
find_program (GTKDOC_FIXXREF_EXE NAMES gtkdoc-fixxref)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (GtkDoc DEFAULT_MSG
    GTKDOC_SCAN_EXE
    GTKDOC_SCANGOBJ_EXE
    GTKDOC_MKDB_EXE
    GTKDOC_MKHTML_EXE
    GTKDOC_REBASE_EXE
    GTKDOC_FIXXREF_EXE
)

set (GTKDOC_FOUND 1)

mark_as_advanced (GTKDOC_SCAN_EXE)
mark_as_advanced (GTKDOC_SCANGOBJ_EXE)
mark_as_advanced (GTKDOC_MKDB_EXE)
mark_as_advanced (GTKDOC_MKHTML_EXE)
mark_as_advanced (GTKDOC_REBASE_EXE)
mark_as_advanced (GTKDOC_FIXXREF_EXE)
mark_as_advanced (GTKDOC_FOUND)

find_package (PkgConfig REQUIRED)
pkg_check_modules (GTKDOC_SCANGOBJ_DEPS REQUIRED gobject-2.0)

include(CMakeParseArguments)

option (GTKDOC_REBASE_ONLINE "Prefer online cross-references when rebasing docs")


get_filename_component(_this_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

# ::
#
# gtk_doc_add_module(doc_prefix
#                    SOURCE <sourcedir> [...]
#                    XML xmlfile
#                    [LIBRARIES depend1...]
#                    [FIXXREFOPTS fixxrefoption1...]
#                    [IGNOREHEADERS header1...]
#                    [IGNOREFILES file1...])
#
# Add a module with documentation to be processed with GTK-Doc.
#
# <sourcedir> must be the *full* path to the source directory.
#
# If omitted, xmlfile defaults to the auto generated ${doc_prefix}/${doc_prefix}-docs.xml.
#
# The `gtkdoc-scangobj` program is used to get introspection information for
# the module. You should pass the target(s) to be scanned as LIRARIES. This
# will try to set the correct compiler and link flags for the introspection
# build to use, and the correct LD_LIBRARY_PATH for it to run, and the correct
# dependencies for the doc target.
#
# You *can* also set the compile and link flags manually, using the 'CFLAGS'
# and 'LDFLAGS' options. The 'LDPATH' option controls the LD_LIBRARY_PATH. You
# can also manually add additional targets as dependencies of the
# documentation build with the DEPENDS option.
#
# This function a target named "doc-${doc_prefix}". You will need to manually
# add it to the ALL target if you want it to be built by default, you can do
# something like this:
#
#   gtk_doc_add_module(doc-mymodule
#                      SOURCE ${CMAKE_SOURCE_DIR}/module ${CMAKE_BINARY_DIR}/module
#                      LIBRARIES mylibrary
#                      LIBRARY_DIRS ${GLIB_LIBRARY_DIRS} ${FOO_LIBRARY_DIRS}
#   add_custom_target(all-documentation ALL)
#   add_dependencies(all-documentation doc-mymodule)
#
function(gtk_doc_add_module _doc_prefix)
    set(_one_value_args "XML")
    set(_multi_value_args "FIXXREFOPTS" "IGNOREHEADERS" "IGNOREFILES" "LIBRARIES"
                          "LIBRARY_DIRS" "SOURCE" "SUFFIXES"
                          "CFLAGS" "DEPENDS" "LDFLAGS" "LDPATH")
    cmake_parse_arguments("GTK_DOC" "" "${_one_value_args}" "${_multi_value_args}" ${ARGN})

    if(NOT GTK_DOC_SOURCE)
        message(FATAL_ERROR "No SOURCE specified for gtk_doc_add_module ${_doc_prefix}")
    endif()

    set(_xml_file ${GTK_DOC_XML})

    set(_fixxrefopts ${GTK_DOC_FIXXREFOPTS})
    set(_ignore_headers ${GTK_DOC_IGNOREHEADERS})
    set(_ignore_files ${GTK_DOC_IGNOREFILES})
    set(_libraries ${GTK_DOC_LIBRARIES})
    set(_library_dirs ${GTK_DOC_LIBRARY_DIRS})
    set(_suffixes ${GTK_DOC_SUFFIXES})

    set(_extra_cflags ${GTK_DOC_CFLAGS})
    set(_depends ${GTK_DOC_DEPENDS})
    set(_extra_ldflags ${GTK_DOC_LDFLAGS})
    set(_extra_ldpath ${GTK_DOC_LDPATH})

    if(_suffixes)
        set(_doc_source_suffixes "")
        foreach(_suffix ${_suffixes})
            if(_doc_source_suffixes)
                set(_doc_source_suffixes "${_doc_source_suffixes},${_suffix}")
            else(_doc_source_suffixes)
                set(_doc_source_suffixes "${_suffix}")
            endif(_doc_source_suffixes)
        endforeach(_suffix)
    else(_suffixes)
        set(_doc_source_suffixes "h")
    endif(_suffixes)

    # Parse the LIBRARIES option and collect compile and link flags for those
    # targets.
    foreach(target ${_libraries})
        _gtk_doc_get_cflags_for_target(_target_cflags ${target})
        _gtk_doc_get_ldflags_for_target(_target_ldflags ${target} "${_libraries}")
        list(APPEND _extra_cflags ${_target_cflags})
        list(APPEND _extra_ldflags ${_target_ldflags})
        list(APPEND _extra_ldpath $<TARGET_FILE_DIR:${target}>)

        list(APPEND _depends ${target})
    endforeach()

    # Link directories can't be specified per target, only for every target
    # under a given directory.
    get_property(all_library_directories DIRECTORY PROPERTY LINK_DIRECTORIES)
    foreach(library_dir ${all_library_directories})
        list(APPEND _extra_ldflags ${CMAKE_LIBRARY_PATH_FLAG}${library_dir})
        list(APPEND _extra_ldpath ${library_dir})
    endforeach()

    # a directory to store output.
    set(_output_dir "${CMAKE_CURRENT_BINARY_DIR}/${_doc_prefix}")
    set(_output_dir_stamp "${_output_dir}/dir.stamp")

    # set default sgml file if not specified
    set(_default_xml_file "${_output_dir}/${_doc_prefix}-docs.xml")
    get_filename_component(_default_xml_file ${_default_xml_file} ABSOLUTE)

    # a directory to store html output.
    set(_output_html_dir "${_output_dir}/html")
    set(_output_html_dir_stamp "${_output_dir}/html_dir.stamp")

    # The output files
    set(_output_scan_stamp "${_output_dir}/scan.stamp")
    set(_output_decl_list "${_output_dir}/${_doc_prefix}-decl-list.txt")
    set(_output_decl "${_output_dir}/${_doc_prefix}-decl.txt")
    set(_output_overrides "${_output_dir}/${_doc_prefix}-overrides.txt")
    set(_output_sections "${_output_dir}/${_doc_prefix}-sections.txt")
    set(_output_types "${_output_dir}/${_doc_prefix}.types")

    set(_output_scangobj_stamp "${_output_dir}/scangobj.stamp")
    set(_output_signals "${_output_dir}/${_doc_prefix}.signals")
    set(_output_hierarchy "${_output_dir}/${_doc_prefix}.hierarchy")
    set(_output_interfaces "${_output_dir}/${_doc_prefix}.interfaces")
    set(_output_prerequisites "${_output_dir}/${_doc_prefix}.prerequisites")
    set(_output_args "${_output_dir}/${_doc_prefix}.args")

    set(_output_unused "${_output_dir}/${_doc_prefix}-unused.txt")
    set(_output_undeclared "${_output_dir}/${_doc_prefix}-undeclared.txt")
    set(_output_undocumented "${_output_dir}/${_doc_prefix}-undocumented.txt")

    set(_output_xml_dir "${_output_dir}/xml")
    set(_output_sgml_stamp "${_output_dir}/sgml.stamp")

    set(_output_html_stamp "${_output_dir}/html.stamp")

    if(GTKDOC_REBASE_ONLINE)
        set(_rebase_online_option "--online")
    endif(GTKDOC_REBASE_ONLINE)
    if(DESTDIR)
        set(_rebase_dest_dir_option, "--dest-dir=${DESTDIR}")
    endif(DESTDIR)

    # add a command to create output directory
    add_custom_command(
        OUTPUT "${_output_dir_stamp}" "${_output_dir}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${_output_dir}"
        COMMAND ${CMAKE_COMMAND} -E touch ${_output_dir_stamp}
        VERBATIM)

    set(_ignore_headers_opt "")
    if(_ignore_headers)
        set(_ignore_headers_opt "--ignore-headers=")
        foreach(_header ${_ignore_headers})
            set(_ignore_headers_opt "${_ignore_headers_opt}${_header} ")
        endforeach(_header ${_ignore_headers})
    endif(_ignore_headers)

    set(_ignore_files_opt "")
    if(_ignore_files)
        set(_ignore_files_opt "--ignore-files=")
        foreach(_file ${_ignore_files})
            set(_ignore_files_opt "${_ignore_files_opt}${_file} ")
        endforeach(_file ${_ignore_files})
    endif(_ignore_files)

    foreach(source_dir ${GTK_DOC_SOURCE})
        set(_source_dirs_opt ${_source_dirs_opt} --source-dir=${source_dir})
    endforeach()

    # add a command to scan the input
    add_custom_command(
        OUTPUT
            "${_output_scan_stamp}"
            "${_output_decl_list}"
            "${_output_decl}"
            "${_output_overrides}"
            "${_output_sections}"
            "${_output_types}"
        DEPENDS
            "${_output_dir_stamp}"
            ${_depends}
        COMMAND
            ${GTKDOC_SCAN_EXE}
            --module=${_doc_prefix}
            ${_ignore_headers_opt}
            ${_source_dirs_opt}
            --rebuild-sections
            --rebuild-types
        COMMAND
            ${CMAKE_COMMAND} -E touch ${_output_scan_stamp}
        WORKING_DIRECTORY ${_output_dir}
        VERBATIM)

    foreach(flag ${_extra_cflags} ${GTKDOC_SCANGOBJ_DEPS_CFLAGS})
        if(_cflags)
            set(_cflags "${_cflags} ")
        endif()
        set(_cflags "${_cflags}${flag}")
    endforeach()

    foreach(flag ${_extra_ldflags} ${GTKDOC_SCANGOBJ_DEPS_LDFLAGS})
        if(_ldflags)
            set(_ldflags "${_ldflags} ")
        endif()
        set(_ldflags "${_ldflags}${flag}")
    endforeach()

    foreach(path ${_extra_ldpath})
        if(_ldpath)
            set(_ldpath "${_ldpath}:")
        endif()
        set(_ldpath "${_ldpath}${path}")
    endforeach()

    # add a command to scan the input via gtkdoc-scangobj
    add_custom_command(
        OUTPUT
            ${_output_scangobj_stamp}
            ${_output_signals}
            ${_output_hierarchy}
            ${_output_interfaces}
            ${_output_prerequisites}
            ${_output_args}
        DEPENDS
            ${_output_types}
        COMMAND ${GTKDOC_SCANGOBJ_EXE}
            "--module=${_doc_prefix}"
            "--types=${_output_types}"
            "--output-dir=${_output_dir}"
            "--cflags=${_cflags}"
            "--ldflags=${_ldflags}"
            "--run=LD_LIBRARY_PATH=${_ldpath}"
        COMMAND
            ${CMAKE_COMMAND} -E touch ${_output_scangobj_stamp}
        WORKING_DIRECTORY "${_output_dir}"
        VERBATIM)

    set(_copy_xml_if_needed "")
    if(_xml_file)
        get_filename_component(_xml_file ${_xml_file} ABSOLUTE)
        set(_copy_xml_if_needed
            COMMAND ${CMAKE_COMMAND} -E copy "${_xml_file}" "${_default_xml_file}")
    endif(_xml_file)

    set(_remove_xml_if_needed "")
    if(_xml_file)
        set(_remove_xml_if_needed
            COMMAND ${CMAKE_COMMAND} -E remove ${_default_xml_file})
    endif(_xml_file)

    # add a command to make the database
    add_custom_command(
        OUTPUT
            ${_output_sgml_stamp}
            ${_default_xml_file}
        DEPENDS
            ${_output_types}
            ${_output_signals}
            ${_output_sections}
            ${_output_overrides}
            ${_depends}
        ${_remove_xml_if_needed}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${_output_xml_dir}
        COMMAND ${GTKDOC_MKDB_EXE}
            --module=${_doc_prefix}
            ${_ignore_files_opt}
            ${_source_dirs_opt}
            --source-suffixes=${_doc_source_suffixes}
            --output-format=xml
            --main-sgml-file=${_default_xml_file}
        ${_copy_xml_if_needed}
        WORKING_DIRECTORY "${_output_dir}"
        VERBATIM)

    # add a command to create html directory
    add_custom_command(
        OUTPUT "${_output_html_dir_stamp}" "${_output_html_dir}"
        COMMAND ${CMAKE_COMMAND} -E make_directory ${_output_html_dir}
        COMMAND ${CMAKE_COMMAND} -E touch ${_output_html_dir_stamp}
        VERBATIM)

    # add a command to output HTML
    add_custom_command(
        OUTPUT
            ${_output_html_stamp}
        DEPENDS
            ${_output_html_dir_stamp}
            ${_output_sgml_stamp}
            ${_xml_file}
            ${_depends}
        ${_copy_xml_if_needed}
        # The binary dir needs adding to --path in order for mkhtml to pick up
        # any version.xml file there might be in there
        COMMAND
            cd ${_output_html_dir} && ${GTKDOC_MKHTML_EXE}
                ${_doc_prefix}
                ${_default_xml_file}
        COMMAND
            cd ${_output_dir} && ${GTKDOC_FIXXREF_EXE}
                --module=${_doc_prefix}
                --module-dir=${_output_html_dir}
                ${_fixxref_opts}
        COMMAND
            ${GTKDOC_REBASE_EXE}
                --html-dir=${_output_html_dir}
                ${_rebase_online_option}
                ${_rebase_dest_dir_option}
        COMMENT
            "Generating HTML documentation for ${_doc_prefix} module with gtkdoc-mkhtml"
        VERBATIM)

    add_custom_target(doc-${_doc_prefix}
        DEPENDS "${_output_html_stamp}")
endfunction(gtk_doc_add_module)

# These two functions reimplement some of the core logic of CMake, in order
# to generate compiler and linker flags from the relevant target properties.
# It sucks that we have to do this, but CMake's own code for this doesn't seem
# to be reusable -- there's no way to say "tell me the flags that you would
# pass to a linker for this target".

function(_gtk_doc_get_cflags_for_target result_var target)
    get_target_property(target_definitions ${target} COMPILE_DEFINITIONS)
    if(target_definitions)
        list(APPEND cflags ${target_definitions})
    endif()

    get_target_property(target_options ${target} COMPILE_OPTIONS)
    if(target_options)
        list(APPEND cflags ${target_options})
    endif()

    get_target_property(target_include_dirs ${target} INCLUDE_DIRECTORIES)
    if(target_include_dirs)
        foreach(target_include_dir ${target_include_dirs})
            list(APPEND cflags -I${target_include_dir})
        endforeach()
    endif()

    if(cflags)
        list(REMOVE_DUPLICATES cflags)
        list(SORT cflags)
    endif()

    set(${result_var} ${cflags} PARENT_SCOPE)
endfunction()

function(_gtk_doc_get_ldflags_for_target result_var target all_targets)
    get_target_property(target_link_flags ${target} LINK_FLAGS)
    if(target_link_flags)
        list(APPEND ldflags ${target_link_flags})
    endif()

    get_target_property(target_link_libraries ${target} LINK_LIBRARIES)
    foreach(target_library ${target_link_libraries})
        # The IN_LIST operator is new in CMake 3.3, so I've tried to avoid using it.
        list(FIND all_targets ${target_library} target_library_is_explicit_dependency)
        if(NOT ${target_library_is_explicit_dependency} EQUAL -1)
            # This target is part of the current project. We will add it to
            # LDFLAGS explicitly, so don't try to add it with -l<target> as
            # well. In fact, we can't do that, as the containing directory
            # probably won't be in the linker search path, and we can't find
            # that out and add it ourselves.
        elseif(EXISTS ${target_library})
            # Pass the filename directly to the linker.
            list(APPEND ldflags "${target_library}")
        else()
            # Pass -l<filename> to the linker.
            list(APPEND ldflags "${CMAKE_LINK_LIBRARY_FLAG}${target_library}")
        endif()
    endforeach()

    # Link in the actual target, as well.
    list(APPEND ldflags $<TARGET_FILE:${target}>)

    list(REMOVE_DUPLICATES ldflags)
    list(SORT ldflags)

    set(${result_var} ${ldflags} PARENT_SCOPE)
endfunction()
