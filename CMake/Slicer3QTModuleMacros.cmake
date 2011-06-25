#
#
#

macro(Slicer3_build_qtmodule)
  SLICER3_PARSE_ARGUMENTS(QTMODULE
    "NAME;TITLE;EXPORT_DIRECTIVE;SRCS;MOC_SRCS;UI_SRCS;INCLUDE_DIRECTORIES;TARGET_LIBRARIES;RESOURCES"
    ""
    ${ARGN}
    )

  # Sanity checks
  if(NOT DEFINED QTMODULE_NAME)
    message(SEND_ERROR "NAME is mandatory")
  endif(NOT DEFINED QTMODULE_NAME)

  if(NOT DEFINED QTMODULE_EXPORT_DIRECTIVE)
    message(SEND_ERROR "EXPORT_DIRECTIVE is mandatory")
  endif(NOT DEFINED QTMODULE_EXPORT_DIRECTIVE)

  if(NOT DEFINED QTMODULE_TITLE)
    set(QTMODULE_TITLE ${QTMODULE_NAME})
  endif(NOT DEFINED QTMODULE_TITLE)

  # Define library name
  set(lib_name qSlicer${QTMODULE_NAME}Module)

  # Define Module title
  add_definitions(-DQTMODULE_TITLE="${QTMODULE_TITLE}")

  # --------------------------------------------------------------------------
  # Find Slicer3

  if(NOT Slicer3_SOURCE_DIR)
    find_package(Slicer3 REQUIRED)
    include(${Slicer3_USE_FILE})
    slicer3_set_default_install_prefix_for_external_projects()
  endif(NOT Slicer3_SOURCE_DIR)

  # --------------------------------------------------------------------------
  # Include dirs

  include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Slicer3_Libs_INCLUDE_DIRS}
    ${Slicer3_Base_INCLUDE_DIRS}
    ${QTMODULE_INCLUDE_DIRECTORIES}
    )

  set(MY_LIBRARY_EXPORT_DIRECTIVE ${QTMODULE_EXPORT_DIRECTIVE})
  set(MY_EXPORT_HEADER_PREFIX qSlicer${QTMODULE_NAME}Module)
  set(MY_LIBNAME ${lib_name})

  configure_file(
    ${Slicer3_SOURCE_DIR}/qSlicerExport.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    )
  set(dynamicHeaders
    "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")


  #file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/Resources/*.h")
  #install(FILES
  #  ${files}
  #  DESTINATION ${Slicer3_INSTALL_INCLUDE_DIR}/${PROJECT_NAME}/Resources COMPONENT Development
  #  )

  #-----------------------------------------------------------------------------
  # Sources
  #

  QT4_WRAP_CPP(QTMODULE_MOC_OUTPUT ${QTMODULE_MOC_SRCS})
  QT4_WRAP_UI(QTMODULE_UI_CXX ${QTMODULE_UI_SRCS})
  if(DEFINED QTMODULE_RESOURCES)
    QT4_ADD_RESOURCES(QTMODULE_QRC_SRCS ${QTMODULE_RESOURCES})
  endif(DEFINED QTMODULE_RESOURCES)

  QT4_ADD_RESOURCES(QTMODULE_QRC_SRCS ${Slicer3_SOURCE_DIR}/Resources/qSlicerLogos.qrc)

  set_source_files_properties(
    ${QTMODULE_UI_CXX}
    ${QTMODULE_SRCS}
    WRAP_EXCLUDE
    )

  source_group("Resources" FILES
    ${QTMODULE_UI_SRCS}
    ${Slicer3_SOURCE_DIR}/Resources/qSlicerLogos.qrc
    ${QTMODULE_RESOURCES}
    )

  source_group("Generated" FILES
    ${QTMODULE_UI_CXX}
    ${QTMODULE_MOC_OUTPUT}
    ${QTMODULE_QRC_SRCS}
    ${dynamicHeaders}
    )

  # --------------------------------------------------------------------------
  # Build the library

  add_library(${lib_name}
    ${QTMODULE_SRCS}
    ${QTMODULE_MOC_OUTPUT}
    ${QTMODULE_UI_CXX}
    ${QTMODULE_QRC_SRCS}
    #${qSlicerModule_TCL_SRCS}
    )

  # Set qt loadable modules output path
  set_target_properties(${lib_name}
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${Slicer3_INSTALL_QTLOADABLEMODULES_BIN_DIR}"
    LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${Slicer3_INSTALL_QTLOADABLEMODULES_LIB_DIR}"
    ARCHIVE_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${Slicer3_INSTALL_QTLOADABLEMODULES_LIB_DIR}"
    )

  target_link_libraries(${lib_name}
    ${Slicer3_Libs_LIBRARIES}
    ${Slicer3_Base_LIBRARIES}
    ${QTMODULE_TARGET_LIBRARIES}
    #${ITK_LIBRARIES}
    )

  # Apply user-defined properties to the library target.
  if(Slicer3_LIBRARY_PROPERTIES)
    set_target_properties(${lib_name} PROPERTIES
      ${Slicer3_LIBRARY_PROPERTIES}
    )
  endif(Slicer3_LIBRARY_PROPERTIES)

  # Install rules
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION ${Slicer3_INSTALL_QTLOADABLEMODULES_BIN_DIR} COMPONENT RuntimeLibraries
    LIBRARY DESTINATION ${Slicer3_INSTALL_QTLOADABLEMODULES_LIB_DIR} COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION ${Slicer3_INSTALL_QTLOADABLEMODULES_LIB_DIR} COMPONENT Development
    )

  # Install headers
  file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
  install(FILES
    ${headers}
    ${dynamicHeaders}
    DESTINATION ${Slicer3_INSTALL_QTLOADABLEMODULES_INCLUDE_DIR}/${QTMODULE_NAME} COMPONENT Development
    )

endmacro(Slicer3_build_qtmodule)
