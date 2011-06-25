#
#  Check if VTK was configured with QT,
#  if so, use it,
#  otherwise, complain.
#
option(Slicer3_USE_QT  "Use Qt as an extra GUI library" OFF)

macro(Slicer3_SETUP_QT)

if(Slicer3_USE_QT)
  set(minimum_required_qt_version "4.6.2")
  if(VTK_USE_QVTK)

    # Check if QT_QMAKE_EXECUTABLE is set
    if(NOT VTK_QT_QMAKE_EXECUTABLE)
      message(FATAL_ERROR "error: There is a problem with your configuration, the variable VTK_QT_QMAKE_EXECUTABLE should be exposed by VTK.")
    endif()

    set(QT_QMAKE_EXECUTABLE ${VTK_QT_QMAKE_EXECUTABLE})

    find_package(Qt4)

    message(STATUS "Configuring Slicer with Qt ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}")

    if(QT4_FOUND AND QT_QMAKE_EXECUTABLE)
      # Check version, note that ${QT_VERSION_PATCH} could also be used
      if("${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" VERSION_LESS "${minimum_required_qt_version}")
        message(FATAL_ERROR "error: Slicer requires Qt >= ${minimum_required_qt_version} -- you cannot use Qt ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}. You should probably reconfigure VTK.")
      endif()
      # Enable modules
      set(QT_USE_QTNETWORK ON)
      set(QT_USE_QTTEST ${Slicer3_BUILD_TESTING})

      # Includes Qt headers
      include(${QT_USE_FILE})
    else(QT4_FOUND AND QT_QMAKE_EXECUTABLE)
      message(FATAL_ERROR "error: Qt >= ${minimum_required_qt_version} was not found on your system. You probably need to set the QT_QMAKE_EXECUTABLE variable.")
    endif(QT4_FOUND AND QT_QMAKE_EXECUTABLE)

  else(VTK_USE_QVTK)
     message("error: VTK was not configured to use QT, you probably need to recompile it with VTK_USE_GUISUPPORT ON, VTK_USE_QVTK ON, DESIRED_QT_VERSION 4 and QT_QMAKE_EXECUTABLE set appropriatly. Note that Qt >= ${minimum_required_qt_version} is *required*")
  endif(VTK_USE_QVTK)
endif(Slicer3_USE_QT)

endmacro(Slicer3_SETUP_QT)


