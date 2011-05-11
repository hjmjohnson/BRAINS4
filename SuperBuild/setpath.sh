if [ $# -gt 0 ] ; then
  BUILD_DIR=${1}
else
  BUILD_DIR=$(pwd)
fi

if [ -e ${BUILD_DIR}/src/lib ]; then
  LIB_DIR=${BUILD_DIR}/src/lib
else
  LIB_DIR=${BUILD_DIR}/lib
fi

libs="${LIB_DIR}:${LIB_DIR}/InsightToolkit:${LIB_DIR}/vtk-5.6:${LIB_DIR}/BRAINSCommonLib"

if [ $(uname) == "Darwin" ] ; then
   if [ "${DYLD_LIBRARY_PATH}" ] ; then
    export DYLD_LIBRARY_PATH="${libs}:${DYLD_LIBRARY_PATH}"
   else
    export DYLD_LIBRARY_PATH="${libs}"
   fi
else
   if [ "${LD_LIBRARY_PATH}" ] ; then
    export LD_LIBRARY_PATH="${libs}:${LD_LIBRARY_PATH}"
   else
    export LD_LIBRARY_PATH="${libs}"
   fi
fi
