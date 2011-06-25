#
# Today macro - Allows to retrieve current date in a cross-platform fashion (Unix-like and windows)
#
# Adapted from the work of Benoit Rat
# See http://www.cmake.org/pipermail/cmake/2009-February/027014.html
#


macro(TODAY RESULT)
  if(WIN32)
    execute_process(COMMAND cmd /c "date /T"
                    ERROR_VARIABLE getdate_error
                    RESULT_VARIABLE getdate_result
                    OUTPUT_VARIABLE ${RESULT}
                    OUTPUT_STRIP_TRAILING_WHITESPACE)

    #message(STATUS "getdate_error:${getdate_error}")
    #message(STATUS "getdate_result:${getdate_result}")
    #message(STATUS "${RESULT}:${${RESULT}}")

    string(REGEX REPLACE ".*(..)/(..)/(....)"
                          "\\3-\\1-\\2"
                          ${RESULT}
                          ${${RESULT}})
  elseif(UNIX)
    execute_process(COMMAND date "+%Y-%m-%d"
                    OUTPUT_VARIABLE ${RESULT}
                    OUTPUT_STRIP_TRAILING_WHITESPACE)

  else(WIN32)
    message(SEND_ERROR "error: Failed to obtain today date - ${RESULT} set to 0000-00-00")
    set(${RESULT} 0000-00-00)
  endif(WIN32)
endmacro(TODAY)

