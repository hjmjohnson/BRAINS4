# The Numpy external project 

set(ETSTraits_binary "${CMAKE_CURRENT_BINARY_DIR}/ETSTraits/")
set(ETSTraits_url https://svn.enthought.com/svn/enthought/Traits/tags/3.6.0/)
set(ETSTraits_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure ETSTraits we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/ETSTraits_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/ETSTraits_configure_step.cmake @ONLY)
# to build ETSTraits we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that 
# python can run after it is built on linux
configure_file(
  SuperBuild/ETSTraits_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/ETSTraits_make_step.cmake @ONLY)

# create an external project to download ETSTraits,
# and configure and build it
ExternalProject_Add(ETSTraits
  SVN_REPOSITORY ${ETSTraits_url}
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/ETSTraits
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/ETSTraits
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/ETSTraits_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/ETSTraits_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS ${ETSTraits_DEPENDENCIES}
  )
