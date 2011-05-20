if(DEFINED BRAINSTracerQT_DIR AND NOT EXISTS ${BRAINSTracerQT_DIR})
  message(FATAL_ERROR "BRAINSTracerQT_DIR variable is defined but corresponds to non-existing directory")
endif()

if(NOT DEFINED BRAINSTracerQT_DIR)
  # if(APPLE)
  #   set(BRAINSTracer_FIXUP_BUNDLE Off)
  # else()
  #   set(BRAINSTracer_FIXUP_BUNDLE On)
  # endif()

set(proj BRAINSTracerQT)
ExternalProject_Add(${proj}
  SVN_REPOSITORY "https://www.nitrc.org/svn/brainstracer/trunk/BRAINSTracerQT/BRAINSTracerQT"
  SVN_USERNAME "slicerbot"
  SVN_PASSWORD "slicer"
  SOURCE_DIR ${proj}
  BINARY_DIR ${proj}-build
  DEPENDS ${BRAINSTracerQT_DEPENDENCIES}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
  --no-warn-unused-cli
  ${LOCAL_CMAKE_BUILD_OPTIONS}
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
  -DCMAKE_CXX_COMPILER:STRING=${CMAKE_CXX_COMPILER}
  -DCMAKE_CXX_COMPILER_ARG1:STRING=${CMAKE_CXX_COMPILER_ARG1}
  -DCMAKE_C_COMPILER:STRING=${CMAKE_C_COMPILER}
  -DCMAKE_C_COMPILER_ARG1:STRING=${CMAKE_C_COMPILER_ARG1}
  -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=OFF
  -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
  -DITK_DIR:PATH=${ITK_DIR}
  -DVTK_DIR:PATH=${VTK_DIR}
  -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
  -DBRAINSTracer_FIXUP_BUNDLE:BOOL=${BRAINSTracer_FIXUP_BUNDLE}
  )
endif(NOT DEFINED BRAINSTracerQT_DIR)
