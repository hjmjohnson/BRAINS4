
#-----------------------------------------------------------------------------
# Get and build itk

set(ITK_PYTHON_ARGS
      -DPYTHON_EXECUTABLE:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}
      -DPYTHON_INCLUDE_DIR:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_INCLUDE}
      -DPYTHON_LIBRARY:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_LIBRARY}
      )

# Sanity checks
if(DEFINED ITK_DIR AND NOT EXISTS ${ITK_DIR})
  message(FATAL_ERROR "ITK_DIR variable is defined but corresponds to non-existing directory")
endif()


if(NOT DEFINED ITK_DIR)
  #
  # this code fixes a loony problem with HDF5 -- it doesn't
  # link properly if -fopenmp is used.
  string(REPLACE "-fopenmp" "" ITK_CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  string(REPLACE "-fopenmp" "" ITK_CMAKE_CXX_FLAGS "${CMAKE_CX_FLAGS}")

  set(proj ITK)  ## Use ITKv4 convention of calling it ITK
  set(ITK_REPOSITORY git://itk.org/ITK.git)
  set(ITK_DIR ${CMAKE_INSTALL_PREFIX}/lib/cmake/ITK-4.0)
  set(ITK_TAG_COMMAND GIT_TAG 0d025b7545894990b03c478e3165e2461f56a2a4)
  set(WrapITK_DIR ${CMAKE_INSTALL_PREFIX}/lib/cmake/ITK-4.0/WrapITK)
  message(STATUS "ITK_WRAPPING=${ITK_WRAPPING}")
  ExternalProject_Add(${proj}
    GIT_REPOSITORY ${ITK_REPOSITORY}
    ${ITK_TAG_COMMAND}
    UPDATE_COMMAND ""
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
    --no-warn-unused-cli
    -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_COMPILER_ARG1:STRING=${CMAKE_CXX_COMPILER_ARG1}
    -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
    -DCMAKE_C_COMPILER_ARG1:STRING=${CMAKE_C_COMPILER_ARG1}
    -DCMAKE_CXX_FLAGS:STRING=${ITK_CMAKE_CXX_FLAGS}
    -DCMAKE_C_FLAGS:STRING=${ITK_CMAKE_C_FLAGS}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_SKIP_RPATH:BOOL=ON
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_TESTING:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DITK_LEGACY_REMOVE:BOOL=ON
    -DITK_BUILD_ALL_MODULES:BOOL=ON
    -DITK_USE_REVIEW:BOOL=ON
    -DUSE_WRAP_ITK:BOOL=OFF ## HACK:  QUICK CHANGE
    -DINSTALL_WRAP_ITK_COMPATIBILITY:BOOL=OFF
    -DWRAP_float:BOOL=ON
    -DWRAP_unsigned_char:BOOL=ON
    -DWRAP_signed_short:BOOL=ON
    -DWRAP_unsigned_short:BOOL=ON
    -DWRAP_complex_float:BOOL=ON
    -DWRAP_vector_float:BOOL=ON
    -DWRAP_covariant_vector_float:BOOL=ON
    -DWRAP_rgb_signed_short:BOOL=ON
    -DWRAP_rgb_unsigned_char:BOOL=ON
    -DWRAP_rgb_unsigned_short:BOOL=ON
    -DWRAP_ITK_TCL:BOOL=OFF
    -DWRAP_ITK_JAVA:BOOL=OFF
    -DWRAP_ITK_PYTHON:BOOL=ON
    ${ITK_PYTHON_ARGS}
    ${FFTW_FLAGS}
    #    ${CableSwig_FLAGS}
    BUILD_COMMAND ${BUILD_COMMAND_STRING}
    DEPENDS
    ${Insight_DEPENDENCIES}
    )
else()
  # The project is provided using ITK_DIR, nevertheless since other project may depend on ITK,
  # let's add an 'empty' one
  ExternalProject_Add(${proj}
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS
    ${Insight_DEPENDENCIES}
    )
endif()
