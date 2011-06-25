# The Numpy external project

set(IPYTHON_binary "${CMAKE_CURRENT_BINARY_DIR}/IPYTHON/")
set(IPYTHON_url https://github.com/ipython/ipython.git)
set(IPYTHON_md5 5c7b5349dc3161763f7f366ceb96516b)
set(IPYTHON_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure IPYTHON we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/IPYTHON_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/IPYTHON_configure_step.cmake @ONLY)
# to build IPYTHON we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that
# python can run after it is built on linux
configure_file(
  SuperBuild/IPYTHON_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/IPYTHON_make_step.cmake @ONLY)

# create an external project to download IPYTHON,
# and configure and build it
ExternalProject_Add(IPYTHON
  GIT_REPOSITORY ${IPYTHON_url}
  GIT_TAG rel-0.10.2
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/IPYTHON
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/IPYTHON
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/IPYTHON_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/IPYTHON_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    ${IPYTHON_DEPENDENCIES}
  )
