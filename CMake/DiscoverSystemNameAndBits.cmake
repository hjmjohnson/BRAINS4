#
# DiscoverSystemNameAndBits - Set the variable Slicer3_BUILD and Slicer3_BUILD_BITS
#

# Slicer3_BUILD can take on of the following value:
#   solaris8, linux-x86, linux-x86_64, darwin-ppc, darwin-x86, darwin-x86_64, win32, win64


set(Slicer3_BUILD "")

set(Slicer3_BUILD_BITS "32")
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(Slicer3_BUILD_BITS "64")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")

  set(Slicer3_BUILD "win${Slicer3_BUILD_BITS}")

elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")

  set(Slicer3_BUILD "linux-x86")
  if(Slicer3_BUILD_BITS STREQUAL "64")
    set(Slicer3_BUILD "linux-x86_64")
  endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")

  # we do not differentiate 32 vs 64 for mac - all are 64 bit.
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "powerpc")
    set(Slicer3_BUILD "darwin-ppc")
  else(CMAKE_SYSTEM_PROCESSOR MATCHES "powerpc")
    set(Slicer3_BUILD "darwin-x86")
  endif()

elseif(CMAKE_SYSTEM_NAME STREQUAL "Solaris")

  set(Slicer3_BUILD "solaris8") # What about solaris9 and solaris10 ?

endif()
