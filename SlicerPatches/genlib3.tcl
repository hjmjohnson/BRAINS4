#!/bin/bash
# the next line restarts using tclsh \
    exec tclsh "$0" "$@"

################################################################################
#
# genlib.tcl
#
# generate the Lib directory with the needed components for slicer
# to build
#
# Steps:
# - pull code from anonymous cvs
# - configure (or cmake) with needed options
# - build for this platform
#
# Packages: cmake, tcl, itcl, iwidgets, blt, ITK, VTK, teem
# 
# Usage:
#   genlib [options] [target]
#
# run genlib from the Slicer3 directory next to where you want the packages to be built
# E.g. if you run /home/pieper/Slicer3/Scripts/genlib.tcl it will create
# /home/pieper/Slicer3-lib
#
# - sp - 2004-06-20
#


if {[info exists ::env(CVS)]} {
    set ::CVS "{$::env(CVS)}"
} else {
    set ::CVS cvs
}

# for subversion repositories (Sandbox)
if {[info exists ::env(SVN)]} {
    set ::SVN $::env(SVN)
} else {
    set ::SVN svn
}

################################################################################
#
# check to see if need to build a package
# returns 1 if need to build, 0 else
# if { [BuildThis  ""] == 1 } {
proc BuildThis { testFile packageName } {
    if {![file exists $testFile] || $::GENLIB(update) || [lsearch $::GENLIB(buildList) $packageName] != -1} {
        # puts "Building $packageName (testFile = $testFile, update = $::GENLIB(update), buildlist = $::GENLIB(buildList) )"
        return 1
    } else {
        # puts "Skipping $packageName"
        return 0
    }
}
#

################################################################################
#
# simple command line argument parsing
#

proc Usage { {msg ""} } {
    global SLICER
    
    set msg "$msg\nusage: genlib \[options\] \[target\]"
    set msg "$msg\n  \[target\] is the the Slicer3_LIB directory"
    set msg "$msg\n             and is determined automatically if not specified"
    set msg "$msg\n  \[options\] is one of the following:"
    set msg "$msg\n   --help : prints this message and exits"
    set msg "$msg\n   --clean : delete the target first"
    set msg "$msg\n   --update : do a cvs update even if there's an existing build"
    set msg "$msg\n   --release : compile with optimization flags"
    set msg "$msg\n   --nobuild : only download and/or update, but don't build"
    set msg "$msg\n   optional space separated list of packages to build (lower case)"
    puts stderr $msg
}

set GENLIB(clean) "false"
set GENLIB(update) "false"
set GENLIB(buildit) "true"
set ::GENLIB(buildList) ""

set isRelease 0
set strippedargs ""
set argc [llength $argv]
for {set i 0} {$i < $argc} {incr i} {
    set a [lindex $argv $i]
    switch -glob -- $a {
        "--clean" -
        "-f" {
            set GENLIB(clean) "true"
        }
        "--update" -
        "-u" {
            set GENLIB(update) "true"
        }
        "--release" {
            set isRelease 1
            set ::VTK_BUILD_TYPE "Release"
        }
        "--nobuild" {
            set ::GENLIB(buildit) "false"
        }
        "--help" -
        "-h" {
            Usage
            exit 1
        }
        "-*" {
            Usage "unknown option $a\n"
            exit 1
        }
        default {
            lappend strippedargs $a 
        }
    }
}
set argv $strippedargs
set argc [llength $argv]
puts "Stripped args = $argv"

set ::Slicer3_LIB ""
if {$argc > 2 } {
    Usage
    exit 1
    # the stripped args list now has the Slicer3_LIB first and then the list of packages to build
    set ::GENLIB(buildList) [lrange $strippedargs 1 end]
    set strippedargs [lindex $strippedargs 0]
# puts "Got the list of package to build: '$::GENLIB(buildList)' , stripped args = $strippedargs"
} 
set ::Slicer3_LIB [lindex $argv 0]
set ::Slicer3_BUILD [lindex $argv 1]



################################################################################
#
# Utilities:

proc runcmd {args} {
    global isWindows
    puts "running: $args"

    # print the results line by line to provide feedback during long builds
    # interleaves the results of stdout and stderr, except on Windows
    if { $isWindows } {
        # Windows does not provide native support for cat
        set fp [open "| $args" "r"]
    } else {
        set fp [open "| $args |& cat" "r"]
    }
    while { ![eof $fp] } {
        gets $fp line
        puts $line
    }
    set ret [catch "close $fp" res] 
    if { $ret } {
        puts stderr $res
        if { $isWindows } {
            # Does not work on Windows
        } else {
            error $ret
        }
    } 
}


################################################################################
# First, set up the directory
# - determine the location
# - determine the build
# 

# hack to work around lack of normalize option in older tcl
# set Slicer3_HOME [file dirname [file dirname [file normalize [info script]]]]
set cwd [pwd]
cd [file dirname [info script]]
cd ..
set Slicer3_HOME [pwd]
cd $cwd

#######
#
# Note: the local vars file, slicer2/slicer_variables3.tcl, overrides the default values in this script
# - use it to set your local environment and then your change won't
#   be overwritten when this file is updated
#
set localvarsfile $Slicer3_HOME/slicer_variables3.tcl
catch {set localvarsfile [file normalize $localvarsfile]}
if { [file exists $localvarsfile] } {
    puts "Sourcing $localvarsfile"
    source $localvarsfile
} else {
    puts "stderr: $localvarsfile not found - use this file to set up your build"
    exit 1
}

#initialize platform variables
switch $tcl_platform(os) {
    "SunOS" {
        set isSolaris 1
        set isWindows 0
        set isDarwin 0
        set isLinux 0
    }
    "Linux" { 
        set isSolaris 0
        set isWindows 0
        set isDarwin 0
        set isLinux 1
    }
    "Darwin" { 
        set isSolaris 0
        set isWindows 0
        set isDarwin 1
        set isLinux 0
    }
    default { 
        set isSolaris 0
        set isWindows 1
        set isDarwin 0
        set isLinux 0
    }
}

set ::VTK_DEBUG_LEAKS "ON"
if ($isRelease) {
    set ::VTK_BUILD_TYPE "Release"
    set ::env(VTK_BUILD_TYPE) $::VTK_BUILD_TYPE
    if ($isWindows) {
        set ::VTK_BUILD_SUBDIR "Release"
    } else {
        set ::VTK_BUILD_SUBDIR ""
    }
    puts "Overriding slicer_variables.tcl; VTK_BUILD_TYPE is '$::env(VTK_BUILD_TYPE)', VTK_BUILD_SUBDIR is '$::VTK_BUILD_SUBDIR'"
    set ::VTK_DEBUG_LEAKS "OFF"

}

# tcl file delete is broken on Darwin, so use rm -rf instead
if { $GENLIB(clean) } {
    puts "Deleting slicer lib files..."
    if { $isDarwin } {
        runcmd rm -rf $Slicer3_LIB
        if { [file exists $Slicer3_LIB/tcl/isPatched] } {
            runcmd rm $Slicer3_LIB/tcl/isPatched
        }

    } else {
        file delete -force $Slicer3_LIB
    }
}

if { ![file exists $Slicer3_LIB] } {
    file mkdir $Slicer3_LIB
}


################################################################################
# If is Darwin, don't use cvs compression to get around bug in cvs 1.12.13
#

if {$isDarwin} {
    set CVS_CO_FLAGS "-q"  
} else {
    set CVS_CO_FLAGS "-q -z3"    
}


################################################################################
# Get and build CMake
#

# set in slicer_vars
if { [BuildThis $::CMAKE "cmake"] == 1 } {
    file mkdir $::CMAKE_PATH
    cd $Slicer3_LIB


    if {$isWindows} {
      runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/Binaries/Windows/CMake-build CMake-build
    } else {
        runcmd $::CVS -d :pserver:anonymous:cmake@www.cmake.org:/cvsroot/CMake login
        eval "runcmd $::CVS $CVS_CO_FLAGS -d :pserver:anonymous@www.cmake.org:/cvsroot/CMake checkout -r $::CMAKE_TAG CMake"

        if {$::GENLIB(buildit)} {
          cd $::CMAKE_PATH
          if { $isSolaris } {
              # make sure to pick up curses.h in /local/os/include
              runcmd $Slicer3_LIB/CMake/bootstrap --init=$Slicer3_HOME/Scripts/spl.cmake.init
          } else {
              runcmd $Slicer3_LIB/CMake/bootstrap
          } 
          eval runcmd $::MAKE
       }
    }
}


################################################################################
# Get and build tcl, tk, itcl, widgets
#
#

# on windows, tcl won't build right, as can't configure, so save commands have to run
if { [BuildThis $::TCL_TEST_FILE "tcl"] == 1 } {

    if {$isWindows} {
      runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/Binaries/Windows/tcl-build tcl-build
    }

    file mkdir $Slicer3_LIB/tcl
    cd $Slicer3_LIB/tcl

    runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/tcl/tcl tcl
    if {$::GENLIB(buildit)} {
      if {$isWindows} {
          # can't do windows
      } else {
          cd $Slicer3_LIB/tcl/tcl/unix

          runcmd ./configure --prefix=$Slicer3_LIB/tcl-build
          eval runcmd $::MAKE
          eval runcmd $::MAKE install
      }
    }
}

if { [BuildThis $::TK_TEST_FILE "tk"] == 1 } {
    cd $Slicer3_LIB/tcl

    runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/tcl/tk tk

    if {$::GENLIB(buildit)} {
      if {$isWindows} {
         # ignore, already downloaded with tcl
      } else {
         cd $Slicer3_LIB/tcl/tk/unix
         if { $isDarwin } {
                  runcmd ./configure --with-tcl=$Slicer3_LIB/tcl-build/lib --prefix=$Slicer3_LIB/tcl-build --disable-corefoundation --x-libraries=/usr/X11R6/lib --x-includes=/usr/X11R6/include --with-x
               } else {
                  runcmd ./configure --with-tcl=$Slicer3_LIB/tcl-build/lib --prefix=$Slicer3_LIB/tcl-build
               }
         eval runcmd $::MAKE
         eval runcmd $::MAKE install
         
         file copy -force $Slicer3_LIB/tcl/tk/generic/default.h $Slicer3_LIB/tcl-build/include
         file copy -force $Slicer3_LIB/tcl/tk/unix/tkUnixDefault.h $Slicer3_LIB/tcl-build/include
      }
   }
}


if { [BuildThis $::ITCL_TEST_FILE "itcl"] == 1 } {

    cd $Slicer3_LIB/tcl

    runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/tcl/incrTcl incrTcl

    cd $Slicer3_LIB/tcl/incrTcl

    exec chmod +x ../incrTcl/configure 
    if {$::GENLIB(buildit)} {
      if {$isWindows} {
         # ignore, already downloaded with tcl
      } else {
        if { $isDarwin } {
          exec cp ../incrTcl/itcl/configure ../incrTcl/itcl/configure.orig
          exec sed -e "s/\\*\\.c | \\*\\.o | \\*\\.obj) ;;/\\*\\.c | \\*\\.o | \\*\\.obj | \\*\\.dSYM | \\*\\.gnoc ) ;;/" ../incrTcl/itcl/configure.orig > ../incrTcl/itcl/configure 
      }
      runcmd ../incrTcl/configure --with-tcl=$Slicer3_LIB/tcl-build/lib --with-tk=$Slicer3_LIB/tcl-build/lib --prefix=$Slicer3_LIB/tcl-build
      if { $isDarwin } {
        # need to run ranlib separately on lib for Darwin
        # file is created and ranlib is needed inside make all
        catch "eval runcmd $::MAKE all"
        runcmd ranlib ../incrTcl/itcl/libitclstub3.2.a
      }
      eval runcmd $::MAKE all
      eval runcmd $::SERIAL_MAKE install
    }
  }
}

################################################################################
# Get and build iwidgets
#
if { 0 } {
if { [BuildThis $::IWIDGETS_TEST_FILE "iwidgets"] == 1 } {
    cd $Slicer3_LIB/tcl

    runcmd  $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/tcl/iwidgets iwidgets

    if {$::GENLIB(buildit)} {
        if {$isWindows} {
            # is present in the windows binary download
        } else {
            cd $Slicer3_LIB/tcl/iwidgets
            runcmd ../iwidgets/configure --with-tcl=$Slicer3_LIB/tcl-build/lib --with-tk=$Slicer3_LIB/tcl-build/lib --with-itcl=$Slicer3_LIB/tcl/incrTcl --prefix=$Slicer3_LIB/tcl-build
            # make all doesn't do anything...
            # iwidgets won't compile in parallel (with -j flag)
            eval runcmd $::SERIAL_MAKE all
            eval runcmd $::SERIAL_MAKE install
        }
    }
}
}
################################################################################
# Get and build blt
#
if { 0 } {
if { !$isDarwin  && ([BuildThis $::BLT_TEST_FILE "blt"] == 1) } {
    cd $Slicer3_LIB/tcl

    runcmd  $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/tcl/blt blt
    if {$::GENLIB(buildit)} {
        if { $isWindows } { 
            # is present in the windows binary download
        } elseif { $isDarwin } {
            if { ![file exists $Slicer3_LIB/tcl/isPatchedBLT] } { 
              puts "Patching..." 
              runcmd curl -k -O https://share.spl.harvard.edu/share/birn/public/software/External/Patches/bltpatch 
              cd $Slicer3_LIB/tcl/blt 
              runcmd patch -p2 < ../bltpatch 

              # create a file to make sure BLT isn't patched twice 
              runcmd touch $Slicer3_LIB/tcl/isPatchedBLT 
              file delete $Slicer3_LIB/tcl/bltpatch

            } else { 
              puts "BLT already patched." 
            }
            cd $Slicer3_LIB/tcl/blt
            runcmd ./configure --with-tcl=$Slicer3_LIB/tcl/tcl/unix --with-tk=$Slicer3_LIB/tcl-build --prefix=$Slicer3_LIB/tcl-build --enable-shared --x-includes=/usr/X11R6/include --x-libraries=/usr/X11R6/lib --with-cflags=-fno-common
            eval runcmd $::MAKE
            eval runcmd $::MAKE install
        } else {
            cd $Slicer3_LIB/tcl/blt
            runcmd ./configure --with-tcl=$Slicer3_LIB/tcl/tcl/unix --with-tk=$Slicer3_LIB/tcl-build --prefix=$Slicer3_LIB/tcl-build
            eval runcmd $::SERIAL_MAKE
            eval runcmd $::SERIAL_MAKE install
        }
    }
}
}
################################################################################
# Get and build python
#
if { 0 } {
if {  [BuildThis $::PYTHON_TEST_FILE "python"] == 1 } {

    file mkdir $::Slicer3_LIB/python
    file mkdir $::Slicer3_LIB/python-build
    cd $::Slicer3_LIB

    if { $isWindows } {
      runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/Binaries/Windows/python-build python-build
    } else {
        cd $Slicer3_LIB/python
        runcmd $::SVN co $::PYTHON_TAG
        cd $Slicer3_LIB/python/release25-maint

        set ::env(LDFLAGS) -L$Slicer3_LIB/tcl-build/lib
        set ::env(CPPFLAGS) -I$Slicer3_LIB/tcl-build/include

        runcmd ./configure --prefix=$Slicer3_LIB/python-build --with-tcl=$Slicer3_LIB/tcl-build --enable-shared
        eval runcmd $::MAKE
        puts [catch "eval runcmd $::SERIAL_MAKE install" res] ;# try twice - it probably fails first time...
        if { $isDarwin } {
            # Special Slicer hack to build and install the .dylib
            file mkdir $::Slicer3_LIB/python-build/lib/
            file delete -force $::Slicer3_LIB/python-build/lib/libpython2.5.dylib
            set fid [open environhack.c w]
            puts $fid "char **environ=0;"
            close $fid
            runcmd gcc -c -o environhack.o environhack.c
            runcmd libtool -o $::Slicer3_LIB/python-build/lib/libpython2.5.dylib -dynamic  \
                -all_load libpython2.5.a environhack.o -single_module \
                -install_name $::Slicer3_LIB/python-build/lib/libpython2.5.dylib \
                -compatibility_version 2.5 \
                -current_version 2.5 -lSystem -lSystemStubs

        }
    }
}
}


################################################################################
# Get and build vtk
#

if { [BuildThis $::VTK_TEST_FILE "vtk"] == 1 } {
    cd $Slicer3_LIB

    eval "runcmd $::CVS -d :pserver:anonymous:vtk@public.kitware.com:/cvsroot/VTK login"
    eval "runcmd $::CVS $CVS_CO_FLAGS -d :pserver:anonymous@public.kitware.com:/cvsroot/VTK checkout -r $::VTK_RELEASE VTK"

    # Andy's temporary hack to get around wrong permissions in VTK cvs repository
    # catch statement is to make file attributes work with RH 7.3
    if { !$isWindows } {
        catch "file attributes $Slicer3_LIB/VTK/VTKConfig.cmake.in -permissions a+rw"
    }
    if {$::GENLIB(buildit)} {

      file mkdir $Slicer3_LIB/VTK-build
      cd $Slicer3_LIB/VTK-build

      set USE_VTK_ANSI_STDLIB ""
      if { $isWindows } {
        if {$MSVC6} {
            set USE_VTK_ANSI_STDLIB "-DVTK_USE_ANSI_STDLIB:BOOL=ON"
        }
      }

      #
      # Note - the two banches are identical down to the line starting -DOPENGL...
      # -- the text needs to be duplicated to avoid quoting problems with paths that have spaces
      #
      if { $isLinux && $::tcl_platform(machine) == "x86_64" } {
        eval runcmd $::CMAKE \
            $::CMAKE_COMPILE_SETTINGS  \
            $::OPENGL_COMPILE_SETTINGS \
            -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
            -DBUILD_SHARED_LIBS:BOOL=ON \
            -DCMAKE_SKIP_RPATH:BOOL=ON \
            -DBUILD_TESTING:BOOL=OFF \
            -DVTK_USE_CARBON:BOOL=OFF \
            -DVTK_USE_COCOA:BOOL=OFF \
            -DVTK_USE_X:BOOL=ON \
            -DVTK_WRAP_TCL:BOOL=ON \
            -DVTK_USE_HYBRID:BOOL=ON \
            -DVTK_USE_PATENTED:BOOL=ON \
            -DVTK_USE_PARALLEL:BOOL=ON \
            -DVTK_DEBUG_LEAKS:BOOL=$::VTK_DEBUG_LEAKS \
            -DTCL_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
            -DTK_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
            -DTCL_LIBRARY:FILEPATH=$::VTK_TCL_LIB \
            -DTK_LIBRARY:FILEPATH=$::VTK_TK_LIB \
            -DTCL_TCLSH:FILEPATH=$::VTK_TCLSH \
            $USE_VTK_ANSI_STDLIB \
            -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
            -DVTK_USE_64BIT_IDS:BOOL=ON \
            ../VTK
      } elseif { $isDarwin } {
        eval runcmd $::CMAKE \
            $::CMAKE_COMPILE_SETTINGS  \
            $::OPENGL_COMPILE_SETTINGS \
            -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
            -DBUILD_SHARED_LIBS:BOOL=ON \
            -DCMAKE_SKIP_RPATH:BOOL=OFF \
            -DBUILD_TESTING:BOOL=OFF \
            -DVTK_USE_CARBON:BOOL=OFF \
            -DVTK_USE_COCOA:BOOL=OFF \
            -DVTK_USE_X:BOOL=ON \
            -DVTK_WRAP_TCL:BOOL=ON \
            -DVTK_USE_HYBRID:BOOL=ON \
            -DVTK_USE_PATENTED:BOOL=ON \
            -DVTK_USE_PARALLEL:BOOL=ON \
            -DVTK_DEBUG_LEAKS:BOOL=$::VTK_DEBUG_LEAKS \
            -DOPENGL_INCLUDE_DIR:PATH=/usr/X11R6/include \
            -DTCL_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
            -DTK_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
            -DTCL_LIBRARY:FILEPATH=$::VTK_TCL_LIB \
            -DTK_LIBRARY:FILEPATH=$::VTK_TK_LIB \
            -DTCL_TCLSH:FILEPATH=$::VTK_TCLSH \
            $USE_VTK_ANSI_STDLIB \
            ../VTK
      } else {
        eval runcmd $::CMAKE \
            $::CMAKE_COMPILE_SETTINGS \
            -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
            -DBUILD_SHARED_LIBS:BOOL=ON \
            -DCMAKE_SKIP_RPATH:BOOL=ON \
            -DBUILD_TESTING:BOOL=OFF \
            -DVTK_USE_CARBON:BOOL=OFF \
            -DVTK_USE_COCOA:BOOL=OFF \
            -DVTK_USE_X:BOOL=ON \
            -DVTK_WRAP_TCL:BOOL=ON \
            -DVTK_USE_HYBRID:BOOL=ON \
            -DVTK_USE_PATENTED:BOOL=ON \
            -DVTK_USE_PARALLEL:BOOL=ON \
            -DVTK_DEBUG_LEAKS:BOOL=$::VTK_DEBUG_LEAKS \
            -DTCL_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
            -DTK_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
            -DTCL_LIBRARY:FILEPATH=$::VTK_TCL_LIB \
            -DTK_LIBRARY:FILEPATH=$::VTK_TK_LIB \
            -DTCL_TCLSH:FILEPATH=$::VTK_TCLSH \
            $USE_VTK_ANSI_STDLIB \
            ../VTK
      }

      if { $isWindows } {
        if { $MSVC6 } {
            runcmd $::MAKE VTK.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            runcmd $::MAKE VTK.SLN /build  $::VTK_BUILD_TYPE
        }
      } else {
        eval runcmd $::MAKE 
    }
  }
}

################################################################################
# Get and build kwwidgets
#

if { [BuildThis $::KWWidgets_TEST_FILE "kwwidgets"] == 1 } {
    cd $Slicer3_LIB

    runcmd $::CVS -d :pserver:anoncvs:@www.kwwidgets.org:/cvsroot/KWWidgets login
    eval "runcmd $::CVS $CVS_CO_FLAGS -d :pserver:anoncvs@www.kwwidgets.org:/cvsroot/KWWidgets checkout -D $::KWWIDGETS_DATE KWWidgets"

    if {$::GENLIB(buildit)} {
      file mkdir $Slicer3_LIB/KWWidgets-build
      cd $Slicer3_LIB/KWWidgets-build



     eval runcmd $::CMAKE \
        $::CMAKE_COMPILE_SETTINGS  \
        -DVTK_DIR:PATH=$Slicer3_LIB/VTK-build \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DCMAKE_SKIP_RPATH:BOOL=ON \
        -DBUILD_EXAMPLES:BOOL=ON \
        -DKWWidgets_BUILD_EXAMPLES:BOOL=ON \
        -DBUILD_TESTING:BOOL=ON \
        -DKWWidgets_BUILD_TESTING:BOOL=ON \
        -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
        ../KWWidgets

    if {$isWindows} {
        if { $MSVC6 } {
            runcmd $::MAKE KWWidgets.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            runcmd $::MAKE KWWidgets.SLN /build  $::VTK_BUILD_TYPE
        }
      } else {
        eval runcmd $::MAKE 
      }
  }
}

################################################################################
# Get and build itk
#

if { [BuildThis $::ITK_TEST_FILE "itk"] == 1 } {
    cd $Slicer3_LIB

#    eval runcmd $::SVN co http://svn.slicer.org/Slicer3/Slicer3/Slicer3-lib-mirrors/trunk/Insight Insight
## Checkout CableSwig
## Use a date tag where ITK and CableSwig can be compiled together.
# Moved up to slicer3_variables.tcl    set ::ITK_CABLE_DATE "2008-03-09"
#    eval runcmd $::CVS update -dAP -D $::ITK_CABLE_DATE
    runcmd $::CVS -d :pserver:anoncvs:@www.vtk.org:/cvsroot/Insight login
    eval "runcmd $::CVS $CVS_CO_FLAGS -d :pserver:anoncvs@www.vtk.org:/cvsroot/Insight checkout -r $::ITK_RELEASE Insight"

    # This is required because of a bug in the ITK version 3.10    
    file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/itkSpatialObjectTreeNode.h $Slicer3_LIB/Insight/Code/SpatialObject/itkSpatialObjectTreeNode.h
    
    cd $::Slicer3_LIB/Insight/Utilities

#set ::CSWIG_TAG "HEAD"
#eval runcmd $::CVS -d :pserver:anonymous@public.kitware.com:/cvsroot/CableSwig co -r $::CSWIG_TAG CableSwig
    eval "runcmd $::CVS -d :pserver:anonymous@public.kitware.com:/cvsroot/CableSwig co -r $::CSWIG_RELEASE  CableSwig"
    if { [ file exists $::Slicer3_LIB/Insight/Wrapping/WrapITK/Modules/Interpolators ] == 0 } {
      cp $::Slicer3_HOME/../brains3/SlicerPatches/wrap_itkWindowedSincInterpolateImageFunction.cmake $::Slicer3_LIB/Insight/Wrapping/WrapITK/Modules/Interpolators
    }
    cd $::Slicer3_LIB

    if {$::GENLIB(buildit)} {
      file mkdir $Slicer3_LIB/Insight-build
      cd $Slicer3_LIB/Insight-build


      if {$isDarwin} {
     eval runcmd $::CMAKE \
        $::CMAKE_COMPILE_SETTINGS  \
          { -DWRAP_ITK_DIMS:STRING=2\;3 } \
        -DBUILD_EXAMPLES:BOOL=OFF \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DBUILD_TESTING:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX:PATH=$::Slicer3_BUILD \
        -DCMAKE_SKIP_RPATH:BOOL=OFF \
        -DITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=OFF \
        -DITK_USE_ORIENTED_IMAGE_DIRECTION:BOOL=ON \
        -DITK_IMAGE_BEHAVES_AS_ORIENTED_IMAGE:BOOL=ON \
        -DITK_USE_TRANSFORM_IO_FACTORIES:BOOL=ON \
        -DITK_USE_REVIEW:BOOL=ON \
        -DUSE_WRAP_ITK:BOOL=ON \
        -DWRAP_ITK_JAVA:BOOL=OFF \
        -DWRAP_ITK_PYTHON:BOOL=OFF \
        -DWRAP_ITK_TCL:BOOL=ON \
        -DWRAP_complex_float:BOOL=OFF \
        -DWRAP_covariant_vector_float:BOOL=OFF \
        -DWRAP_float:BOOL=ON \
        -DWRAP_rgb_signed_short:BOOL=OFF \
        -DWRAP_rgb_unsigned_char:BOOL=OFF \
        -DWRAP_rgb_unsigned_short:BOOL=OFF \
        -DWRAP_signed_short:BOOL=ON \
        -DWRAP_unsigned_char:BOOL=ON \
        -DWRAP_unsigned_short:BOOL=OFF \
        -DWRAP_vector_float:BOOL=ON \
        -DTCL_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
        -DTK_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
        -DTCL_LIBRARY:FILEPATH=$::VTK_TCL_LIB \
        -DTK_LIBRARY:FILEPATH=$::VTK_TK_LIB \
        -DTCL_TCLSH:FILEPATH=$::VTK_TCLSH \
        -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
        ../Insight
      } else {
     eval runcmd $::CMAKE \
        $::CMAKE_COMPILE_SETTINGS \
          { -DWRAP_ITK_DIMS:STRING=2\;3 } \
        -DBUILD_EXAMPLES:BOOL=OFF \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DBUILD_TESTING:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX:PATH=$::Slicer3_BUILD \
        -DCMAKE_SKIP_RPATH:BOOL=ON \
        -DITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=OFF \
	-DITK_USE_ORIENTED_IMAGE_DIRECTION:BOOL=ON \
        -DITK_IMAGE_BEHAVES_AS_ORIENTED_IMAGE:BOOL=ON \
        -DITK_USE_TRANSFORM_IO_FACTORIES:BOOL=ON \
        -DITK_USE_REVIEW:BOOL=ON \
        -DUSE_WRAP_ITK:BOOL=ON \
        -DWRAP_ITK_JAVA:BOOL=OFF \
        -DWRAP_ITK_PYTHON:BOOL=OFF \
        -DWRAP_ITK_TCL:BOOL=ON \
        -DWRAP_complex_float:BOOL=OFF \
        -DWRAP_covariant_vector_float:BOOL=OFF \
        -DWRAP_float:BOOL=ON \
        -DWRAP_rgb_signed_short:BOOL=OFF \
        -DWRAP_rgb_unsigned_char:BOOL=OFF \
        -DWRAP_rgb_unsigned_short:BOOL=OFF \
        -DWRAP_signed_short:BOOL=ON \
        -DWRAP_unsigned_char:BOOL=ON \
        -DWRAP_unsigned_short:BOOL=OFF \
        -DWRAP_vector_float:BOOL=ON \
        -DTCL_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
        -DTK_INCLUDE_PATH:PATH=$TCL_INCLUDE_DIR \
        -DTCL_LIBRARY:FILEPATH=$::VTK_TCL_LIB \
        -DTK_LIBRARY:FILEPATH=$::VTK_TK_LIB \
        -DTCL_TCLSH:FILEPATH=$::VTK_TCLSH \
        -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
        ../Insight
      }

      if {$isWindows} {
        if { $MSVC6 } {
            runcmd $::MAKE ITK.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            runcmd $::MAKE ITK.SLN /build  $::VTK_BUILD_TYPE
        }
      } else {
        eval runcmd $::MAKE 
        eval runcmd $::MAKE install
    }
    puts "Patching ITK..."

    set fp1 [open "$Slicer3_LIB/Insight-build/Utilities/nifti/niftilib/cmake_install.cmake" r]
    set fp2 [open "$Slicer3_LIB/Insight-build/Utilities/nifti/znzlib/cmake_install.cmake" r]
    set data1 [read $fp1]
#    puts "data1 is $data1"
    set data2 [read $fp2]
#    puts "data2 is $data2"

    close $fp1
    close $fp2

    regsub -all /usr/local/lib $data1 \${CMAKE_INSTALL_PREFIX}/lib data1
    regsub -all /usr/local/include $data1 \${CMAKE_INSTALL_PREFIX}/include data1
    regsub -all /usr/local/lib $data2 \${CMAKE_INSTALL_PREFIX}/lib data2
    regsub -all /usr/local/include $data2 \${CMAKE_INSTALL_PREFIX}/include data2

    set fw1 [open "$Slicer3_LIB/Insight-build/Utilities/nifti/niftilib/cmake_install.cmake" w]
    set fw2 [open "$Slicer3_LIB/Insight-build/Utilities/nifti/znzlib/cmake_install.cmake" w]

    puts -nonewline $fw1 $data1
#    puts "data1out is $data1"
    puts -nonewline $fw2 $data2
#    puts "data2out is $data2"
 
    close $fw1
    close $fw2
  }
}


################################################################################
# Get and build teem
# -- relies on VTK's png and zlib
#

if { [BuildThis $::TEEM_TEST_FILE "teem"] == 1 } {
    cd $Slicer3_LIB

    runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/teem teem

    if {$::GENLIB(buildit)} {
      file mkdir $Slicer3_LIB/teem-build
      cd $Slicer3_LIB/teem-build

      if { $isDarwin } {
        set C_FLAGS -DCMAKE_C_FLAGS:STRING=-fno-common \
      } else {
        set C_FLAGS ""
      }

      switch $::tcl_platform(os) {
        "SunOS" -
        "Linux" {
            set zlib "libvtkzlib.so"
            set png "libvtkpng.so"
        }
        "Darwin" {
            set zlib "libvtkzlib.dylib"
            set png "libvtkpng.dylib"
        }
        "Windows NT" {
            set zlib "vtkzlib.lib"
            set png "vtkpng.lib"
        }
      }

     eval runcmd $::CMAKE \
        $::CMAKE_COMPILE_SETTINGS  \
        -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
        $C_FLAGS \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DBUILD_TESTING:BOOL=OFF \
        -DTEEM_ZLIB:BOOL=ON \
        -DTEEM_PNG:BOOL=ON \
        -DTEEM_VTK_MANGLE:BOOL=ON \
        -DTEEM_VTK_TOOLKITS_IPATH:FILEPATH=$::Slicer3_LIB/VTK-build \
        -DZLIB_INCLUDE_DIR:PATH=$::Slicer3_LIB/VTK/Utilities/vtkzlib \
        -DTEEM_ZLIB_DLLCONF_IPATH:PATH=$::Slicer3_LIB/VTK-build/Utilities \
        -DZLIB_LIBRARY:FILEPATH=$::Slicer3_LIB/VTK-build/bin/$::VTK_BUILD_SUBDIR/$zlib \
        -DPNG_PNG_INCLUDE_DIR:PATH=$::Slicer3_LIB/VTK/Utilities/vtkpng \
        -DTEEM_PNG_DLLCONF_IPATH:PATH=$::Slicer3_LIB/VTK-build/Utilities \
        -DPNG_LIBRARY:FILEPATH=$::Slicer3_LIB/VTK-build/bin/$::VTK_BUILD_SUBDIR/$png \
        ../teem

      if {$isWindows} {
        if { $MSVC6 } {
            runcmd $::MAKE teem.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            runcmd $::MAKE teem.SLN /build  $::VTK_BUILD_TYPE
        }
      } else {
        eval runcmd $::MAKE 
      }
  }
}



################################################################################
# Get and build igstk 
#
### Currently BRAINS does not need this
if { 0 } {
    cd $Slicer3_LIB

    runcmd $::CVS -d:pserver:anonymous:igstk@public.kitware.com:/cvsroot/IGSTK login
    eval "runcmd $::CVS $CVS_CO_FLAGS -d :pserver:anonymous@public.kitware.com:/cvsroot/IGSTK co -r IGSTK-2-0 IGSTK"

    if {$::GENLIB(buildit)} {
      file mkdir $Slicer3_LIB/IGSTK-build
      cd $Slicer3_LIB/IGSTK-build


      if {$isDarwin} {
        eval runcmd $::CMAKE \
            $::CMAKE_COMPILE_SETTINGS  \
            -DVTK_DIR:PATH=$VTK_DIR \
            -DITK_DIR:FILEPATH=$ITK_BINARY_PATH \
            -DBUILD_SHARED_LIBS:BOOL=ON \
            -DCMAKE_SKIP_RPATH:BOOL=OFF \
            -DIGSTK_BUILD_EXAMPLES:BOOL=OFF \
            -DIGSTK_BUILD_TESTING:BOOL=OFF \
            -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
            ../IGSTK
      } else {
        eval runcmd $::CMAKE \
            $::CMAKE_COMPILE_SETTINGS  \
            -DVTK_DIR:PATH=$VTK_DIR \
            -DITK_DIR:FILEPATH=$ITK_BINARY_PATH \
            -DBUILD_SHARED_LIBS:BOOL=ON \
            -DCMAKE_SKIP_RPATH:BOOL=ON \
            -DIGSTK_BUILD_EXAMPLES:BOOL=OFF \
            -DIGSTK_BUILD_TESTING:BOOL=OFF \
            -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
            ../IGSTK
      }

      if {$isWindows} {
        if { $MSVC6 } {
            runcmd $::MAKE IGSTK.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            runcmd $::MAKE IGSTK.SLN /build  $::VTK_BUILD_TYPE
        }
      } else {
        # Running this cmake again will populate those CMake variables 
        # in IGSTK/CMakeLists.txt marked as MARK_AS_ADVANCED with their 
        # default values. For instance, IGSTK_SERIAL_PORT_0, IGSTK_SERIAL_PORT_1,
        # IGSTK_SERIAL_PORT_2, ......
        eval runcmd $::CMAKE ../IGSTK 

        eval runcmd $::MAKE 
      }
  }
}

################################################################################
# Get and build SLICERLIBCURL (slicerlibcurl)
#
#

if { [BuildThis $::SLICERLIBCURL_TEST_FILE "libcurl"] == 1 } {
    cd $::Slicer3_LIB

    runcmd $::SVN co http://svn.slicer.org/Slicer3-lib-mirrors/trunk/cmcurl cmcurl
    if {$::GENLIB(buildit)} {

      file mkdir $::Slicer3_LIB/cmcurl-build
      cd $::Slicer3_LIB/cmcurl-build

     eval runcmd $::CMAKE \
        $::CMAKE_COMPILE_SETTINGS \
        -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DBUILD_TESTING:BOOL=OFF \
        ../cmcurl

      if {$isWindows} {
        if { $MSVC6 } {
            runcmd $::MAKE SLICERLIBCURL.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            runcmd $::MAKE SLICERLIBCURL.SLN /build  $::VTK_BUILD_TYPE
        }
      } else {
        eval runcmd $::MAKE
      }
  }
}
puts "BUILD INRIA"
##set inriaSiteStatus "Down"
set inriaSiteStatus "Up"
if { ${inriaSiteStatus} == "Up" } {
#
# get and build vtkinria3d
if { ![file exists $::vtkinria3d_TEST_FILE] || $::GENLIB(update) } {
    cd $Slicer3_LIB

    catch { eval runcmd $::SVN co svn://scm.gforge.inria.fr/svn/vtkinria3d -r "$::VTKINRIA3D_REVISION" }
#    catch { eval runcmd $::SVN co svn://scm.gforge.inria.fr/svn/vtkinria3d }
    file mkdir $Slicer3_LIB/vtkinria3d-build
    cd $Slicer3_LIB/vtkinria3d-build
    file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkFibersManager.cxx $Slicer3_LIB/vtkinria3d/vtkVisuManagement/vtkFibersManager.cxx
    file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkKWDICOMExporter.cxx $Slicer3_LIB/vtkinria3d/KWAddOn/vtkKWDICOMExporter.cxx
    file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkKWTimeAnimationWidget.cxx $Slicer3_LIB/vtkinria3d/KWAddOn/vtkKWTimeAnimationWidget.cxx

    if { $isWindows } {
      set ::GETBUILDTEST(cpack-generator) "NSIS"
    } else {
      set ::GETBUILDTEST(cpack-generator) "STGZ"
    }

    if {$isWindows} {
      set ::env(PATH) "$::env(PATH):$::Slicer3_BUILD/lib/InsightToolkit:$::Slicer3_BUILD/lib/vtk"
    }
    if { $isDarwin } {
      if { [info exists ::env(DYLD_LIBRARY_PATH)] } {
        set ::env(DYLD_LIBRARY_PATH) "$::env(DYLD_LIBRARY_PATH):$::Slicer3_BUILD/lib/InsightToolkit:$::Slicer3_BUILD/lib/vtk-5.1"
      } else {
        set ::env(DYLD_LIBRARY_PATH) "$::Slicer3_BUILD/lib/InsightToolkit:$::Slicer3_BUILD/lib/vtk"
      }
    }
    if { $isLinux } {
      if { [info exists ::env(LD_LIBRARY_PATH)] } {
        set ::env(LD_LIBRARY_PATH) "$::env(LD_LIBRARY_PATH):$::Slicer3_BUILD/lib/InsightToolkit:$::Slicer3_BUILD/lib/vtk-5.1"
      } else {
        set ::env(LD_LIBRARY_PATH) "$::Slicer3_BUILD/lib/InsightToolkit:$::Slicer3_BUILD/lib/vtk"
      }
    }

# -bind_at_load

    eval runcmd $::CMAKE \
        $::CMAKE_COMPILE_SETTINGS  \
        $::OPENGL_COMPILE_SETTINGS \
        -DCMAKE_BUILD_TYPE:STRING=$::VTK_BUILD_TYPE \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX:PATH=$::Slicer3_BUILD \
        -DITK_DIR:FILEPATH=$::Slicer3_LIB/Insight-build \
        -DKWWidgets_DIR:FILEPATH=$::Slicer3_LIB/KWWidgets-build \
        -DVTK_DIR:PATH=$Slicer3_LIB/VTK-build \
        -DUSE_KWWidgets:BOOL=ON \
        -DUSE_ITK:BOOL=ON \
        -DKWWIDGETS_OLD_API:BOOL=OFF \
        -DvtkINRIA3D_USE_KWWIDGETS_OLD_API:BOOL=OFF \
        -DCMAKE_BUILD_TYPE=$::VTK_BUILD_TYPE \
        ../vtkinria3d

#        -DCPACK_GENERATOR:STRING=$::GETBUILDTEST(cpack-generator) \
#        -DCPACK_PACKAGE_FILE_NAME:STRING=$::GETBUILDTEST(binary-filename) \

    if {$isWindows} {
        if { $MSVC6 } {
            eval runcmd $::MAKE vtkinria3d.dsw /MAKE "ALL_BUILD - $::VTK_BUILD_TYPE"
        } else {
            eval runcmd $::MAKE vtkinria3d.SLN /build  $::VTK_BUILD_TYPE
        }
    } else {
        eval runcmd $::MAKE
    }
}
}
puts "INRIA COMPLETE"

if {! $::GENLIB(buildit)} {
 exit 0
}

# Are all the test files present and accounted for?  If not, return error code

if { ![file exists $::CMAKE] } {
    puts "CMake test file $::CMAKE not found."
}
if { ![file exists $::TEEM_TEST_FILE] } {
    puts "Teem test file $::TEEM_TEST_FILE not found."
}
if { ![file exists $::SLICERLIBCURL_TEST_FILE] } {
    puts "SLICERLIBCURL test file $::SLICERLIBCURL_TEST_FILE not found."
}
if { ![file exists $::TCL_TEST_FILE] } {
    puts "Tcl test file $::TCL_TEST_FILE not found."
}
if { ![file exists $::TK_TEST_FILE] } {
    puts "Tk test file $::TK_TEST_FILE not found."
}
if { 0 } {
if { ![file exists $::ITCL_TEST_FILE] } {
    puts "incrTcl test file $::ITCL_TEST_FILE not found."
}
if { ![file exists $::IWIDGETS_TEST_FILE] } {
    puts "iwidgets test file $::IWIDGETS_TEST_FILE not found."
}
}
if { ![file exists $::VTK_TEST_FILE] } {
    puts "VTK test file $::VTK_TEST_FILE not found."
}
if { ![file exists $::ITK_TEST_FILE] } {
    puts "ITK test file $::ITK_TEST_FILE not found."
}

if { ![file exists $::CMAKE] || \
         ![file exists $::TEEM_TEST_FILE] || \
         ![file exists $::SLICERLIBCURL_TEST_FILE] || \
         ![file exists $::TCL_TEST_FILE] || \
         ![file exists $::TK_TEST_FILE] || \
         ![file exists $::VTK_TEST_FILE] || \
         ![file exists $::ITK_TEST_FILE] } {
    puts "Not all packages compiled; check errors and run genlib.tcl again."
    exit 1 
} else { 
    puts "All packages compiled."
    exit 0 
}
