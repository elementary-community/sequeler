# project name
project (com.github.alecaddd.sequeler)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.8)

# enable testing
enable_testing (true)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/com.github.alecaddd.sequeler")

set (EXEC_NAME "com.github.alecaddd.sequeler")
set (RELEASE_NAME "Sequeler")
set (VERSION "0.6.0")
set (VERSION_INFO "Friendly SQL Client")

# disable C compiler warnings
add_definitions(-w)

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED gtk+-3.0 granite glib-2.0 gee-0.8 gobject-2.0 libxml-2.0 libgda-5.0)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.23.2" MINIMUM)

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Main.vala
    src/Application.vala
    src/Window.vala

    src/Partials/HeaderBar.vala
    src/Partials/ButtonType.vala
    src/Partials/MessageDialog.vala
    src/Partials/ErrorDialog.vala

    src/Services/Settings.vala
    src/Services/FileManager.vala
    src/Services/DataBase.vala

    src/Widgets/Welcome.vala
    src/Widgets/Library.vala
    src/Widgets/SettingsDialog.vala
    src/Widgets/ConnectionDialog.vala
    src/Widgets/DataBaseOpen.vala

# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0
    granite
    glib-2.0
    gee-0.8
    gobject-2.0
    libxml-2.0
    libgda-5.0
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --target-glib=2.39
    --thread
    --enable-experimental
)


include (GResource)
glib_compile_resources(GLIB_RESOURCES_ICONS SOURCE /data/assets.gresource.xml)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C} ${GLIB_RESOURCES_ICONS})

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# Translation files
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

add_subdirectory (po)
add_subdirectory (data)
add_subdirectory (schemas)