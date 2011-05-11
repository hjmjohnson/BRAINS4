#!/bin/bash
# the next line restarts using tclsh \
    exec tclsh "$0" "$@"

################################################################################
#
# getbuildtest.tcl
#
# does an update and a clean build of slicer3 (including utilities and libs)
# then does a dashboard submission
#
# Usage:
#   getbuildtest [options] [target]
#
# Initiated - sp - 2006-05-11
#

################################################################################
#
# simple command line argument parsing
#

proc Usage { {msg ""} } {
    global SLICER
    
    set msg "$msg\nusage: getbuildtest \[options\] \[target\]"
    set msg "$msg\n  \[target\] is determined automatically if not specified"
    set msg "$msg\n  \[options\] is one of the following:"
    set msg "$msg\n   h --help : prints this message and exits"
    set msg "$msg\n   -f --clean : delete lib and build directories first"
    set msg "$msg\n   -t --test-type : CTest test target (default: Experimental)"
    set msg "$msg\n   -a --abi : Build Parameter Name (default: DEBUG)"
    set msg "$msg\n   --release : compile with optimization flags"
    set msg "$msg\n   -u --update : does a cvs/svn update on each lib"
    set msg "$msg\n   --version-patch : set the patch string for the build (used by installer)"
    set msg "$msg\n                   : default: version-patch is the current date"
    set msg "$msg\n   --tag : same as version-patch"
    set msg "$msg\n   --pack : run cpack after building (default: off)"
    set msg "$msg\n   --upload : set the upload string for the binary, used if pack is true"
    set msg "$msg\n            : snapshot (default), nightly, release"
    set msg "$msg\n   --doxy : just do an svn update on Slicer3 and run doxygen"
    set msg "$msg\n   --verbose : optional, print out lots of stuff, for debugging"
    set msg "$msg\n   --rpm : optional, specify CPack RPM generator for packaging"
    set msg "$msg\n   --deb : optional, specify CPack DEB generator for packaging"
    puts stderr $msg
}

set ::GETBUILDTEST(clean) "false"
set ::GETBUILDTEST(update) ""
set ::GETBUILDTEST(release) ""
set ::GETBUILDTEST(test-type) "Experimental"
set ::GETBUILDTEST(version-patch) ""
set ::GETBUILDTEST(pack) "false"
set ::GETBUILDTEST(upload) "false"
set ::GETBUILDTEST(uploadFlag) "nightly"
set ::GETBUILDTEST(doxy) "false"
set ::GETBUILDTEST(verbose) "false"
set ::::GETBUILDTEST(abi) "DEBUG"
set ::GETBUILDTEST(buildList) ""
set ::GETBUILDTEST(cpack-generator) ""

set strippedargs ""
set argc [llength $argv]
for {set i 0} {$i < $argc} {incr i} {
    set a [lindex $argv $i]
    switch -glob -- $a {
        "--clean" -
        "-f" {
            set ::GETBUILDTEST(clean) "true"
        }
        "--update" -
        "-u" {
            set ::GETBUILDTEST(update) "--update"
        }
        "--release" {
            set ::GETBUILDTEST(release) "--release"
            set ::VTK_BUILD_TYPE "Release"
        }
        "-t" -
        "--test-type" {
            incr i
            if { $i == $argc } {
                Usage "Missing test-type argument"
            } else {
                set ::GETBUILDTEST(test-type) [lindex $argv $i]
            }
        }
        "-a" -
        "--abi" {
            incr i
            if { $i == $argc } {
                Usage "Missing abi argument"
                exit -1;
            } else {
                set ::GETBUILDTEST(abi) [lindex $argv $i]
                  puts "Setting --abi to  ::GETBUILDTEST(abi)"
            }
        }
        "--tag" -
        "--version-patch" {
            incr i
            if { $i == $argc } {
                Usage "Missing version-patch argument"
            } else {
                set ::GETBUILDTEST(version-patch) [lindex $argv $i]
            }
        }
        "--pack" {
                set ::GETBUILDTEST(pack) "true"            
        }
        "--upload" {
            set ::GETBUILDTEST(upload) "true"
            incr i
            if {$i == $argc} {
                # uses default value                
            } else {
                # peek at the next arg to see if we should use it...
                set arg [lindex $argv $i]
                if { [string match "--*" $arg] } {
                  # next arg is another -- flag, so don't use it as the
                  # upload flag...
                  incr i -1
                } else {
                  set ::GETBUILDTEST(uploadFlag) [lindex $argv $i]
                }
            }
        }
        "--doxy" {
            set ::GETBUILDTEST(doxy) "true"
        }
        "--verbose" {
            set ::GETBUILDTEST(verbose) "true"
        }
        "--rpm" {
            set ::GETBUILDTEST(cpack-generator) "RPM"
        }
        "--deb" {
            set ::GETBUILDTEST(cpack-generator) "DEB"
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

if {$argc > 1 } {
    Usage
    exit 1
}
puts "getbuildtest: setting build list to $strippedargs"
set ::GETBUILDTEST(buildList) $strippedargs



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


#initialize platform variables
foreach v { isSolaris isWindows isDarwin isLinux } { set $v 0 }
switch $tcl_platform(os) {
    "SunOS" { set isSolaris 1 }
    "Linux" { set isLinux 1 }
    "Darwin" { set isDarwin 1 }
    default { set isWindows 1 }
}

################################################################################
# First, set up the directory
# - determine the location
# - determine the build
# 

set script [info script]
catch {set script [file normalize $script]}
set ::Slicer3_HOME [file dirname [file dirname $script]]
set cwd [pwd]
cd [file dirname [info script]]
cd ..
set ::Slicer3_HOME [pwd]
cd $cwd
if { $isWindows } {
  set ::Slicer3_HOME [file attributes $::Slicer3_HOME -shortname]
}
set ::Slicer3_BUILD_TYPE $::GETBUILDTEST(abi)
set env(Slicer3_BUILD_TYPE) $::Slicer3_BUILD_TYPE

if { [string match $tcl_platform(os) "Windows NT"] } {
  set ::Slicer3_LIB [file dirname $::Slicer3_HOME]/Slicer3-COMPILE/Win32/${::Slicer3_BUILD_TYPE}-lib
  set ::Slicer3_BUILD [file dirname $::Slicer3_HOME]/Slicer3-COMPILE/Win32/${::Slicer3_BUILD_TYPE}-build
} else {
  set ::Slicer3_LIB [file dirname $::Slicer3_HOME]/Slicer3-COMPILE/$tcl_platform(os)/${::Slicer3_BUILD_TYPE}-lib
  set ::Slicer3_BUILD [file dirname $::Slicer3_HOME]/Slicer3-COMPILE/$tcl_platform(os)/${::Slicer3_BUILD_TYPE}-build
}
# use an environment variable so doxygen can use it
set ::env(Slicer3_DOC) $::Slicer3_HOME/../Slicer3-doc


#######
#
# Note: the local vars file, slicer2/slicer_variables.tcl, overrides the default values in this script
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

puts "making with $::MAKE"


#
# Deletes both Slicer3_LIB and Slicer3_BUILD if clean option given
#
# tcl file delete is broken on Darwin, so use rm -rf instead
if { $::GETBUILDTEST(clean) } {
    puts "Deleting slicer lib files..."
    if { $isDarwin } {
        runcmd rm -rf $Slicer3_LIB
        runcmd rm -rf $Slicer3_BUILD
        if { [file exists $Slicer3_LIB/tcl/isPatched] } {
            runcmd rm $Slicer3_LIB/tcl/isPatched
        }

        if { [file exists $Slicer3_LIB/tcl/isPatchedBLT] } {
            runcmd rm $Slicer3_LIB/tcl/isPatchedBLT
        }
    } else {
        file delete -force $Slicer3_LIB
        file delete -force $Slicer3_BUILD
    }
}

if { ![file exists $Slicer3_LIB] } {
    file mkdir $Slicer3_LIB
}

if { ![file exists $Slicer3_BUILD] } {
    file mkdir $Slicer3_BUILD
}

if { $::GETBUILDTEST(doxy) && ![file exists $::env(Slicer3_DOC)] } {
    puts "Making documentation directory  $::env(Slicer3_DOC)"
    file mkdir $::env(Slicer3_DOC)
}


################################################################################
#
# the actual build and test commands
# - checkout the source code
# - make the prerequisite libs
# - cmake and build the program
# - run the tests
# - make a package
#


# svn checkout (does an update if it already exists)
cd $::Slicer3_HOME/..
if { [file exists Slicer3] } {
    cd Slicer3
    eval runcmd svn switch $::SLICER_TAG
#     runcmd svn update $::SLICER_TAG
  } else {
    runcmd svn checkout $::SLICER_TAG Slicer3
  }

if { $::GETBUILDTEST(doxy) } {
    # just run doxygen and exit
    puts "Creating documenation files in $::env(Slicer3_DOC)"
    set cmd "doxygen $::Slicer3_HOME/Doxyfile"
    eval runcmd $cmd
    return
}

puts "Run gen lib 3"
# build the lib with options
cd $::Slicer3_HOME
set cmd "bash ./Scripts/genlib3.tcl $Slicer3_LIB $::Slicer3_BUILD"
if { $::GETBUILDTEST(release) != "" } {
   append cmd " $::GETBUILDTEST(release)"
} 
if { $::GETBUILDTEST(update) != "" } {
   append cmd " $::GETBUILDTEST(update)"
} 
if { $::GETBUILDTEST(buildList) != "" } {
    # puts "Passing $::GETBUILDTEST(buildList) to genlib"
    append cmd " $::GETBUILDTEST(buildList)"
}

eval runcmd $cmd

puts "BUILD SLicer"

if { $::GETBUILDTEST(version-patch) == "" } {
  # TODO: add build type (win32, etc) here...
  set ::GETBUILDTEST(version-patch) [clock format [clock seconds] -format %Y-%m-%d]
}

# set the binary filename root
set ::GETBUILDTEST(binary-filename) "Slicer3-3.3-alpha-$::GETBUILDTEST(version-patch)-$::env(BUILD)"
if {$::GETBUILDTEST(verbose)} {
    puts "CPack will use $::::GETBUILDTEST(binary-filename)"
}

# set the cpack generator to determine the binary file extension
if {$isLinux || $isDarwin} {
    if { $::GETBUILDTEST(cpack-generator) == "" } {
        # default generator is TGZ"
        set ::GETBUILDTEST(cpack-generator) "TGZ"
        set ::GETBUILDTEST(cpack-extension) ".tar.gz"
        # if wish to have .sh, use generator = STGZ and extension = .sh / currently disabled due to Ubuntu bug
    }
    if {$::GETBUILDTEST(cpack-generator) == "RPM" || $::GETBUILDTEST(cpack-generator) == "DEB"} {
        # RPMs cannot have dashes in the version names, so we use underscores instead
        set ::GETBUILDTEST(version-patch) [clock format [clock seconds] -format %Y_%m_%d]

        if { $::GETBUILDTEST(cpack-generator) == "RPM" } {
            set ::GETBUILDTEST(cpack-extension) ".rpm"
        }
        if { $::GETBUILDTEST(cpack-generator) == "DEB" } {
            set ::GETBUILDTEST(cpack-extension) ".deb"
        }
    } 
}

if {$isWindows} {
    set ::GETBUILDTEST(cpack-generator) "NSIS"
    set ::GETBUILDTEST(cpack-extension) ".exe"
}

# once dmg packaging is done
if {0 && $isDarwin} {
   set ::GETBUILDTEST(cpack-generator) "OSXX11"
   set ::GETBUILDTEST(cpack-extension) ".dmg"
}

# make verbose makefiles?
if {$::GETBUILDTEST(verbose)} {
   set ::GETBUILDTEST(cmake-verbose) "ON"
} else {
   set ::GETBUILDTEST(cmake-verbose) "OFF"
}

# build the slicer
if { [file exists $::SLICER_TEST_FILE] == 0 } {
  cd $::Slicer3_BUILD
  if { [catch {glob *} ] == 0 } {
    eval file delete -force [glob *]
  }
  # Changes required for gcc version 4.3
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/ModuleProcessInformation.h $::Slicer3_HOME/Libs/ModuleDescriptionParser/ModuleProcessInformation.h 
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/ModuleProcessInformation.h $::Slicer3_HOME/Libs/LoadableModule/ModuleProcessInformation.h
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/BatchMakeUtilities.cxx $::Slicer3_HOME/Libs/ModuleDescriptionParser/BatchMakeUtilities.cxx
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecProject.cpp $::Slicer3_HOME/Libs/Qdec/QdecProject.cpp
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecDataTable.cpp $::Slicer3_HOME/Libs/Qdec/QdecDataTable.cpp
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecFactor.cpp $::Slicer3_HOME/Libs/Qdec/QdecFactor.cpp
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecGlmDesign.cpp $::Slicer3_HOME/Libs/Qdec/QdecGlmDesign.cpp
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecGlmFit.cpp $::Slicer3_HOME/Libs/Qdec/QdecGlmFit.cpp
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecSubject.cpp $::Slicer3_HOME/Libs/Qdec/QdecSubject.cpp
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/QdecUtilities.cpp $::Slicer3_HOME/Libs/Qdec/QdecUtilities.cpp 
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/ModuleFactoryTest.cxx $::Slicer3_HOME/Libs/ModuleDescriptionParser/Testing/ModuleFactoryTest.cxx
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkImageConnectivity.cxx $::Slicer3_HOME/Base/Logic/vtkImageConnectivity.cxx
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkTextureText.h $::Slicer3_HOME/Modules/QueryAtlas/vtkTextureText.h
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkRectangle.cxx $::Slicer3_HOME/Modules/QueryAtlas/vtkRectangle.cxx
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/vtkTimeDef.h $::Slicer3_HOME/Modules/EMSegment/Algorithm/vtkTimeDef.h
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/ModuleProcessInformation.h $::Slicer3_HOME/Libs/LoadableModule/ModuleProcessInformation.h .
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/CMakeLists-Slicer-CLI.txt $::Slicer3_HOME/Applications/CLI/CMakeLists.txt 
  file copy -force $::Slicer3_HOME/../trunk/SlicerPatches/slicerio.c $::Slicer3_HOME/Libs/SlicerIO/slicerio.c

  eval runcmd $::CMAKE \
          $::CMAKE_COMPILE_SETTINGS \
          $::OPENGL_COMPILE_SETTINGS \
          -DITK_DIR:FILEPATH=$ITK_BINARY_PATH \
          -DKWWidgets_DIR:FILEPATH=$Slicer3_LIB/KWWidgets-build \
          -DTEEM_DIR:FILEPATH=$Slicer3_LIB/teem-build \
          -DIGSTK_DIR:FILEPATH=$Slicer3_LIB/IGSTK-build \
          -DINCR_TCL_LIBRARY:FILEPATH=$::INCR_TCL_LIB \
          -DINCR_TK_LIBRARY:FILEPATH=$::INCR_TK_LIB \
          -DSlicer3_USE_PYTHON=OFF \
          -DPYTHON_INCLUDE_PATH:PATH=$::PYTHON_INCLUDE \
          -DPYTHON_LIBRARY:FILEPATH=$::PYTHON_LIB \
          -DSandBox_DIR:FILEPATH=$Slicer3_LIB/NAMICSandBox \
          -DCMAKE_BUILD_TYPE=$::VTK_BUILD_TYPE \
          -DSlicer3_VERSION_PATCH:STRING=$::GETBUILDTEST(version-patch) \
          -DCPACK_GENERATOR:STRING=$::GETBUILDTEST(cpack-generator) \
          -DCPACK_PACKAGE_FILE_NAME:STRING=$::GETBUILDTEST(binary-filename) \
          -DSlicer3_USE_IGSTK=$::IGSTK \
          -DSlicer3_USE_NAVITRACK=$::NAVITRACK \
          -DNAVITRACK_LIB_DIR:FILEPATH=$::NAVITRACK_LIB_DIR \
          -DNAVITRACK_INC_DIR:FILEPATH=$::NAVITRACK_INC_DIR \
          -DSLICERLIBCURL_DIR:FILEPATH=$Slicer3_LIB/cmcurl-build \
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=$::GETBUILDTEST(cmake-verbose) \
          $Slicer3_HOME

  if { $isWindows } {
      if { $MSVC6 } {
          eval runcmd $::MAKE Slicer3.dsw /MAKE $::GETBUILDTEST(test-type)
          if { $::GETBUILDTEST(pack) == "true" } {
              eval runcmd $::MAKE Slicer3.dsw /MAKE package
          }
      } else {
          # tell cmake explicitly what command line to run when doing the ctest builds
          set makeCmd "$::MAKE Slicer3.sln /build $::VTK_BUILD_TYPE /project ALL_BUILD"
          runcmd $::CMAKE -DMAKECOMMAND:STRING=$makeCmd $Slicer3_HOME

          if { $::GETBUILDTEST(test-type) == "" } {
              runcmd $::MAKE Slicer3.SLN /build $::VTK_BUILD_TYPE
          } else {
              # running ctest through visual studio is broken in cmake2.4, so run ctest directly
              #runcmd $::CMAKE_PATH/bin/ctest -D $::GETBUILDTEST(test-type) -C $::VTK_BUILD_TYPE
	      runcmd $::MAKE Slicer3.SLN /build $::VTK_BUILD_TYPE
          }

          if { $::GETBUILDTEST(pack) == "true" } {
              runcmd $::MAKE Slicer3.SLN /build $::VTK_BUILD_TYPE /project PACKAGE
          }
      }
  } else {

      eval runcmd $::MAKE

  #    puts "\nResults: "
  #    puts "build of \"$::GETBUILDTEST(test-type)\" [if $buildReturn "concat failed" "concat succeeded"]"
  #    if { $::GETBUILDTEST(pack) == "true" } {
  #        puts "package [if $packageReturn "concat failed" "concat succeeded"]"
  #    }
  }
}
# build BRAINS version 3
if { [file exists $::Slicer3_BUILD/brains3-build] == 0 } {
  file mkdir  $::Slicer3_BUILD/brains3-build
}
   cd $::Slicer3_BUILD/brains3-build
   if { [catch {glob *} ] == 0 } {
    eval file delete -force [glob *]
   }
   eval runcmd $::CMAKE \
           $::CMAKE_COMPILE_SETTINGS  \
           $::OPENGL_COMPILE_SETTINGS \
           -DCMAKE_BUILD_TYPE=$::VTK_BUILD_TYPE \
           -DMAKECOMMAND:STRING=$::MAKE \
           -DITK_DIR:FILEPATH=${ITK_BINARY_PATH} \
           -DKWWidgets_DIR:FILEPATH=$::Slicer3_LIB/KWWidgets-build \
           -DVTK_DIR:FILEPATH=$::Slicer3_LIB/VTK-build \
           -DSlicer3_BINARY_DIR:FILEPATH=$::Slicer3_BUILD \
           -DCMAKE_INSTALL_PREFIX:PATH=$::Slicer3_BUILD \
           -DCPACK_GENERATOR:STRING=$::GETBUILDTEST(cpack-generator) \
           -DCPACK_PACKAGE_FILE_NAME:STRING=$::GETBUILDTEST(binary-filename) \
           -DUSE_OLD_BUILD:BOOL=OFF \
           -DBRAINS_BUILD_TESTING:BOOL=ON \
           -DBRAINS_BINARY_DIR:PATH=$::Slicer3_BUILD \
           -DDISABLE_ITK_TESTING:BOOL=ON \
           -DDISABLE_ALT_DICOM_FILTERS:BOOL=ON \
           -DUSE_GUI:BOOL=OFF \
           -DENABLE_TEST_IN_GUI_MODE:BOOL=OFF \
           -DUSE_BRAINS_BETA:BOOL=ON \
           -DUSE_BRAINS_ALPHA:BOOL=ON \
           -DCMAKE_SKIP_RPATH:BOOL=ON \
           -DUSE_PYTHON:BOOL=OFF\
           -DUSE_TCL:BOOL=ON\
           -DBUILD_WRAPPERS:BOOL=ON\
           -DWrapITK_DIR:PATH=$::Slicer3_LIB/Insight-build/Wrapping/WrapITK \
           -DINSTALL_DEVEL_FILES:BOOL=ON\
           -DBUILD_SHARED_LIBS:BOOL=ON \
           -DTCL_INCLUDE_PATH:PATH=$::Slicer3_LIB/tcl-build/include \
           -DTCL_LIBRARY:FILEPATH=$::TCL_LIB_DIR/libtcl8.4.$shared_lib_ext \
           -DTK_INCLUDE_PATH:PATH=$::Slicer3_LIB/tcl-build/include \
           -DTK_LIBRARY:FILEPATH=$::TCL_LIB_DIR/libtk8.4.$shared_lib_ext \
           -DGENERATECLP_EXE:FILEPATH=$::Slicer3_BUILD/bin/GenerateCLP \
           -DvtkINRIA3D_DIR:PATH=$::vtkinria3d_BUILD_DIR \
           -DBUILD_AGAINST_SLICER3:BOOL=ON \
           $::Slicer3_HOME/../trunk

if { $isWindows } {
    if { $MSVC6 } {
        eval runcmd $::MAKE BRAINS_Complete.dsw /MAKE $::GETBUILDTEST(test-type)
        if { $::GETBUILDTEST(pack) == "true" } {
            eval runcmd $::MAKE BRAINS_Complete.dsw /MAKE package
        }
    } else {
        # tell cmake explicitly what command line to run when doing the ctest builds
        set makeCmd "$::MAKE BRAINS_Complete.sln /build $::VTK_BUILD_TYPE /project ALL_BUILD"
        runcmd $::CMAKE -DMAKECOMMAND:STRING=$makeCmd $BRAINS_Complete_HOME

        if { $::GETBUILDTEST(test-type) == "" } {
            runcmd $::MAKE BRAINS_Complete.SLN /build $::VTK_BUILD_TYPE
        } else {
            # running ctest through visual studio is broken in cmake2.4, so run ctest directly
            runcmd $::CMAKE_PATH/bin/ctest -D $::GETBUILDTEST(test-type) -C $::VTK_BUILD_TYPE
        }

        if { $::GETBUILDTEST(pack) == "true" } {
            runcmd $::MAKE BRAINS_Complete.SLN /build $::VTK_BUILD_TYPE /project PACKAGE
        }
    }
} else {
    set buildReturn [catch "eval runcmd $::MAKE $::GETBUILDTEST(test-type)"]
    if { $::GETBUILDTEST(pack) == "true" } {
        set packageReturn [catch "eval runcmd $::MAKE package"]
    }

    puts "\nResults: "
    puts "build of \"$::GETBUILDTEST(test-type)\" [if $buildReturn "concat failed" "concat succeeded"]"
    if { $::GETBUILDTEST(pack) == "true" } {
        puts "package [if $packageReturn "concat failed" "concat succeeded"]"
    }
}


# upload

if {$::GETBUILDTEST(upload) == "true"} {
    set scpfile "${::GETBUILDTEST(binary-filename)}${::GETBUILDTEST(cpack-extension)}"
    set namic_path "/clients/Slicer3/WWW/Downloads"
    if {$::GETBUILDTEST(pack) == "true" &&  
        [file exists $::Slicer3_BUILD/$scpfile] && 
        $::GETBUILDTEST(upload) == "true"} {
        puts "About to do a $::GETBUILDTEST(uploadFlag) upload with $scpfile"
    }

    switch $::GETBUILDTEST(uploadFlag) {
        "nightly" {            
            # reset the file name - take out the date
            #set ex ".${::GETBUILDTEST(version-patch)}"
            #regsub $ex $scpfile "" scpNightlyFile
            #set scpfile $scpNightlyFile
            set scpdest "${namic_path}/Nightly"
        }
        "snapshot" {
            set scpdest "${namic_path}/Snapshots/$::env(BUILD)"
        }
        "release" {
            set scpdest "${namic_url}/Release/$::env(BUILD)"
        }
        default {
            puts "Invalid ::GETBUILDTEST(uploadFlag) \"$::GETBUILDTEST(uploadFlag)\", setting scpdest to nightly value"
            set scpdest "${namic_path}/Nightly"
        }
    }

    puts " -- upload $scpfile to $scpdest"
    set curlcmd ""
    switch $::tcl_platform(os) {
        "SunOS" -
        "Linux" {
            set scpcmd "/usr/bin/scp $scpfile hayes@na-mic1.bwh.harvard.edu:$scpdest"
        }
        "Darwin" {            
            set scpcmd "/usr/bin/scp $scpfile hayes@na-mic1.bwh.harvard.edu:$scpdest"
        }
        default {             
            set scpcmd "scp $scpfile hayes@na-mic1.bwh.harvard.edu:$scpdest"
        }
    }

    set scpReturn [catch "eval runcmd [split $scpcmd]"]
    if {$scpReturn} {
        puts "Upload failed..."
    } else {
        puts "See http://www.na-mic.org/Slicer/Download, in the $::GETBUILDTEST(uploadFlag) directory, for the uploaded file."
    }

    #else {
    #    if {$::GETBUILDTEST(verbose)} {
    #    puts "Not uploading $scpfile"
    #    }
    #}

}
