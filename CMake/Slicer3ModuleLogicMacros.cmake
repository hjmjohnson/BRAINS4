#
# Slicer3_build_module_logic
#

macro(Slicer3_build_module_logic)
  SLICER3_PARSE_ARGUMENTS(MODULELOGIC
    "NAME;EXPORT_DIRECTIVE;SRCS;INCLUDE_DIRECTORIES;TARGET_LIBRARIES"
    ""
    ${ARGN}
    )

  # Sanity checks
  if(NOT DEFINED MODULELOGIC_NAME)
    message(SEND_ERROR "NAME is mandatory")
  endif(NOT DEFINED MODULELOGIC_NAME)

  if(NOT DEFINED MODULELOGIC_EXPORT_DIRECTIVE)
    message(SEND_ERROR "EXPORT_DIRECTIVE is mandatory")
  endif(NOT DEFINED MODULELOGIC_EXPORT_DIRECTIVE)

  # Define library name
  set(lib_name ${MODULELOGIC_NAME})

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
    ${MODULELOGIC_INCLUDE_DIRECTORIES}
    )

  set(MY_LIBRARY_EXPORT_DIRECTIVE ${MODULELOGIC_EXPORT_DIRECTIVE})
  set(MY_EXPORT_HEADER_PREFIX ${MODULELOGIC_NAME})
  set(MY_LIBNAME ${lib_name})

  configure_file(
    ${Slicer3_SOURCE_DIR}/qSlicerExport.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h
    )
  set(dynamicHeaders
    "${dynamicHeaders};${CMAKE_CURRENT_BINARY_DIR}/${MY_EXPORT_HEADER_PREFIX}Export.h")


  # --------------------------------------------------------------------------
  # TCL Wrapping

  set(MODULELOGIC_TCL_SRCS "")
  if(VTK_WRAP_TCL)
    include("${VTK_CMAKE_DIR}/vtkWrapTcl.cmake")
    vtk_wrap_tcl3(${lib_name}
                  MODULELOGIC_TCL_SRCS
                  "${MODULELOGIC_SRCS}" "")
  endif(VTK_WRAP_TCL)

  #-----------------------------------------------------------------------------
  # Source group(s)

  source_group("Generated" FILES
    ${MODULELOGIC_TCL_SRCS}
    ${dynamicHeaders}
    )

  # --------------------------------------------------------------------------
  # Build the library

  add_library(${lib_name}
    ${MODULELOGIC_SRCS}
    ${MODULELOGIC_TCL_SRCS}
    )

  # Set loadable modules output path
  set_target_properties(${lib_name}
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${Slicer3_INSTALL_MODULES_BIN_DIR}"
    LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${Slicer3_INSTALL_MODULES_LIB_DIR}"
    ARCHIVE_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${Slicer3_INSTALL_MODULES_LIB_DIR}"
    )

  # HACK Since we don't depend on qSlicerBaseQT{Base, Core, CLI, CoreModules, GUI},
  # let's remove them from the list
  set(Slicer3_ModuleLogic_Base_LIBRARIES ${Slicer3_Base_LIBRARIES})
  list(REMOVE_ITEM Slicer3_ModuleLogic_Base_LIBRARIES qSlicerBaseQTBase)
  list(REMOVE_ITEM Slicer3_ModuleLogic_Base_LIBRARIES qSlicerBaseQTCore)
  list(REMOVE_ITEM Slicer3_ModuleLogic_Base_LIBRARIES qSlicerBaseQTCLI)
  list(REMOVE_ITEM Slicer3_ModuleLogic_Base_LIBRARIES qSlicerBaseQTCoreModules)
  list(REMOVE_ITEM Slicer3_ModuleLogic_Base_LIBRARIES qSlicerBaseQTGUI)
  # Let's also remove dependency on SlicerBaseGUI
  list(REMOVE_ITEM Slicer3_ModuleLogic_Base_LIBRARIES SlicerBaseGUI)

  target_link_libraries(${lib_name}
    ${Slicer3_Libs_LIBRARIES}
    ${Slicer3_ModuleLogic_Base_LIBRARIES}
    ${MODULELOGIC_TARGET_LIBRARIES}
    )

  # Apply user-defined properties to the library target.
  if(Slicer3_LIBRARY_PROPERTIES)
    set_target_properties(${lib_name} PROPERTIES
      ${Slicer3_LIBRARY_PROPERTIES}
    )
  endif(Slicer3_LIBRARY_PROPERTIES)

  # Install rules
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION ${Slicer3_INSTALL_MODULES_BIN_DIR} COMPONENT RuntimeLibraries
    LIBRARY DESTINATION ${Slicer3_INSTALL_MODULES_LIB_DIR} COMPONENT RuntimeLibraries
    ARCHIVE DESTINATION ${Slicer3_INSTALL_MODULES_LIB_DIR} COMPONENT Development
    )

  # Install headers
  file(GLOB headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
  install(FILES
    ${headers}
    ${dynamicHeaders}
    DESTINATION ${Slicer3_INSTALL_MODULES_INCLUDE_DIR}/${MODULELOGIC_NAME} COMPONENT Development
    )

endmacro(Slicer3_build_module_logic)
