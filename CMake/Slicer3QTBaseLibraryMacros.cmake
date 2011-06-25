#
#
#

macro(Slicer3_build_slicer_qtbase_library)
  SLICER3_PARSE_ARGUMENTS(SLICERQTBASELIB
    "NAME;EXPORT_DIRECTIVE;SRCS;MOC_SRCS;UI_SRCS;INCLUDE_DIRECTORIES;TARGET_LIBRARIES;RESOURCES"
    ""
    ${ARGN}
    )

  # Sanity checks
  if(NOT DEFINED SLICERQTBASELIB_NAME)
    message(SEND_ERROR "NAME is mandatory")
  endif(NOT DEFINED SLICERQTBASELIB_NAME)

  if(NOT DEFINED SLICERQTBASELIB_EXPORT_DIRECTIVE)
    message(SEND_ERROR "EXPORT_DIRECTIVE is mandatory")
  endif(NOT DEFINED SLICERQTBASELIB_EXPORT_DIRECTIVE)

  # Define library name
  set(lib_name ${SLICERQTBASELIB_NAME})

  # --------------------------------------------------------------------------
  # Include dirs

  set(QT_INCLUDE_DIRS
    ${QT_INCLUDE_DIR}
    ${QT_QTWEBKIT_INCLUDE_DIR}
    ${QT_QTGUI_INCLUDE_DIR}
    ${QT_QTCORE_INCLUDE_DIR}
    )

  set(include_dirs
    ${QT_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${SlicerBaseLogic_SOURCE_DIR}
    ${SlicerBaseLogic_BINARY_DIR}
    ${qMRMLWidgets_SOURCE_DIR}
    ${qMRMLWidgets_BINARY_DIR}
    ${MRML_SOURCE_DIR}
    ${MRML_BINARY_DIR}
    ${SLICERQTBASELIB_INCLUDE_DIRECTORIES}
    )

  include_directories(${include_dirs})

  slicer3_get_persistent_property(Slicer3_Base_INCLUDE_DIRS tmp)
  slicer3_set_persistent_property(Slicer3_Base_INCLUDE_DIRS ${tmp} ${include_dirs})

  #-----------------------------------------------------------------------------
  # Configure
  #
  set(MY_LIBRARY_EXPORT_DIRECTIVE ${SLICERQTBASELIB_EXPORT_DIRECTIVE})
  set(MY_EXPORT_HEADER_PREFIX ${SLICERQTBASELIB_NAME})
  set(MY_LIBNAME ${lib_name})

  configure_file(
    ${Slicer3_SOURCE_DIR}/qSlicerExport.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    )
  set(dynamicHeaders
    "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")

  #-----------------------------------------------------------------------------
  # Sources
  #

  QT4_WRAP_CPP(SLICERQTBASELIB_MOC_OUTPUT ${SLICERQTBASELIB_MOC_SRCS})
  QT4_WRAP_UI(SLICERQTBASELIB_UI_CXX ${SLICERQTBASELIB_UI_SRCS})
  if(DEFINED SLICERQTBASELIB_RESOURCES)
    QT4_ADD_RESOURCES(SLICERQTBASELIB_QRC_SRCS ${SLICERQTBASELIB_RESOURCES})
  endif(DEFINED SLICERQTBASELIB_RESOURCES)

  QT4_ADD_RESOURCES(SLICERQTBASELIB_QRC_SRCS ${Slicer3_SOURCE_DIR}/Resources/qSlicerLogos.qrc)

  set_source_files_properties(
    ${SLICERQTBASELIB_UI_CXX}
    ${SLICERQTBASELIB_SRCS}
    WRAP_EXCLUDE
    )

  source_group("Resources" FILES
    ${SLICERQTBASELIB_UI_SRCS}
    ${Slicer3_SOURCE_DIR}/Resources/qSlicerLogos.qrc
    ${SLICERQTBASELIB_RESOURCES}
  )

  source_group("Generated" FILES
    ${SLICERQTBASELIB_UI_CXX}
    ${SLICERQTBASELIB_MOC_OUTPUT}
    ${SLICERQTBASELIB_QRC_SRCS}
    ${dynamicHeaders}
  )

  # --------------------------------------------------------------------------
  # Build the library

  slicer3_get_persistent_property(Slicer3_Base_LIBRARIES tmp)
  slicer3_set_persistent_property(Slicer3_Base_LIBRARIES ${tmp} ${lib_name})

  add_library(${lib_name}
    ${SLICERQTBASELIB_SRCS}
    ${SLICERQTBASELIB_MOC_OUTPUT}
    ${SLICERQTBASELIB_UI_CXX}
    ${SLICERQTBASELIB_QRC_SRCS}
    )

  # Apply user-defined properties to the library target.
  if(Slicer3_LIBRARY_PROPERTIES)
    set_target_properties(${lib_name} PROPERTIES ${Slicer3_LIBRARY_PROPERTIES})
  endif(Slicer3_LIBRARY_PROPERTIES)

  set(QT_LIBRARIES
    ${QT_QTCORE_LIBRARY}
    ${QT_QTGUI_LIBRARY}
    ${QT_QTWEBKIT_LIBRARY}
    )

  target_link_libraries(${lib_name}
    ${QT_LIBRARIES}
    ${CTK_EXTERNAL_LIBRARIES}
    ${SLICERQTBASELIB_TARGET_LIBRARIES}
    )

  # Install rules
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION ${Slicer3_INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
    LIBRARY DESTINATION ${Slicer3_INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION ${Slicer3_INSTALL_LIB_DIR} COMPONENT Development
  )

  # Install headers
  file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
  install(FILES
    ${headers}
    ${dynamicHeaders}
    DESTINATION ${Slicer3_INSTALL_INCLUDE_DIR}/${PROJECT_NAME} COMPONENT Development
    )

endmacro(Slicer3_build_slicer_qtbase_library)
