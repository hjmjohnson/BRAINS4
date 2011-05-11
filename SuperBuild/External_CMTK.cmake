#
# CMTK at this point must be statically linked, this is a bug in their build system.
# As it happens, it doesn't depend on any of our other build modules, so it
# can be statically linked even if everything else is shared.
#
if(DEFINED CMTK_DIR AND NOT EXISTS ${CMTK_DIR})
  message(FATAL_ERROR "CMTK_DIR variable is defined but corresponds to non-existing directory")
endif()

if(NOT DEFINED CMTK_DIR)

  set(CMTK_DEPEND CMTK)
  set(proj CMTK)
  ExternalProject_add(${proj}
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
    SVN_REPOSITORY https://www.nitrc.org/svn/cmtk/releases/1.5.3/core
#    SVN_REPOSITORY "https://www.nitrc.org/svn/cmtk/tags/BRAINS4"
    SVN_USERNAME "slicerbot"
    SVN_PASSWORD "slicer"
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
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DBUILD_TESTING:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
    )

  set(CMTK_DIR ${proj}-build)

endif(NOT DEFINED CMTK_DIR)
