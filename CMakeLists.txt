cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
project (evalify)
enable_testing ()
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share/evalify")
set (PKGDATADIR "${DATADIR}/evalify")
set (RELEASE_NAME "The PHP eval applications.")
set (VERSION "0.2")
set (VERSION_INFO "Initial release.")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Add 'make dist' command for creating release tarball
set (CPACK_PACKAGE_VERSION ${VERSION})
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

# Some definitions
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

# Vala
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.16" MINIMUM)
include (ValaPrecompile)

add_definitions(-DVALA_VERSION="${VALA_SHORTVER}")
add_definitions(-w) # Disable gcc warnings

# Dependencies
set (EVALIFY_DEPS
  pango
  gtksourceview-3.0
  gio-2.0
  gtk+-3.0)

find_package (PkgConfig)
pkg_check_modules (GTK+ REQUIRED
  gtk+-3.0>=3.10)

pkg_check_modules (LIBSOURCE REQUIRED
  gtksourceview-3.0>=3.10)

pkg_check_modules (DEPS REQUIRED ${EVALIFY_DEPS})

set(NORMAL_CFLAGS ${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
set(NORMAL_LINK_DIRS ${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})
set(NORMAL_LIBRARIES ${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})

add_definitions (${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
link_libraries (${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})

vala_precompile(VALA_C evalify
    src/evalify.vala
PACKAGES
    ${EVALIFY_DEPS}
OPTIONS
    --thread
)
# tranlation stuff

add_executable (evalify ${VALA_C})

install (TARGETS evalify RUNTIME DESTINATION bin)

# Data
set (HICOLOR_DIR share/icons/hicolor)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/evalify.svg DESTINATION ${HICOLOR_DIR}/16x16/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/24/evalify.svg DESTINATION ${HICOLOR_DIR}/24x24/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/32/evalify.svg DESTINATION ${HICOLOR_DIR}/32x32/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/48/evalify.svg DESTINATION ${HICOLOR_DIR}/48x48/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/64/evalify.svg DESTINATION ${HICOLOR_DIR}/64x64/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/128/evalify.svg DESTINATION ${HICOLOR_DIR}/128x128/apps/)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/evalify.desktop DESTINATION share/applications)
