
macro(SHARED_FORWARD_WRAPPER ProgramBaseName )
    set(BRAINS_SHARED_FORWARD_DIR_BUILD "\"${BRAINS_BINARY_DIR}\"")
    set(BRAINS_SHARED_FORWARD_PATH_BUILD "\"../lib\",\"${VTK_DIR}/bin\",\"${KWWidgets_RUNTIME_DIRS}\",\"${ITK_DIR}/bin\",\"${TCL_DIR}/bin\",\"${OPENGL_gl_LIBRARY_PATH}\"")
    set(BRAINS_SHARED_FORWARD_PATH_INSTALL "\"../lib\", \"../lib/vtk-${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}\",\"../lib/KWWidgets\",\"../lib/InsightToolkit\"")
set(BRAINS_SHARED_FORWARD_EXE_BUILD "\"${ProgramBaseName}-real\"")
set(BRAINS_SHARED_FORWARD_EXE_INSTALL "\"${ProgramBaseName}-real\"")

configure_file(${BRAINS_Complete_SOURCE_DIR}/CMake/ForwardPathProgram.c.in
        ${CMAKE_CURRENT_BINARY_DIR}/${ProgramBaseName}Launcher.c @ONLY IMMEDIATE)

add_executable(${ProgramBaseName}
	${CMAKE_CURRENT_BINARY_DIR}/${ProgramBaseName}Launcher.c)
endmacro(SHARED_FORWARD_WRAPPER)

