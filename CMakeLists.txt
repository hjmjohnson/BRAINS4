#-----------------------------------------------------------------------------
project(BRAINS4)
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
cmake_minimum_required(VERSION 2.8.2)

find_package(Git REQUIRED)

include(ExternalProject)
#-----------------------------------------------------------------------------
set(PROJECT_EXTERNAL_SHARED_SOURCE_TREE ${CMAKE_CURRENT_SOURCE_DIR}/../${CMAKE_PROJECT_NAME}-extsrc)

set(BUILDNAME "NoBuldNameGiven")
set(SITE      "NoSiteGiven")

enable_language(C)
enable_language(CXX)

#-----------------------------------------------------------------------------
# See http://cmake.org/cmake/help/cmake-2-8-docs.html#section_Policies for details
#-----------------------------------------------------------------------------

SET(project_policies
  #CMP0001 # NEW: CMAKE_BACKWARDS_COMPATIBILITY should no longer be used.
  #CMP0002 # NEW: Logical target names must be globally unique.
  CMP0003 # NEW: Libraries linked via full path no longer produce linker search paths.
  #CMP0004 # NEW: Libraries linked may NOT have leading or trailing whitespace.
  #CMP0005 # NEW: Preprocessor definition values are now escaped automatically.
  #CMP0006 # NEW: Installing MACOSX_BUNDLE targets requires a BUNDLE DESTINATION.
  #CMP0007 # NEW: List command no longer ignores empty elements.
  #CMP0008 # NEW: Libraries linked by full-path must have a valid library file name.
  #CMP0009 # NEW: FILE GLOB_RECURSE calls should not follow symlinks by default.
  #CMP0010 # NEW: Bad variable reference syntax is an error.
  #CMP0011 # NEW: Included scripts do automatic cmake_policy PUSH and POP.
  #CMP0012 # NEW: if() recognizes numbers and boolean constants.
  #CMP0013 # NEW: Duplicate binary directories are not allowed.
  #CMP0014 # NEW: Input directories must have CMakeLists.txt
  )
FOREACH(policy ${project_policies})
  IF(POLICY ${policy})
    CMAKE_POLICY(SET ${policy} NEW)
  ENDIF()
ENDFOREACH()

if(NOT SETIFEMPTY)
macro(SETIFEMPTY)
  set(KEY ${ARGV0})
  set(VALUE ${ARGV1})
  if(NOT ${KEY})
    set(${ARGV})
  endif(NOT ${KEY})
endmacro(SETIFEMPTY KEY VALUE)
endif(NOT SETIFEMPTY)
SETIFEMPTY(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
SETIFEMPTY(CMAKE_BUNDLE_OUTPUT_DIRECTORY  ${CMAKE_CURRENT_BINARY_DIR}/bin)
link_directories(${CMAKE_LIBRARY_OUTPUT_DIRECTORY} ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})

#-----------------------------------------------------------------------------
# Platform check
#-----------------------------------------------------------------------------

set(PLATFORM_CHECK true)

if(PLATFORM_CHECK)
  # See CMake/Modules/Platform/Darwin.cmake)
  #   6.x == Mac OSX 10.2 (Jaguar)
  #   7.x == Mac OSX 10.3 (Panther)
  #   8.x == Mac OSX 10.4 (Tiger)
  #   9.x == Mac OSX 10.5 (Leopard)
  #  10.x == Mac OSX 10.6 (Snow Leopard)
  if (DARWIN_MAJOR_VERSION LESS "9")
    message(FATAL_ERROR "Only Mac OSX >= 10.5 are supported !")
  endif()
endif()

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------

set(CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/CMake
  ${CMAKE_SOURCE_DIR}/SuperBuild
  ${CMAKE_BINARY_DIR}/CMake
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/CMake #  CMake directory
  ${CMAKE_CURRENT_SOURCE_DIR}/src/CMake # CMake directory
  ${CMAKE_MODULE_PATH}
  )

#-----------------------------------------------------------------------------
# Prerequisites
#------------------------------------------------------------------------------
#
# BRAINS4 Addition: install to the common library
# directory, so that all libs/include etc ends up
# in one common tree
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH "Where all the prerequisite libraries go" FORCE)
set(${CMAKE_PROJECT_NAME}_BUILD_TESTING ON CACHE BOOL "Turn on Testing for BRAINS")

# Compute -G arg for configuring external projects with the same CMake generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()

#-----------------------------------------------------------------------------
# Always build Shared library
#------------------------------------------------------------------------------
set(BUILD_SHARED_LIBS OFF)

#-----------------------------------------------------------------------------
# Setup build type
#------------------------------------------------------------------------------

# By default, let's build as Debug
if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

# let a dashboard override the default.
if(CTEST_BUILD_CONFIGURATION)
  set(CMAKE_BUILD_TYPE "${CTEST_BUILD_CONFIGURATION}")
endif()

#-------------------------------------------------------------------------
# augment compiler flags
#-------------------------------------------------------------------------
include(CompilerFlagSettings)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_DEBUG_DESIRED_FLAGS}" )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_DEBUG_DESIRED_FLAGS}" )
else() # Release, or anything else
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_RELEASE_DESIRED_FLAGS}" )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_RELEASE_DESIRED_FLAGS}" )
endif()
#message("CMAKE_C_FLAGS ${CMAKE_C_FLAGS}")
#message("CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS}")
#-----------------------------------------------------------------------------
# BRAINS4 Options
#-----------------------------------------------------------------------------
option(${CMAKE_PROJECT_NAME}_BUILD_GUI "Build GUI" ON)
option(${CMAKE_PROJECT_NAME}_USE_QT  "Build BRAINS4 Qt GUI" ON)

if(DARWIN_MAJOR_VERSION GREATER "10")
# For Mac OS X 10.6, Apple has started recommending developers to build their applications 64-bit.
# The main reason is that there is a small speed increase due to the extra registers on Intel
#CPU's, all their machine offerings have been 64-bit since 2007, and there is a cost for reading
# all the 32-bit libraries into memory if everything else is 64-bit. If you want to follow this
# advice, there is only one choice, 64-bit Cocoa.
#
# See CMake/Modules/Platform/Darwin.cmake)
#   6.x == Mac OSX 10.2 (Jaguar)
#   7.x == Mac OSX 10.3 (Panther)
#   8.x == Mac OSX 10.4 (Tiger)
#   9.x == Mac OSX 10.5 (Leopard)
#  10.x == Mac OSX 10.6 (Snow Leopard)
  set(minimum_required_qt_version "4.7.0")
else()
  set(minimum_required_qt_version "4.6.2")
endif()

find_package(Qt4 REQUIRED)
if(QT4_FOUND)
  set(current_qt_version "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}")

  if("${current_qt_version}" VERSION_LESS "${minimum_required_qt_version}")
    message(FATAL_ERROR "error: BRAINS4 requires Qt >= ${minimum_required_qt_version} -- you cannot use Qt ${current_qt_version}.")
  endif()

  # Enable modules
  SET(QT_USE_QTNETWORK ON)

  # Includes Qt headers
  INCLUDE(${QT_USE_FILE})

  option(${CMAKE_PROJECT_NAME}_USE_PYTHONQT "Integrate a python-QT interpreter into BRAINS4." ON)
endif()

#------------------------------------------------------------------------------
# Python option
#------------------------------------------------------------------------------
#option(${CMAKE_PROJECT_NAME}_BUILD_NUMPY "Build BRAINS with NumPy (builds CLapack)." ON)
# Work in progress ...
#HACK  if(${CMAKE_PROJECT_NAME}_BUILD_NUMPY)
    option(${CMAKE_PROJECT_NAME}_BUILD_SCIPY "Build BRAINS with SciPy (requires NumPy)" ON)
#HACK  endif()

#------------------------------------------------------------------------------
# Additional options
#------------------------------------------------------------------------------

# Enable VTK Debug Leaks
option(${CMAKE_PROJECT_NAME}_USE_VTK_DEBUG_LEAKS
  "Turn on VTKs Debug Leaks functionality in both VTK and ${CMAKE_PROJECT_NAME}." ON)

#------------------------------------------------------------------------------
# Validate options
#------------------------------------------------------------------------------

if (${CMAKE_PROJECT_NAME}_USE_PYTHON AND ${CMAKE_PROJECT_NAME}_USE_PYTHONQT)
  set(err "error: ${CMAKE_PROJECT_NAME} SuperBuild doesn't support ${CMAKE_PROJECT_NAME}_USE_PYTHON and ${CMAKE_PROJECT_NAME}_USE_PYTHONQT ON.")
  message(FATAL_ERROR "${err}")
endif()

#------------------------------------------------------------------------------
# Configure the CTest custom file - Used to suppress external project configure/build warnings
#------------------------------------------------------------------------------

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild/CTestCustom.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
  @ONLY IMMEDIATE)

#------------------------------------------------------------------------------
# Establish Target Dependencies based on Selected Options
#------------------------------------------------------------------------------

set(CLAPACK_DEPENDENCIES)
set(python_DEPENDENCIES)
#set(PYTHONSETUPTOOLS_DEPENDANCIES python)

#set(NUMPY_DEPENDENCIES CLAPACK python)
#set(scipy_DEPENDENCIES NUMPY)
#set(NETWORKX_DEPENDENCIES python)
#set(SIMPLEJSON_DEPENDANCIES python)
#set(MATPLOTLIB_DEPENDANCIES python)
#set(NIBABEL_DEPENDANCIES python)
set(SPYDER_DEPENDANCIES python)
#set(ETSTraits_DEPENDANCIES python SPYDER)
set(NIPYPE_DEPENDANCIES SPYDER python)

set(VTK_DEPENDENCIES)
#set(CTK_DEPENDENCIES VTK)

#if(${CMAKE_PROJECT_NAME}_USE_PYTHONQT)
#  list(APPEND CTK_DEPENDENCIES python)
#endif()
set(Insight_DEPENDENCIES python)

set(${CMAKE_PROJECT_NAME}_DEPENDENCIES VTK ITK )
set(SlicerExecutionModel_DEPENDENCIES ITK)

set(BRAINSCommonLib_DEPENDENCIES ITK)

#------------------------------------------------------------------------------
# Conditionnaly include ExternalProject Target
#------------------------------------------------------------------------------

set(ep_common_args
  --no-warn-unused-cli
  -DMAKECOMMAND:STRING=${MAKECOMMAND}
  -DCMAKE_SKIP_RPATH:BOOL=ON
  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
  -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
  -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
  -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
  -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
  -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
  -DBUILD_EXAMPLES:BOOL=OFF
  -DBUILD_TESTING:BOOL=${BUILD_TESTING}
  -DCMAKE_GENERATOR:STRING=${CMAKE_GENERATOR}
  -DCMAKE_EXTRA_GENERATOR:STRING=${CMAKE_EXTRA_GENERATOR}
  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
  -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
  -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
  -DCMAKE_BUNDLE_OUTPUT_DIRECTORY:PATH=${CMAKE_BUNDLE_OUTPUT_DIRECTORY}
  -DCTEST_NEW_FORMAT:BOOL=ON
  -DMEMORYCHECK_COMMAND_OPTIONS:STRING=${MEMORYCHECK_COMMAND_OPTIONS}
  -DMEMORYCHECK_COMMAND:PATH=${MEMORYCHECK_COMMAND}
  -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CMAKE_SHARED_LINKER_FLAGS}
  -DCMAKE_EXE_LINKER_FLAGS:STRING=${CMAKE_EXE_LINKER_FLAGS}
  -DCMAKE_MODULE_LINKER_FLAGS:STRING=${CMAKE_MODULE_LINKER_FLAGS}
  -DSITE:STRING=${SITE}
  -DBUILDNAME:STRING=${BUILDNAME}
)

#------------------------------------------------------------------------------
# FFTW
#------------------------------------------------------------------------------
option(${CMAKE_PROJECT_NAME}_USE_FFTW "Turn on building and installing FFTW" OFF)
mark_as_advanced(${CMAKE_PROJECT_NAME}_USE_FFTW)

if(${CMAKE_PROJECT_NAME}_USE_FFTW)
include(External_FFTW)
set(FFTW_FLAGS
-DFFTW_INSTALL_BASE_PATH:PATH="${FFTW_INSTALL_BASE_PATH}"
-DUSE_FFTWD:BOOL=${USE_FFTWD}
)
endif(${CMAKE_PROJECT_NAME}_USE_FFTW)

include(External_Python26)
#if(${CMAKE_PROJECT_NAME}_BUILD_NUMPY)
  include(External_CLAPACK)
  #  include(External_NUMPY)
  #  include(External_NETWORKX)
  #  include(External_SIMPLEJSON)
  #  include(External_PYTHONSETUPTOOLS)
  #include(External_MATPLOTLIB)
  #  if(${CMAKE_PROJECT_NAME}_BUILD_SCIPY)
  #      include(External_SciPy)
  #  endif(${CMAKE_PROJECT_NAME}_BUILD_SCIPY)
  #endif()
#include(External_NIBABEL)

include(External_SPYDER)
#include(External_ETSTraits)
include(External_NIPYPE)

#-----------------------------------------------------------------------------
# VTK Settings
#------------------------------------------------------------------------------
set(git_protocol "git")
set(${CMAKE_PROJECT_NAME}_VTK_GIT_REPOSITORY "github.com/Slicer/VTK.git" CACHE STRING "repository from which to get VTK")
MARK_AS_ADVANCED(${CMAKE_PROJECT_NAME}_VTK_GIT_REPOSITORY)
include(External_VTK)

# if(${CMAKE_PROJECT_NAME}_USE_QT)
#   include(External_CTK)
# endif()

set(ITK_WRAPPING ON CACHE BOOL "Turn on wrapping ITK with WrapITK")

include(External_ITKv4)
list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES ITK)
include(External_Swig)
include(External_SimpleITK)
list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES SimpleITK)

include(External_SlicerExecutionModel)
list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES ${GenerateCLP_DEPEND} NIPYPE)


#-----------------------------------------------------------------------------
# Update external project dependencies
#------------------------------------------------------------------------------
#if(${CMAKE_PROJECT_NAME}_USE_PYTHON OR ${CMAKE_PROJECT_NAME}_USE_PYTHONQT)
  list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES python)
#  if(${CMAKE_PROJECT_NAME}_BUILD_NUMPY)
#    list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES NUMPY)
#    if(${CMAKE_PROJECT_NAME}_BUILD_SCIPY)
#      list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES scipy)
#    endif()
#  endif()
#endif()

#------------------------------------------------------------------------------
# OpenCV
#------------------------------------------------------------------------------
set(Build_OpenCV ON CACHE BOOL "Set ON to build OpenCV for use with BRAINSCut")

if(Build_OpenCV)
include(External_OpenCV)
list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES ${OpenCV_DEPEND})
endif(Build_OpenCV)

#-----------------------------------------------------------------------------
# CMTK
#-----------------------------------------------------------------------------
#include(External_CMTK)
#list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES ${CMTK_DEPEND})

#-----------------------------------------------------------------------------
# BRAINSTracerQT
#-----------------------------------------------------------------------------
##HACK if (${CMAKE_PROJECT_NAME}_USE_QT)
##HACK set(BRAINSTracerQT_DEPENDENCIES ITK VTK ${GenerateCLP_DEPEND})
##HACK include(External_BRAINSTracerQT)
##HACK endif()

#-----------------------------------------------------------------------------
# vv
#-----------------------------------------------------------------------------
#include(External_vv)

#------------------------------------------------------------------------------
# BuildName used for dashboard reporting
#
set(BUILDNAME "Unknown-build" CACHE STRING "Name of build to report to dashboard")

#------------------------------------------------------------------------------
# List of external projects
#------------------------------------------------------------------------------

set(external_project_list  python CLAPACK VTK ITK )

#-----------------------------------------------------------------------------
# Dump external project dependencies
#------------------------------------------------------------------------------

set(ep_dependency_graph "# External project dependencies")
foreach(ep ${external_project_list})
  set(ep_dependency_graph "${ep_dependency_graph}\n${ep}:${${ep}_DEPENDENCIES}")
endforeach()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/ExternalProjectDependencies.txt "${ep_dependency_graph}\n")

#-----------------------------------------------------------------------------
# Update external BRAINS* project dependencies
#------------------------------------------------------------------------------
include(External_BRAINSCommonLib)
list(APPEND ${CMAKE_PROJECT_NAME}_DEPENDENCIES BRAINSCommonLib BRAINSFit BRAINSDemonWarp)

#-----------------------------------------------------------------------------
# Configure and build Slicer
# Note that the Slicer3Version.txt file will be created at configuration time
#------------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Find the test data
if(0)  ## HACK
if(${CMAKE_PROJECT_NAME}_BUILD_TESTING)
  enable_testing()
  find_package(BrainsRegressionData REQUIRED)
  if(NOT BrainsRegressionData_FOUND)
    message(FATAL_ERROR "Cannot test ${CMAKE_PROJECT_NAME} without the regressiontest tree.")
  endif(NOT BrainsRegressionData_FOUND)
endif(${CMAKE_PROJECT_NAME}_BUILD_TESTING)
endif(0)

if(0)

set(PackageName BRAINS4)
set(SRCCMDS
      SVN_REPOSITORY https://www.nitrc.org/svn/brains/BRAINS/branches/BRAINS4_v0
      SVN_USERNAME "slicerbot"
      SVN_PASSWORD "slicer"
      SOURCE_DIR ${PROJECT_EXTERNAL_SHARED_SOURCE_TREE}/${PackageName}
)
MESSAGE("BRAINS4 Dependancies:  ${${CMAKE_PROJECT_NAME}_DEPENDENCIES} ")
set(proj BRAINS4)
ExternalProject_Add(${proj}
  ${SRCCMDS}
  DEPENDS ${${CMAKE_PROJECT_NAME}_DEPENDENCIES}
  BINARY_DIR src
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${ep_common_args}
    -DBUILDNAME:STRING=${BUILDNAME}
    -DSITE:STRING=${SITE}
    -D${CMAKE_PROJECT_NAME}_USE_QT:BOOL=${${CMAKE_PROJECT_NAME}_USE_QT}
    -DSubversion_SVN_EXECUTABLE:FILEPATH=${Subversion_SVN_EXECUTABLE}
    -D${CMAKE_PROJECT_NAME}_CMAKE_HELPER_DIR:PATH=${PROJECT_EXTERNAL_SHARED_SOURCE_TREE}/BuildScripts
    # SlicerExecutionModel
    -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
    # BRAINSCommonLib
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBRAINSCommonLib_DIR:PATH=${BRAINSCommonLib_DIR}
    -DBUILD_TESTING:BOOL=${${CMAKE_PROJECT_NAME}_BUILD_TESTING}
    -D${CMAKE_PROJECT_NAME}_BUILD_TESTING:BOOL=${${CMAKE_PROJECT_NAME}_BUILD_TESTING}
    -DBrainsRegressionData_DIR:PATH=${BrainsRegressionData_DIR}
    # ITK
    -DITK_DIR:PATH=${ITK_DIR}
    -DWrapITK_DIR:PATH=${WrapITK_DIR}
    # VTK
    -DVTK_DIR:PATH=${VTK_DIR}
    -DVTK_DEBUG_LEAKS:BOOL=${${CMAKE_PROJECT_NAME}_USE_VTK_DEBUG_LEAKS}
    # OpenCV
    -DOpenCV_DIR:PATH=${OpenCV_DIR}
    # Python
    -D${CMAKE_PROJECT_NAME}_USE_PYTHON:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHON}
    -D${CMAKE_PROJECT_NAME}_USE_PYTHONQT:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
    -D${CMAKE_PROJECT_NAME}_USE_SYSTEM_PYTHON:BOOL=OFF
    -D${CMAKE_PROJECT_NAME}_USE_NUMPY:BOOL=${${CMAKE_PROJECT_NAME}_BUILD_NUMPY}
    -DPYTHON_EXECUTABLE:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}
    -DPYTHON_INCLUDE_DIR:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_INCLUDE}
    -DPYTHON_LIBRARY:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_LIBRARY}
    # Qt
    -DQT_QMAKE_EXECUTABLE:PATH=${QT_QMAKE_EXECUTABLE}
    -DCTK_DIR:PATH=${CTK_DIR}
    # OpenCV
    -DOpenCV_DIR:PATH=${OpenCV_DIR}
    -DATLAS_NAME:STRING=${ATLAS_NAME}
    # HDF5
    -DHDF5_DIR:PATH=${HDF5_DIR}
  INSTALL_COMMAND ""
  BUILD_COMMAND ${BUILD_COMMAND_STRING}
)

ExternalProject_Add_Step(${proj} forcebuild
  COMMAND ${CMAKE_COMMAND} -E remove
    ${CMAKE_CURRENT_BUILD_DIR}/${proj}-prefix/src/${proj}-stamp/${proj}-build
  DEPENDEES configure
  DEPENDERS build
  ALWAYS 1
  )

#
# target to produce a deployable directory tree
#
add_custom_target(${CMAKE_PROJECT_NAME}_Deploy
  COMMAND ${CMAKE_COMMAND}
  -D${CMAKE_PROJECT_NAME}_BINARY_DIR:PATH="${${CMAKE_PROJECT_NAME}_BINARY_DIR}"
  -DCMAKE_INSTALL_PREFIX:PATH="${CMAKE_INSTALL_PREFIX}"
  -DDEPLOY_SYSTEM_NAME:STRING="${CMAKE_SYSTEM}"
  -P "${CMAKE_CURRENT_LIST_DIR}/Deploy.cmake"
)
add_dependencies(${CMAKE_PROJECT_NAME}_Deploy BRAINS4)

endif()
