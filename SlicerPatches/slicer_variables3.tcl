
#
# Note: this local vars file overrides sets the default environment for :
#   Scripts/genlib.tcl -- make all the support libs
#   Scripts/cmaker.tcl -- makes slicer code
#   launch.tcl -- sets up the runtime env and starts slicer
#   Scripts/tarup.tcl -- makes a tar.gz files with all the support files
#
# - use this file to set your local environment and then your change won't 
#   be overwritten when those files are updated through CVS
#


## variables that are the same for all systems
set ::Slicer3_DATA_ROOT ""

if {[info exists ::env(Slicer3_HOME)]} {
    # already set by the launcher
    set ::Slicer3_HOME $::env(Slicer3_HOME)
} else {
    # if sourcing this into cmaker, Slicer3_HOME may not be set
    # set the Slicer3_HOME directory to the one in which this script resides
    set cwd [pwd]
    cd [file dirname [info script]]
    set ::Slicer3_HOME [pwd]
    set ::env(Slicer3_HOME) $::Slicer3_HOME
    cd $cwd
}

# set up variables for the OS Builds, to facilitate the move to solaris9
# - solaris can be solaris8 or solaris9
set ::SOLARIS "solaris8"
set ::LINUX "linux-x86"
set ::LINUX_64 "linux-x86_64"
set ::DARWIN "darwin-ppc"
set ::DARWIN_X86 "darwin-x86"
set ::WINDOWS "win32"

#
# set the default locations for the main components
#
switch $::tcl_platform(os) {
    "SunOS" { set ::env(BUILD) $::SOLARIS }
    "Linux" {           
        if {$::tcl_platform(machine) == "x86_64"} {
            set ::env(BUILD) $::LINUX_64 
        } else {
            set ::env(BUILD) $::LINUX
        }
    }       
    "Darwin" { 
        if {$::tcl_platform(machine) == "i386"} {
            set ::env(BUILD) $::DARWIN_X86
        } else {
            set ::env(BUILD) $::DARWIN 
        }
    }
    default { 
        set ::env(BUILD) $::WINDOWS 
        set ::Slicer3_HOME [file attributes $::Slicer3_HOME -shortname]
        set ::env(Slicer3_HOME) $::Slicer3_HOME
    }
}

puts stderr "Platform is $::env(BUILD)"
puts stderr "Slicer3_HOME is $::Slicer3_HOME"

# Choose which library versions you want to compile against.  These
# shouldn't be changed between releases except for testing purposes.
# If you change them and Slicer breaks, you get to keep both pieces.
#
# When modifying these variables, make sure to make appropriate
# changes in the "Files to test if library has already been built"
# section below, or genlib will happily build the library again.

set ::SLICER_TAG "http://svn.slicer.org/Slicer3/branches/Slicer-3-2"
set ::CMAKE_TAG "CMake-2-6-2"
set ::TEEM_TAG http://teem.svn.sourceforge.net/svnroot/teem/teem/trunk
set ::KWWIDGETS_RELEASE "Slicer-3-2"
set ::KWWIDGETS_DATE "20090109"
set ::VTK_RELEASE    "VTK-5-2-1"
set ::ITK_RELEASE "ITK-3-10"
set ::CSWIG_RELEASE "ITK-3-10"
set ::PYTHON_TAG "http://svn.python.org/projects/python/branches/release25-maint"
set ::SLICERLIBCURL_TAG "HEAD"
set ::VTKINRIA3D_DATE "20090114"
set ::VTKINRIA3D_REVISION "1066"
set ::BRAINS_TAG "https://www.psychiatry.uiowa.edu/svn/code/BRAINS/trunk"

set ::USE_SIGN 0
set ::USE_PYTHON 0

# Set library, binary, etc. paths...
#### This information needs to be set prior to sourcing this shell script.
#### These heuristics are not correct in all cases.
#--# # if Slicer3_LIB and Slicer3_BUILD haven't been set,
#--# # then assume they are in the 'standard' places next to the source tree
#--# # (as created by getbuildtest.tcl
#--# if { ![info exists ::Slicer3_LIB] } {
#--#     set wd [pwd]
#--#     cd $::Slicer3_HOME/../Slicer3-lib
#--#     set ::Slicer3_LIB [pwd]
#--#     cd $wd
#--# }
#--# if { ![info exists ::Slicer3_BUILD] } {
#--#     set wd [pwd]
#--#     cd $::Slicer3_HOME/../Slicer3-build
#--#     set ::Slicer3_BUILD [pwd]
#--#     cd $wd
#--# }

set ::CMAKE_SRC_DIR $::Slicer3_LIB/CMake
set ::CMAKE_BUILD_DIR $::Slicer3_LIB/CMake-build
set ::TEEM_SRC_DIR  $::Slicer3_LIB/teem
set ::TEEM_BUILD_DIR  $::Slicer3_LIB/teem-build
set ::VTK_DIR  $::Slicer3_LIB/VTK-build
set ::VTK_SRC_DIR $::Slicer3_LIB/VTK
if { ![info exists ::VTK_BUILD_TYPE] } {
  # set a default if it hasn't already been specified
  set ::VTK_BUILD_TYPE "Debug" ;# options: Release, RelWithDebInfo, Debug
}
set ::VTK_BUILD_SUBDIR $::VTK_BUILD_TYPE 
set ::env(VTK_BUILD_TYPE) $::VTK_BUILD_TYPE
set ::KWWidgets_BUILD_DIR  $::Slicer3_LIB/KWWidgets-build
set ::KWWIDGETS_DIR  $::Slicer3_LIB/KWWidgets
set ::ITK_BINARY_PATH $::Slicer3_LIB/Insight-build
set ::TCL_BIN_DIR $::Slicer3_LIB/tcl-build/bin
set ::TCL_LIB_DIR $::Slicer3_LIB/tcl-build/lib
set ::TCL_INCLUDE_DIR $::Slicer3_LIB/tcl-build/include
set ::PYTHON_BIN_DIR $::Slicer3_LIB/python-build
set ::CMAKE_PATH $::Slicer3_LIB/CMake-build
set ::SOV_BINARY_DIR ""
set ::XVNC_EXECUTABLE " "
set ::IGSTK_DIR $::Slicer3_LIB/IGSTK-build 
set ::SLICERLIBCURL_SRC_DIR $::Slicer3_LIB/cmcurl
set ::SLICERLIBCURL_BUILD_DIR $::Slicer3_LIB/cmcurl-build
set ::vtkinria3d_BUILD_DIR $::Slicer3_LIB/vtkinria3d-build

# Options for building IGT modules in Slicer
set ::IGSTK "OFF"
set ::NAVITRACK "OFF"

# The absolute path and directory containing the navitrack library,
# for instance on linux the libNaviTrack.so
# set ::NAVITRACK_LIB_DIR /home/hliu/projects/navitrack/NaviTrack-build
set ::NAVITRACK_LIB_DIR "" 

# The navitrack include directry, e.g.
# /home/hliu/projects/navitrack/NaviTrack/include
# set ::NAVITRACK_INC_DIR /home/hliu/projects/navitrack/NaviTrack/include
set ::NAVITRACK_INC_DIR "" 

switch $::tcl_platform(os) {
    "SunOS" -
    "Linux" {
        set shared_lib_ext "so"
    }
    "Darwin" {
        set shared_lib_ext "dylib"
    }
    "Windows NT" {
        set shared_lib_ext "dll"
    }
}

# TODO: identify files for each platform

switch $::tcl_platform(os) {
    "SunOS" -
    "Darwin" {
        set ::VTK_BUILD_SUBDIR ""
        set ::TEEM_BIN_DIR  $::TEEM_BUILD_DIR/bin

        set ::TCL_TEST_FILE $::TCL_BIN_DIR/tclsh8.4
        set ::TK_TEST_FILE  $::TCL_BIN_DIR/wish8.4
        set ::INCR_TCL_LIB $::TCL_LIB_DIR/lib/libitcl3.2.dylib
        set ::INCR_TK_LIB $::TCL_LIB_DIR/lib/libitk3.2.dylib
        set ::PYTHON_TEST_FILE $::PYTHON_BIN_DIR/bin/python
        set ::PYTHON_LIB $::PYTHON_BIN_DIR/lib/libpython2.5.dylib
        set ::PYTHON_INCLUDE $::PYTHON_BIN_DIR/include/python2.5
        set ::ITCL_TEST_FILE $::TCL_LIB_DIR/libitcl3.2.dylib
        set ::IWIDGETS_TEST_FILE $::TCL_LIB_DIR/iwidgets4.0.1/iwidgets.tcl
        set ::BLT_TEST_FILE $::TCL_BIN_DIR/bltwish24
        set ::TEEM_TEST_FILE $::TEEM_BIN_DIR/unu
        set ::VTK_TEST_FILE $::VTK_DIR/bin/vtk
        set ::KWWidgets_TEST_FILE $::KWWidgets_BUILD_DIR/bin/libKWWidgets.$shared_lib_ext
        set ::VTK_TCL_LIB $::TCL_LIB_DIR/libtcl8.4.$shared_lib_ext 
        set ::VTK_TK_LIB $::TCL_LIB_DIR/libtk8.4.$shared_lib_ext
        set ::VTK_TCLSH $::TCL_BIN_DIR/tclsh8.4
        set ::ITK_TEST_FILE $::ITK_BINARY_PATH/bin/libITKCommon.$shared_lib_ext
        set ::TK_EVENT_PATCH $::Slicer3_HOME/tkEventPatch.diff
        set ::env(VTK_BUILD_SUBDIR) $::VTK_BUILD_SUBDIR
        set ::IGSTK_TEST_FILE $::IGSTK_DIR/bin/libIGSTK.$shared_lib_ext
        set ::SLICERLIBCURL_TEST_FILE $::SLICERLIBCURL_BUILD_DIR/bin/libslicerlibcurl.a
        set ::vtkinria3d_TEST_FILE $::vtkinria3d_BUILD_DIR/lib/libitkAddOn.dylib
        set ::SLICER_TEST_FILE $::Slicer3_BUILD/bin/Slicer3
    }
    "Linux" {
        set ::VTK_BUILD_SUBDIR ""
        set ::TEEM_BIN_DIR  $::TEEM_BUILD_DIR/bin

        set ::CMAKE_TEST_FILE  $::CMAKE_BUILD_DIR/bin/cmake
        set ::TCL_TEST_FILE $::TCL_BIN_DIR/tclsh8.4
        set ::INCR_TCL_LIB $::TCL_LIB_DIR/lib/libitcl3.2.so
        set ::INCR_TK_LIB $::TCL_LIB_DIR/lib/libitk3.2.so
        set ::IWIDGETS_TEST_FILE $::TCL_LIB_DIR/iwidgets4.0.1/iwidgets.tcl
        set ::BLT_TEST_FILE $::TCL_BIN_DIR/bltwish24
        set ::PYTHON_TEST_FILE $::PYTHON_BIN_DIR/bin/python
        set ::PYTHON_LIB $::PYTHON_BIN_DIR/lib/libpython2.5.so
        set ::PYTHON_INCLUDE $::PYTHON_BIN_DIR/include/python2.5
        set ::TK_TEST_FILE  $::TCL_BIN_DIR/wish8.4
        set ::ITCL_TEST_FILE $::TCL_LIB_DIR/libitcl3.2.so
        set ::TEEM_TEST_FILE $::TEEM_BIN_DIR/unu
        set ::VTK_TEST_FILE $::VTK_DIR/bin/vtk
        set ::KWWidgets_TEST_FILE $::KWWidgets_BUILD_DIR/bin/libKWWidgets.so
        set ::VTK_TCL_LIB $::TCL_LIB_DIR/libtcl8.4.$shared_lib_ext 
        set ::VTK_TK_LIB $::TCL_LIB_DIR/libtk8.4.$shared_lib_ext
        set ::VTK_TCLSH $::TCL_BIN_DIR/tclsh8.4
        set ::ITK_TEST_FILE $::ITK_BINARY_PATH/bin/libITKCommon.$shared_lib_ext
        set ::TK_EVENT_PATCH $::Slicer3_HOME/tkEventPatch.diff
        set ::env(VTK_BUILD_SUBDIR) $::VTK_BUILD_SUBDIR
        set ::IGSTK_TEST_FILE $::IGSTK_DIR/bin/libIGSTK.$shared_lib_ext
        set ::SLICERLIBCURL_TEST_FILE $::SLICERLIBCURL_BUILD_DIR/bin/libslicerlibcurl.a
        set ::vtkinria3d_TEST_FILE $::vtkinria3d_BUILD_DIR/lib/libitkAddOn.so
        set ::SLICER_TEST_FILE $::Slicer3_BUILD/bin/Slicer3

    }
    "Windows NT" {
    # Windows NT currently covers WinNT, Win2000, XP Home, XP Pro

        set ::VTK_BUILD_SUBDIR $::VTK_BUILD_TYPE
        set ::TEEM_BIN_DIR  $::TEEM_BUILD_DIR/bin/$::VTK_BUILD_TYPE

        set ::env(VTK_BUILD_SUBDIR) $::VTK_BUILD_SUBDIR
        set ::TCL_TEST_FILE $::TCL_BIN_DIR/tclsh84.exe
        set ::TK_TEST_FILE  $::TCL_BIN_DIR/wish84.exe
        set ::ITCL_TEST_FILE $::TCL_LIB_DIR/itclConfig.sh
        set ::INCR_TCL_LIB $::TCL_LIB_DIR/lib/itcl3.2/itcl32.lib
        set ::INCR_TK_LIB $::TCL_LIB_DIR/lib/itk3.2/itk32.lib
        set ::IWIDGETS_TEST_FILE $::TCL_LIB_DIR/iwidgets4.0.2/iwidgets.tcl
        set ::BLT_TEST_FILE $::TCL_BIN_DIR/BLT24.dll
        set ::TEEM_TEST_FILE $::TEEM_BIN_DIR/unu.exe
        set ::PYTHON_TEST_FILE $::PYTHON_BIN_DIR/bin/python.exe
        set ::PYTHON_LIB $::PYTHON_BIN_DIR/Libs/python25.lib
        set ::PYTHON_INCLUDE $::PYTHON_BIN_DIR/include
        set ::VTK_TEST_FILE $::VTK_DIR/bin/$::VTK_BUILD_TYPE/vtk.exe
        set ::KWWidgets_TEST_FILE $::KWWidgets_BUILD_DIR/bin/$::env(VTK_BUILD_SUBDIR)/KWWidgets.lib
        set ::VTK_TCL_LIB $::TCL_LIB_DIR/tcl84.lib
        set ::VTK_TK_LIB $::TCL_LIB_DIR/tk84.lib
        set ::VTK_TCLSH $::TCL_BIN_DIR/tclsh84.exe
        set ::ITK_TEST_FILE $::ITK_BINARY_PATH/bin/$::VTK_BUILD_TYPE/ITKCommon.dll
        set ::IGSTK_TEST_FILE $::IGSTK_DIR/bin/$::VTK_BUILD_TYPE/IGSTK.lib
        set ::SLICERLIBCURL_TEST_FILE $::SLICERLIBCURL_BUILD_DIR/bin/$::VTK_BUILD_TYPE/slicerlibcurl.lib
        set ::vtkinria3d_TEST_FILE $::vtkinria3d_BUILD_DIR/lib/itkAddOn.lib
        set ::SLICER_TEST_FILE $::Slicer3_BUILD/bin/$::VTK_BUILD_TYPE/Slicer3
    }
    default {
        puts stderr "Could not match platform \"$::tcl_platform(os)\"."
        exit
    }
}

# System dependent variables
## Initialize them
    set ::CMAKE_SHARED_LINKER_FLAGS ""
    set ::CMAKE_MODULE_LINKER_FLAGS ""
    set ::CMAKE_EXE_LINKER_FLAGS ""


switch $::tcl_platform(os) {
    "SunOS" {
        set ::VTKSLICERBASE_BUILD_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/vtkSlicerBase.so
        set ::VTKSLICERBASE_BUILD_TCL_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/vtkSlicerBaseTCL.so
        set ::GENERATOR "Unix Makefiles"
        set ::COMPILER_PATH "/local/os/bin"
        set ::C_COMPILER "gcc"
        set ::COMPILER "g++"
        set ::CMAKE $::CMAKE_PATH/bin/cmake
        set ::MAKE "gmake"
        set ::SERIAL_MAKE "gmake"

        switch $env(Slicer3_BUILD_TYPE) {
        "DEBUG" {
              set ::CC "$COMPILER_PATH/$C_COMPILER"
              set ::CXX "$COMPILER_PATH/$COMPILER"
              set ::CFLAGS   "-UNDEBUG -g -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -g -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
    set ::OPENGL_INCLUDE_DIR "/usr/include"
    set ::OPENGL_gl_LIBRARY "/usr/lib/libGL.$shared_lib_ext"
    set ::OPENGL_glu_LIBRARY "/usr/lib/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              ##  Some of the iwidgets, itcl, itk does not compile with these flags due to poor build tools used.
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
           }
        "DUMMY" {
        }
        default {
          puts "ERROR Invalid abi."
          exit -1;
        }
        }
    }
    "Linux" {
        set ::VTKSLICERBASE_BUILD_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/vtkSlicerBase.so
        set ::VTKSLICERBASE_BUILD_TCL_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/vtkSlicerBaseTCL.so
        set ::GENERATOR "Unix Makefiles" 
        set ::CMAKE $::CMAKE_PATH/bin/cmake
        set numCPUs [lindex [exec grep processor /proc/cpuinfo | wc] 0]
        set ::MAKE "make -j [expr $numCPUs * 2]"
        set ::SERIAL_MAKE "make"

        switch $env(Slicer3_BUILD_TYPE) {
        "DEBUG" {
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc4"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++4"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-UNDEBUG -g -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -g -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY "/usr/lib/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              ##  Some of the iwidgets, itcl, itk does not compile with these flags due to poor build tools used.
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        "PROFILE_64" {
              # NOTE:  on RHEL4 gcov supports only the 3.4 compiler properly.
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-UNDEBUG -fprofile-arcs -ftest-coverage -pg -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -fprofile-arcs -ftest-coverage -pg -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY  "/usr/lib64/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib64/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              ##  Some of the iwidgets, itcl, itk does not compile with these flags due to poor build tools used.
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        "PROFILE" {
              # NOTE:  on RHEL4 gcov supports only the 3.4 compiler properly.
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-UNDEBUG -fprofile-arcs -ftest-coverage -pg -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -fprofile-arcs -ftest-coverage -pg -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY "/usr/lib/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              ##  Some of the iwidgets, itcl, itk does not compile with these flags due to poor build tools used.
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
              ## Should be found be default with proper compiler flags ::env(LDFLAGS) "-lgcov"
          }
        "FAST" {
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc4"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++4"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-DNDEBUG -O2 -msse -mmmx -msse2 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-DNDEBUG -O2 -msse -mmmx -msse2 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY  "/usr/lib64/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib64/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        "FAST_64" {
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc4"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++4"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-DNDEBUG -O2 -msse -mmmx -msse2 -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-DNDEBUG -O2 -msse -mmmx -msse2 -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY  "/usr/lib64/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib64/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        "FASTO3_64" {
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc4"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++4"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-DNDEBUG -O3 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-DNDEBUG -O3 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY  "/usr/lib64/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib64/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        "DEBUG_64" {
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc4"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++4"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$C_COMPILER"
              set ::CXX "$COMPILER"
              set ::CFLAGS   "-UNDEBUG -g -Wall -msse -mmmx -msse2 -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -g -Wall -msse -mmmx -msse2 -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY  "/usr/lib64/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib64/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        "DEBUG2_64" {
              if { [info exists env(CC)] } {
                set ::C_COMPILER $env(CC)
              } else {
                set ::C_COMPILER "gcc4"
              }
              if { [info exists env(CXX)] } {
                set ::COMPILER $env(CXX)
              } else {
                set ::COMPILER "g++4"
              }
              set ::COMPILER_PATH "/usr/bin"
              set ::CC "$COMPILER_PATH/$C_COMPILER"
              set ::CXX "$COMPILER_PATH/$COMPILER"
              set ::CFLAGS   "-UNDEBUG -g -Wall -msse -mmmx -msse2 -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -g -Wall -msse -mmmx -msse2 -m64 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS "--suppressions=$::Slicer3_HOME/../brains3/ValgrindSuppression.supp --verbose --leak-check=full --leak-resolution=high --show-reachable=yes"
              set ::OPENGL_INCLUDE_DIR "/usr/include"
              set ::OPENGL_gl_LIBRARY  "/usr/lib64/libGL.$shared_lib_ext"
              set ::OPENGL_glu_LIBRARY "/usr/lib64/libGLU.$shared_lib_ext"
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
          }
        default {
          puts "ERROR Invalid abi."
          exit -1;
        }
        }
    }
    "Darwin" {
        set ::VTKSLICERBASE_BUILD_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/vtkSlicerBase.dylib
        set ::VTKSLICERBASE_BUILD_TCL_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/vtkSlicerBaseTCL.dylib
        set ::GENERATOR "Unix Makefiles" 
        set ::COMPILER_PATH "/usr/bin"
        set ::C_COMPILER "gcc"
        set ::COMPILER "g++"
        set ::CMAKE $::CMAKE_PATH/bin/cmake
        set numCPUs [exec /usr/sbin/sysctl -n hw.ncpu ]
        set ::MAKE "make -j [expr $numCPUs * 2]"
        set ::SERIAL_MAKE "make"

        set OSX_VERSION  [ lindex [ split [exec uname -r ] "." ] 0 ]
        switch $OSX_VERSION {
          "8" {
            set ::env(LDFLAGS) ""
          }
          "9" {
            ## OPEN GL under Leopard requires this link line in order to resolve the GL libraries correctly.
            ## set ::env(LDFLAGS) "-Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib"
            set ::CMAKE_SHARED_LINKER_FLAGS "-Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib"
            set ::CMAKE_MODULE_LINKER_FLAGS "-Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib"
            set ::CMAKE_EXE_LINKER_FLAGS "-Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib"
          }
        }
        set ::OPENGL_INCLUDE_DIR "/usr/X11R6/include"
        set ::OPENGL_gl_LIBRARY  "-framework OpenGL;/usr/X11R6/lib/libGL.dylib"
        set ::OPENGL_glu_LIBRARY "-framework OpenGL;/usr/X11R6/lib/libGLU.dylib"
        switch $env(Slicer3_BUILD_TYPE) {
        "DEBUG" {
              set ::CC "$COMPILER_PATH/$C_COMPILER"
              set ::CXX "$COMPILER_PATH/$COMPILER"
              set ::CFLAGS   "-UNDEBUG -g -Wall -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-UNDEBUG -g -Wall -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS ""
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              ##  Some of the iwidgets, itcl, itk does not compile with these flags due to poor build tools used.
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
        }
        "FAST" {
              set ::CC "$COMPILER_PATH/$C_COMPILER"
              set ::CXX "$COMPILER_PATH/$COMPILER"
              set ::CFLAGS   "-DNDEBUG -O2 -msse -mmmx -msse2 -msse3 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::CXXFLAGS "-DNDEBUG -O2 -msse -mmmx -msse2 -msse3 -UITKIO_DEPRECATED_METADATA_ORIENTATION"
              set ::VALGRIND_COMMANDS_FLAGS ""
              set ::env(CC) $::CC
              set ::env(CXX) $::CXX
              ##  Some of the iwidgets, itcl, itk does not compile with these flags due to poor build tools used.
              set ::env(CFLAGS) $::CFLAGS
              set ::env(CXXFLAGS) $::CXXFLAGS
        }
        default {
          puts "ERROR Invalid abi."
          exit -1;
        }
        }
    }
    default {
        # different windows machines say different things, so assume
        # that if it doesn't match above it must be windows
        # (VC7 is Visual C++ 7.0, also known as the .NET version)


        set ::VTKSLICERBASE_BUILD_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/$::VTK_BUILD_TYPE/vtkSlicerBase.lib
        set ::VTKSLICERBASE_BUILD_TCL_LIB $::Slicer3_HOME/Base/builds/$::env(BUILD)/bin/$::VTK_BUILD_TYPE/vtkSlicerBaseTCL.lib

        set ::CMAKE $::CMAKE_PATH/bin/cmake.exe

        set MSVC6 0
        #
        ## match this to the version of the compiler you have:
        #
        
        ## for Visual Studio 6:
        #set ::GENERATOR "Visual Studio 6" 
        #set ::MAKE "msdev"
        #set ::COMPILER_PATH ""
        #set MSVC6 1

        if {[info exists ::env(MSVC6)]} {
            set ::MSVC6 $::env(MSVC6)
        } else {
        }

        ## for Visual Studio 7:
        if {[info exists ::env(GENERATOR)]} {
            set ::GENERATOR $::env(GENERATOR)
        } else {
            set ::GENERATOR "Visual Studio 7" 
        }

        if {[info exists ::env(MAKE)]} {
            set ::MAKE $::env(MAKE)
        } else {
            set ::MAKE "c:/Program\ Files/Microsoft\ Visual\ Studio\ .NET/Common7/IDE/devenv"
        }

        if {[info exists ::env(COMPILER_PATH)]} {
            set ::COMPILER_PATH $::env(COMPILER_PATH)
        } else {
            set ::COMPILER_PATH "c:/Program\ Files/Microsoft\ Visual\ Studio\ .NET/Common7/Vc7/bin"
        }

        #
        ## for Visual Studio 7.1:
        # - automatically use newer if available
        #
        if { [file exists "c:/Program Files/Microsoft Visual Studio .NET 2003/Common7/IDE/devenv.exe"] } {
            set ::GENERATOR "Visual Studio 7 .NET 2003" 
            set ::MAKE "c:/Program\ Files/Microsoft\ Visual\ Studio\ .NET 2003/Common7/IDE/devenv"
            set ::COMPILER_PATH "c:/Program\ Files/Microsoft\ Visual\ Studio\ .NET 2003/Vc7/bin"
        }

        #
        ## for Visual Studio 8
        # - automatically use newest if available
        # - use full if available, otherwise express
        # - use the 64 bit version if available
        #
        if { [file exists "c:/Program Files/Microsoft Visual Studio 8/Common7/IDE/VCExpress.exe"] } {
            set ::GENERATOR "Visual Studio 8 2005" 
            set ::MAKE "c:/Program Files/Microsoft Visual Studio 8/Common7/IDE/VCExpress.exe"
            set ::COMPILER_PATH "c:/Program Files/Microsoft Visual Studio 8/VC/bin"
        }


        if { [file exists "c:/Program Files/Microsoft Visual Studio 8/Common7/IDE/devenv.exe"] } {
            set ::GENERATOR "Visual Studio 8 2005" 
            set ::MAKE "c:/Program Files/Microsoft Visual Studio 8/Common7/IDE/devenv.exe"
            set ::COMPILER_PATH "c:/Program Files/Microsoft Visual Studio 8/VC/bin"
        }

        if { [file exists "c:/Program Files (x86)/Microsoft Visual Studio 8/Common7/IDE/devenv.exe"] } {
            #set ::GENERATOR "Visual Studio 8 2005 Win64"
            set ::GENERATOR "Visual Studio 8 2005"   ;# do NOT use the 64 bit target
            set ::MAKE "c:/Program Files (x86)/Microsoft Visual Studio 8/Common7/IDE/devenv.exe"
            set ::COMPILER_PATH "c:/Program Files (x86)/Microsoft Visual Studio 8/VC/bin"
        }
        #
        ## for Visual Studio 9
        if { [file exists "c:/Program Files/Microsoft Visual Studio 9.0/Common7/IDE/VCExpress.exe"] } {
            set ::GENERATOR "Visual Studio 9 2008" 
            set ::MAKE "c:/Program Files/Microsoft Visual Studio 9.0/Common7/IDE/VCExpress.exe"
            set ::COMPILER_PATH "c:/Program Files/Microsoft Visual Studio 9.0/VC/bin"
        
        }

        set ::COMPILER "cl"
        set ::SERIAL_MAKE $::MAKE
    }
}

switch -regexp $::tcl_platform(os) {
  Windows* { 
     puts "In Win32"
     set ::CMAKE_COMPILE_SETTINGS [list "-G$GENERATOR" ]
     set ::OPENGL_COMPILE_SETTINGS ""
  }
  default {
  puts "In default: $::tcl_platform(os)"
     set ::CMAKE_COMPILE_SETTINGS [list "-G$GENERATOR" "-DCMAKE_CXX_COMPILER:FILEPATH=$::CXX" "-DCMAKE_CXX_FLAGS:STRING=$::CXXFLAGS" "-DCMAKE_CXX_FLAGS_RELEASE:STRING=$::CXXFLAGS" "-DCMAKE_CXX_FLAGS_DEBUG:STRING=$::CXXFLAGS" "-DCMAKE_C_COMPILER:FILEPATH=$::CC" "-DCMAKE_C_FLAGS:STRING=$::CFLAGS" "-DDART_TESTING_TIMEOUT:STRING=6500" "-DMEMORYCHECK_COMMAND_OPTIONS:STRING=$::VALGRIND_COMMANDS_FLAGS" "-DCMAKE_SHARED_LINKER_FLAGS=$::CMAKE_SHARED_LINKER_FLAGS" "-DCMAKE_EXE_LINKER_FLAGS=$::CMAKE_EXE_LINKER_FLAGS" "-DCMAKE_MODULE_LINKER_FLAGS=$::CMAKE_MODULE_LINKER_FLAGS" ]
     set ::OPENGL_COMPILE_SETTINGS [ list "-DOPENGL_gl_LIBRARY:FILEPATH=$::OPENGL_gl_LIBRARY" "-DOPENGL_glu_LIBRARY:FILEPATH=$::OPENGL_glu_LIBRARY"  "-DOPENGL_INCLUDE_DIR:PATH=$::OPENGL_INCLUDE_DIR" ]
  }
}

puts $::CMAKE_COMPILE_SETTINGS
puts $::OPENGL_COMPILE_SETTINGS

