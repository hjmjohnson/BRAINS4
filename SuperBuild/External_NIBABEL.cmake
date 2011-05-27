# The Numpy external project 

set(NIBABEL_binary "${CMAKE_CURRENT_BINARY_DIR}/NIBABEL/")
set(NIBABEL_url http://github.com/nipy/nibabel.git)
set(NIBABEL_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure NIBABEL we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/NIBABEL_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/NIBABEL_configure_step.cmake @ONLY)
# to build NIBABEL we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that 
# python can run after it is built on linux
configure_file(
  SuperBuild/NIBABEL_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/NIBABEL_make_step.cmake @ONLY)

# create an external project to download NIBABEL,
# and configure and build it
ExternalProject_Add(NIBABEL
  GIT_REPOSITORY ${NIBABEL_url}
  GIT_TAG  aac6a669308c9965ddfd
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/NIBABEL
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/NIBABEL
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/NIBABEL_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/NIBABEL_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS ${NIBABEL_DEPENDENCIES}
  )
