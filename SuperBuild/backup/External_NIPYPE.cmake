# The Numpy external project 

set(NIPYPE_binary "${CMAKE_CURRENT_BINARY_DIR}/NIPYPE/")
set(NIPYPE_url git://github.com/nipy/nipype.git)
set(NIPYPE_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure NIPYPE we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/NIPYPE_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/NIPYPE_configure_step.cmake @ONLY)
# to build NIPYPE we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that 
# python can run after it is built on linux
configure_file(
  SuperBuild/NIPYPE_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/NIPYPE_make_step.cmake @ONLY)

# create an external project to download NIPYPE,
# and configure and build it
ExternalProject_Add(NIPYPE
  GIT_REPOSITORY ${NIPYPE_url}
  GIT_TAG 7bad7e143d78e65f4beaa5cf0200f3e8c30876f8
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/NIPYPE
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/NIPYPE
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/NIPYPE_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/NIPYPE_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS 
    ${NIPYPE_DEPENDENCIES}
  )
