# The Numpy external project 

set(MATPLOTLIB_binary "${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB/")
set(MATPLOTLIB_url https://github.com/matplotlib/matplotlib.git)
set(MATPLOTLIB_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure MATPLOTLIB we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/MATPLOTLIB_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB_configure_step.cmake @ONLY)
# to build MATPLOTLIB we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that 
# python can run after it is built on linux
configure_file(
  SuperBuild/MATPLOTLIB_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB_make_step.cmake @ONLY)

# create an external project to download MATPLOTLIB,
# and configure and build it
ExternalProject_Add(MATPLOTLIB
  GIT_REPOSITORY ${MATPLOTLIB_url}
  GIT_TAG v1.0.1
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/MATPLOTLIB_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS 
    ${MATPLOTLIB_DEPENDENCIES}
  )
