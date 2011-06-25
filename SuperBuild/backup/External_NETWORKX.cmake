# The Numpy external project

set(NETWORKX_binary "${CMAKE_CURRENT_BINARY_DIR}/NETWORKX/")
set(NETWORKX_url http://networkx.lanl.gov/download/networkx/networkx-1.4rc1.tar.gz)
set(NETWORKX_md5 8a22c49c216e36cd3e73ea02896e4ae9)
set(NETWORKX_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure NETWORKX we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/NETWORKX_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/NETWORKX_configure_step.cmake @ONLY)
# to build NETWORKX we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that
# python can run after it is built on linux
configure_file(
  SuperBuild/NETWORKX_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/NETWORKX_make_step.cmake @ONLY)

# create an external project to download NETWORKX,
# and configure and build it
ExternalProject_Add(NETWORKX
  URL ${NETWORKX_url}
  URL_MD5 ${NETWORKX_md5}
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/NETWORKX
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/NETWORKX
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/NETWORKX_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/NETWORKX_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    ${NETWORKX_DEPENDENCIES}
  )
