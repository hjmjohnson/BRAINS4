#
#
include(ExternalProject)
string(REPLACE "-fopenmp" "" HDF_CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
string(REPLACE "-fopenmp" "" HDF_CMAKE_CXX_FLAGS "${CMAKE_CX_FLAGS}")
ExternalProject_add(HDF5
  SOURCE_DIR HDF5
  BINARY_DIR HDF5-build
  SVN_REPOSITORY http://svn.hdfgroup.uiuc.edu/hdf5/branches/hdf5_1_8
  SVN_REVISION -r {2011-04-20}
  UPDATE_COMMAND ""
  CMAKE_ARGS
  # if you build debug you get libraries with _debug in their names
  # which is impossible to deal with. & it isn't like we're going
  # to be debugging HDF any time soon.
    --no-warn-unused-cli
  -DCMAKE_BUILD_TYPE:STRING=Release
  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
  -DCMAKE_CXX_COMPILER_ARG1:STRING=${CMAKE_CXX_COMPILER_ARG1}
  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
  -DCMAKE_C_COMPILER_ARG1:STRING=${CMAKE_C_COMPILER_ARG1}
  -DCMAKE_CXX_FLAGS:STRING=${HDF_CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS:STRING=${HDF_CMAKE_C_FLAGS}
  -DBUILD_SHARED_LIBS:BOOL=Off
  -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=On
  -DHDF5_BUILD_CPP_LIB:BOOL=On
  -DHDF5_BUILD_TOOLS:BOOL=On
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
  INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
  # CONFIGURE_COMMAND ../HDF5/configure
  # --prefix=${CMAKE_INSTALL_PREFIX}
  # --enable-cxx
)

if(0)
ExternalProject_Add_Step(HDF5 fix_H5Oshared_h
  COMMENT "Remove Stupid static inline bogosity from H5Oshared.h"
  DEPENDEES download
  DEPENDERS build
  ALWAYS 1
  COMMAND ${CMAKE_COMMAND} -Dfixfile=<SOURCE_DIR>/src/H5Oshared.h
  -P ${CMAKE_CURRENT_LIST_DIR}/fix_H5Oshared.cmake
  )
endif(0)

set(HDF5_DEPEND HDF5)
set(HDF5_DIR ${CMAKE_INSTALL_PREFIX}/share/cmake/hdf5-1.8.7)
set(hdf5_DIR ${HDF5_DIR})
