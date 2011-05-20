## TODO:  KENT:  Every one of the options listed in should be configurable as build time of wether to include them or not.
##       This one file should have if(BUILD_BRAINSFIT) around the brainsfit to deterimine if it gets built or not.
##       It is my hope that I can include this one external file in Slicer3, and BRAINS3, and the configure which tools are build with options.

set(MIDAS_REST_URL
  "http://midas.kitware.com/api/rest"
  CACHE STRING "The MIDAS server where testing data resides")

macro(BuildExtPackage PackageName PackageRepo REVISIONCODE PACKAGE_DEPENDANCIES)
  if("${PackageRepo}" STREQUAL "")
    set(SRCCMDS
      SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR ${PROJECT_EXTERNAL_SHARED_SOURCE_TREE}/}/${PackageName}
      )
  else()
    set(SRCCMDS
      SVN_REPOSITORY ${PackageRepo}
      SVN_USERNAME "slicerbot"
      SVN_PASSWORD "slicer"
      SOURCE_DIR ${PROJECT_EXTERNAL_SHARED_SOURCE_TREE}/${PackageName}
      )
    if("${REVISIONCODE}" STREQUAL "")
    else()
      set(SRCCMDS
        ${SRCCMDS}
        SVN_REVISION -r ${REVISIONCODE}
        )
    endif()
  endif()
  ExternalProject_Add(${PackageName}
    ${SRCCMDS}
    BINARY_DIR ${PackageName}-build
    CMAKE_GENERATOR ${gen}
    DEPENDS ${PACKAGE_DEPENDANCIES}
    CMAKE_ARGS
    ${ep_common_args}
    -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
    -DMIDAS_REST_URL:STRING=${MIDAS_REST_URL}
    -DITK_DIR:PATH=${ITK_DIR}
    -DVTK_DIR:PATH=${VTK_DIR}
    -DOpenCV_DIR:PATH=${OpenCV_DIR}
    -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    -DHDF5_DIR:PATH=${HDF5_DIR}
    -Dhdf5_DIR:PATH=${hdf5_DIR}
    ### HACK:  Need to evaluate these command line arguments
    -DBRAINSCommonLib_DIR:PATH=${BRAINSCommonLib_DIR}
    -DBRAINS_BUILD:BOOL=${BRAINS_BUILD}
    -DBRAINS_CMAKE_HELPER_DIR:PATH=${BRAINS_CMAKE_HELPER_DIR}
    -DBRAINSLogo:PATH=${BRAINSLogo}
    -DBRAINS3_USE_QT:BOOL=${BRAINS3_USE_QT}
    -DBRAINS3_USE_ITK4:BOOL=${BRAINS3_USE_ITK4}
    #INSTALL_COMMAND ""
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}
    )

  ExternalProject_Add_Step(${PackageName} forcebuild
    COMMAND ${CMAKE_COMMAND} -E remove
    ${CMAKE_CURRENT_BUILD_DIR}/${PackageName}-prefix/src/${PackageName}-stamp/${PackageName}-build
    DEPENDEES configure
    DEPENDERS build
    ALWAYS 1
    )

  set(${PackageName}_DEPEND "${proj}")
  set(${PackageName}_DIR ${BRAINS3_INSTALL_PREFIX}/lib/${PackageName})
  set(${PackageName}_SOURCE_DIR ${PROJECT_EXTERNAL_SHARED_SOURCE_TREE}/${PackageName} )
  message(STATUS "${PackageName}_DIR = ${${PackageName}_DIR}")
endmacro(BuildExtPackage)

BuildExtPackage(BuildScripts
  https://www.nitrc.org/svn/brains/BuildScripts/trunk "{20110520}" "" )

### HACK:  Need to change name of BuildScripts to BRAINSBuildScripts
### HACK:  Need to remove BRAINS_CMAKE_HELPER_DIR in favor of BRAINSBuildScripts
set(BRAINS_CMAKE_HELPER_DIR ${BuildScripts_SOURCE_DIR})

BuildExtPackage(BRAINSCommonLib
  http://www.nitrc.org/svn/brains/BRAINSCommonLib/trunk "{20110515}" "BuildScripts;SlicerExecutionModel")

#set(BRAINSCommonLib_DEPEND "${proj}")
#set(BRAINSCommonLib_DIR ${BRAINS3_INSTALL_PREFIX}/lib/BRAINSCommonLib)
#  message(STATUS "BRAINSCommonLib_DIR = ${BRAINSCommonLib_DIR}")

BuildExtPackage(BRAINSFit
  https://www.nitrc.org/svn/multimodereg/trunk  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(BRAINSMush
  https://www.nitrc.org/svn/brainsmush/trunk  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(BRAINSDemonWarp
  https://www.nitrc.org/svn/brainsdemonwarp/trunk  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(BRAINSROIAuto
  https://www.nitrc.org/svn/brainsroiauto/trunk  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(BRAINSCut
  https://www.nitrc.org/svn/brainscut/trunk  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(GTRACT
  https://www.nitrc.org/svn/vmagnotta/GTRACT  "{20110515}" "BRAINSCommonLib" )

BuildExtPackage(BRAINSMultiModeSegment
  https://www.nitrc.org/svn/brains/BRAINS/trunk/BRAINSTools/BRAINSMultiModeSegment  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(BRAINSResample
  https://www.nitrc.org/svn/brains/BRAINS/trunk/BRAINSTools/BRAINSResample  "{20110515}" "BRAINSCommonLib" )
BuildExtPackage(BRAINSInitilizedControlPoints
  https://www.nitrc.org/svn/brains/BRAINS/trunk/BRAINSTools/BRAINSInitilizedControlPoints  "{20110515}" "BRAINSCommonLib" )

if("${ITK_VERSION_MAJOR}" EQUAL "3")
  BuildExtPackage(DicomToNrrdConverter
    http://svn.slicer.org/Slicer3/trunk/Applications/CLI/DicomToNrrdConverter  "{20110515}" "BRAINSCommonLib" )
  #
  # DicomSignature won't work with ITK4
  BuildExtPackage(DicomSignature
    https://www.nitrc.org/svn/brains/BRAINS/trunk/BRAINSTools/DicomSignature  "{20110515}" "BRAINSCommonLib" )
endif("${ITK_VERSION_MAJOR}" EQUAL "3")

if(${BRAINS3_USE_QT})
  BuildExtPackage(BRAINSImageEval
    http://www.nitrc.org/svn/brainsimageeval  "{20110515}" "BRAINSCommonLib" )
endif(${BRAINS3_USE_QT})

#-----------------------------------------------------------------------------
# ReferenceAtlas
#-----------------------------------------------------------------------------
# Define the atlas subdirectory in one place
set(BRAINS3_RUNTIME_DIR ${CMAKE_CURRENT_BINARY_DIR}/src/bin)

include(External_ReferenceAtlas)
list(APPEND brains3_DEPENDENCIES ${ReferenceAtlas_DEPEND})

#-----------------------------------------------------------------------------
# BRAINSABC
#-----------------------------------------------------------------------------
BuildExtPackage(BRAINSABC
  https://www.nitrc.org/svn/brains/BRAINS/trunk/BRAINSTools/BRAINSABC  "{20110515}" "BRAINSCommonLib;${ReferenceAtlas_DEPEND}" )



#-----------------------------------------------------------------------------
# HDF5
#-----------------------------------------------------------------------------
if(NOT BRAINS3_USE_ITK4)
  include(External_HDF5)
endif(NOT BRAINS3_USE_ITK4)

#-----------------------------------------------------------------------------
# BRAINSABC
#-----------------------------------------------------------------------------
BuildExtPackage(BRAINSConstellationDetector
  https://www.nitrc.org/svn/brainscdetector/trunk  "{20110515}" "BRAINSCommonLib;HDF5" )


