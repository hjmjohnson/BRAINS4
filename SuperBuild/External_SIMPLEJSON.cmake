# The Numpy external project 

set(SIMPLEJSON_binary "${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON/")
set(SIMPLEJSON_url http://pypi.python.org/packages/source/s/simplejson/simplejson-2.0.9.tar.gz)
set(SIMPLEJSON_md5 af5e67a39ca3408563411d357e6d5e47)
set(SIMPLEJSON_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

# to configure SIMPLEJSON we run a cmake -P script
# the script will create a site.cfg file
# then run python setup.py config to verify setup
configure_file(
  SuperBuild/SIMPLEJSON_configure_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON_configure_step.cmake @ONLY)
# to build SIMPLEJSON we also run a cmake -P script.
# the script will set LD_LIBRARY_PATH so that 
# python can run after it is built on linux
configure_file(
  SuperBuild/SIMPLEJSON_make_step.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON_make_step.cmake @ONLY)

# create an external project to download SIMPLEJSON,
# and configure and build it
ExternalProject_Add(SIMPLEJSON
  URL ${SIMPLEJSON_url}
  URL_MD5 ${SIMPLEJSON_md5}
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON
  CONFIGURE_COMMAND ${CMAKE_COMMAND}
    -DCONFIG_TYPE=${CMAKE_CFG_INTDIR} -P ${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON_configure_step.cmake
  BUILD_COMMAND ${CMAKE_COMMAND}
    -P ${CMAKE_CURRENT_BINARY_DIR}/SIMPLEJSON_make_step.cmake
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
  DEPENDS 
    ${SIMPLEJSON_DEPENDENCIES}
  )
