#
#  SimpleITK externalBuild
#
include(ExternalProject)

ExternalProject_add(SimpleITK
  SOURCE_DIR SimpleITK
  BINARY_DIR SimpleITK-build
  GIT_REPOSITORY https://github.com/hjmjohnson/SimpleITK.git
  GIT_TAG NeverBranchFromThisTest
  #GIT_TAG master
  UPDATE_COMMAND ""
  CMAKE_ARGS
    --no-warn-unused-cli
    ${ep_common_args}
  # SimpleITK does not work with shared libs turned on
  #  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
  -DBUILD_SHARED_LIBS:BOOL=OFF
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
  -DITK_DIR:PATH=${ITK_DIR}
  -DBUILD_EXAMPLES:BOOL=ON
  -DBUILD_TESTING:BOOL=ON
  -DWRAP_PYTHON:BOOL=ON
  -DWRAP_TCL:BOOL=OFF
  -DWRAP_JAVA:BOOL=OFF
  -DWRAP_RUBY:BOOL=OFF
  -DWRAP_LUA:BOOL=OFF
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
  DEPENDS ITK
  #
  # NO INSTALL COMMAND YET!
  INSTALL_COMMAND ${CMAKE_COMMAND} -Dsrc=<BINARY_DIR>/bin 
  -Dprefix=${CMAKE_INSTALL_PREFIX} -P ${CMAKE_CURRENT_LIST_DIR}/SimpleITKInstall.cmake
  # CONFIGURE_COMMAND ../HDF5/configure
  # --prefix=${CMAKE_INSTALL_PREFIX}
  # --enable-cxx
)

