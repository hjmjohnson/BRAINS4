# This is a very ugly hack that will only work on Mac computers for now.
# I want a fully functional python environment inside of BRAINS4

set(SPYDER_PYTHON_EXECUTABLE "${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}")

set(SPYDER_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/SPYDER)
if(APPLE)
  set(SPYDER_EASY_INSTALL_EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/Library/Framework/Python.framework/Versions/2.6/bin/easy_install-2.6)
  set(SPYDER_PYTHON_EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/Library/Framework/Python.framework/Versions/2.6/bin/python2.6)
else()
  set(SPYDER_EASY_INSTALL_EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/bin/easy_install-2.6)
  set(SPYDER_PYTHON_EXECUTABLE ${CMAKE_CURRENT_BINARY_DIR}/bin/python2.6)
endif()

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild/spyder_config.sh.in
  ${SPYDER_BINARY_DIR}/spyder_config.sh
  @ONLY IMMEDIATE)

# create an external project to download SPYDER,
# and configure and build it
ExternalProject_Add(SPYDER
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild/SPYDER
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/SPYDER
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
    ${ep_common_args}
    -DCMAKE_CURRENT_BINARY_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}
    BUILD_COMMAND /bin/bash ${SPYDER_BINARY_DIR}/spyder_config.sh
    UPDATE_COMMAND ""
    INSTALL_COMMAND ""
    DEPENDS ${SPYDER_DEPENDENCIES}
  )
