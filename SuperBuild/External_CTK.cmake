#-----------------------------------------------------------------------------
# Get and build CTK
if (${CMAKE_PROJECT_NAME}_USE_QT)

# Sanity checks
if(DEFINED CTK_DIR AND NOT EXISTS ${CTK_DIR})
  message(FATAL_ERROR "CTK_DIR variable is defined but corresponds to non-existing directory")
endif()

set(proj CTK)

if(NOT DEFINED CTK_DIR)
#    message(STATUS "Adding project:${proj}")
  ExternalProject_Add(${proj}
    GIT_REPOSITORY "${git_protocol}://github.com/commontk/CTK.git"
    GIT_TAG "origin/master"
    SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}
    BINARY_DIR ${proj}-build
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${ep_common_args}
      -DADDITIONAL_CXX_FLAGS=${ep_common_cxx_flags}
      -DADDITIONAL_C_FLAGS=${ep_common_c_flags}
      -DCTK_INSTALL_LIB_DIR:STRING=${${CMAKE_PROJECT_NAME}_INSTALL_LIB_DIR}
      -DCTK_USE_GIT_PROTOCOL:BOOL=${${CMAKE_PROJECT_NAME}_USE_GIT_PROTOCOL}
      -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
      -DVTK_DIR:PATH=${VTK_DIR}
      -DITK_DIR:PATH=${ITK_DIR}
      -DPYTHON_LIBRARY:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_LIBRARY}
      -DPYTHON_INCLUDE_DIR:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_INCLUDE}
      -DPYTHON_EXECUTABLE:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}
      -DCTK_LIB_Widgets:BOOL=ON
      -DCTK_LIB_Visualization/VTK/Widgets:BOOL=ON
      -DCTK_LIB_ImageProcessing/ITK/Core:BOOL=ON
      -DCTK_LIB_Scripting/Python/Core:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_LIB_Scripting/Python/Core_PYTHONQT_USE_VTK:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTCORE:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTGUI:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTUITOOLS:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_LIB_Scripting/Python/Widgets:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_WRAP_PYTHONQT_LIGHT:BOOL=${${CMAKE_PROJECT_NAME}_USE_PYTHONQT}
      -DCTK_LIB_PluginFramework:BOOL=OFF
      -DCTK_PLUGIN_org.commontk.eventbus:BOOL=OFF
      -DGIT_EXECUTABLE:FILEPATH=${GIT_EXECUTABLE}
    INSTALL_COMMAND ""
    DEPENDS
      ${CTK_DEPENDENCIES}
    )
  set(CTK_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  # The project is provided using CTK_DIR, nevertheless since other project may depend on CTK,
  # let's add an 'empty' one
  SlicerMacroEmptyExternalProject(${proj} "${CTK_DEPENDENCIES}")
endif()

