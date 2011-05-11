#
#  vv externalBuild
#
include(ExternalProject)
ExternalProject_add(vv
  SOURCE_DIR vv
  BINARY_DIR vv-build
  GIT_REPOSITORY http://www.creatis.insa-lyon.fr/~dsarrut/clitk3.pub.git
  #  GIT_TAG ConsolodateImageStatMeasurements
  UPDATE_COMMAND ""
  CMAKE_ARGS
    --no-warn-unused-cli
    ${ep_common_args}
  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
  -DITK_DIR:PATH=${ITK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
  DEPENDS ITK VTK
  #
  # NO INSTALL COMMAND YET!
  # CONFIGURE_COMMAND ../HDF5/configure
  # --prefix=${CMAKE_INSTALL_PREFIX}
  # --enable-cxx
)

