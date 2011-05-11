if ( $# > 0 ) then
  set BUILD_DIR=$1
else
  set BUILD_DIR=`pwd`
endif

if (-e $BUILD_DIR/src/lib)
  set LIB_DIR=$BUILD_DIR/src/lib
else
  set LIB_DIR=$BUILD_DIR/lib
endif

set libs="${LIB_DIR}:${LIB_DIR}/InsightToolkit:${LIB_DIR}/vtk-5.6:${LIB_DIR}/BRAINSCommonLib"

if ( `uname` == "Darwin" ) then
   if ( ${?DYLD_LIBRARY_PATH} ) then
    setenv DYLD_LIBRARY_PATH "${libs}:${DYLD_LIBRARY_PATH}"
   else
    setenv DYLD_LIBRARY_PATH "${libs}"
   endif
else
   if ( ${?LD_LIBRARY_PATH} ) then
    setenv LD_LIBRARY_PATH "${libs}:${LD_LIBRARY_PATH}"
   else
    setenv LD_LIBRARY_PATH "${libs}"
   endif
endif
