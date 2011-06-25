# The Numpy external project

set(PYTHONSETUPTOOLS_binary "${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS/")
set(PYTHONSETUPTOOLS_url http://svn.python.org/projects/sandbox/branches/setuptools-0.6)
set(PYTHONSETUPTOOLS_md5 bfa92100bd772d5a213eedd356d64086)
set(PYTHONSETUPTOOLS_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure PYTHONSETUPTOOLS we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/PYTHONSETUPTOOLS_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS_configure_step.cmake @ONLY)
# to build PYTHONSETUPTOOLS we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that
# python can run after it is built on linux
configure_file(
  SuperBuild/PYTHONSETUPTOOLS_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS_make_step.cmake @ONLY)

# create an external project to download PYTHONSETUPTOOLS,
# and configure and build it
ExternalProject_Add(PYTHONSETUPTOOLS
  SVN_REPOSITORY ${PYTHONSETUPTOOLS_url}
  SVN_REVISION -r 88794
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/PYTHONSETUPTOOLS_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS
    ${PYTHONSETUPTOOLS_DEPENDENCIES}
  )
