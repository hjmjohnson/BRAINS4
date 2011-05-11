#
# FFTW at this point must be statically linked, this is a bug in their build system.
# As it happens, it doesn't depend on any of our other build modules, so it
# can be statically linked even if everything else is shared.
#
if(DEFINED FFTW_DIR AND NOT EXISTS ${FFTW_DIR})
  message(FATAL_ERROR "FFTW_DIR variable is defined but corresponds to non-existing directory")
endif()

set(LIB_EXT a)

if(NOT DEFINED FFTW_DIR)

  set(FFTW_DEPEND FFTW)
  set(proj FFTW)
  ExternalProject_add(${proj}
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
    URL "http://www.fftw.org/fftw-3.2.2.tar.gz"
    DOWNLOAD_DIR ${proj}/download
    CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/${proj}/configure --prefix=${CMAKE_INSTALL_PREFIX} --disable-fortran
    )
  set(FFTW_INSTALL_BASE_PATH CACHE PATH ${CMAKE_INSTALL_PREFIX})
  set(USE_FFTWD ON)
endif(NOT DEFINED FFTW_DIR)
