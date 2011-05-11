if(DEFINED CableSwig_DIR AND NOT EXISTS ${CableSwig_DIR})
  message(FATAL_ERROR "CableSwig_DIR variable is defined but corresponds to non-existing directory")
endif()

if(NOT DEFINED CableSwig_DIR)

set(CableSwig_DEPEND CableSwig)
set(proj CableSwig)
ExternalProject_add(${proj}
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
CVS_REPOSITORY ":pserver:anonymous@public.kitware.com:/cvsroot/CableSwig"
#CVS_TAG -r ITK-3-18
CVS_TAG -D "2010-09-09 08:00"
CVS_MODULE "CableSwig"
UPDATE_COMMAND ""
CMAKE_ARGS
    --no-warn-unused-cli
      -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_COMPILER_ARG1:STRING=${CMAKE_CXX_COMPILER_ARG1}
      -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
      -DCMAKE_C_COMPILER_ARG1:STRING=${CMAKE_C_COMPILER_ARG1}
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_EXAMPLES:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
      -DSWIG_DIR:PATH=${SWIG_DIR}
      -DSWIG_EXECUTABLE:PATH=${SWIG_EXECUTABLE}
INSTALL_COMMAND ""
DEPENDS ${Swig_DEPEND}
)
set(CableSwig_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
endif(NOT DEFINED CableSwig_DIR)
