#
# FindGit
#

set(Git_FOUND FALSE)

find_program(Git_EXECUTABLE git
  DOC "git command line client")
mark_as_advanced(Git_EXECUTABLE)

if(Git_EXECUTABLE)
  set(Git_FOUND TRUE)
  macro(Git_WC_INFO dir prefix)
    execute_process(COMMAND ${Git_EXECUTABLE} rev-list -n 1 HEAD
       WORKING_DIRECTORY ${dir}
       ERROR_VARIABLE Git_error
       OUTPUT_VARIABLE ${prefix}_WC_REVISION_HASH
       OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT ${Git_error} EQUAL 0)
      message(SEND_ERROR "Command \"${Git_EXECUTBALE} rev-list -n 1 HEAD\" in directory ${dir} failed with output:\n${Git_error}")
    else(NOT ${Git_error} EQUAL 0)
      execute_process(COMMAND ${Git_EXECUTABLE} name-rev ${${prefix}_WC_REVISION_HASH}
         WORKING_DIRECTORY ${dir}
         OUTPUT_VARIABLE ${prefix}_WC_REVISION_NAME
          OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif(NOT ${Git_error} EQUAL 0)

    # In case, git-svn is used, attempt to extract svn info
    execute_process(COMMAND ${Git_EXECUTABLE} svn info
      WORKING_DIRECTORY ${dir}
      ERROR_VARIABLE git_svn_info_error
      OUTPUT_VARIABLE ${prefix}_WC_INFO
      RESULT_VARIABLE git_svn_info_result
      OUTPUT_STRIP_TRAILING_WHITESPACE)

    if(NOT ${git_svn_info_result} EQUAL 0)
      #message(SEND_ERROR "Command \"${Git_SVN_EXECUTABLE} info ${dir}\" failed with output:\n${git_svn_info_error}")
    else(NOT ${git_svn_info_result} EQUAL 0)

      string(REGEX REPLACE "^(.*\n)?URL: ([^\n]+).*"
        "\\2" ${prefix}_WC_URL "${${prefix}_WC_INFO}")
      string(REGEX REPLACE "^(.*\n)?Revision: ([^\n]+).*"
        "\\2" ${prefix}_WC_REVISION "${${prefix}_WC_INFO}")
      string(REGEX REPLACE "^(.*\n)?Last Changed Author: ([^\n]+).*"
        "\\2" ${prefix}_WC_LAST_CHANGED_AUTHOR "${${prefix}_WC_INFO}")
      string(REGEX REPLACE "^(.*\n)?Last Changed Rev: ([^\n]+).*"
        "\\2" ${prefix}_WC_LAST_CHANGED_REV "${${prefix}_WC_INFO}")
      string(REGEX REPLACE "^(.*\n)?Last Changed Date: ([^\n]+).*"
        "\\2" ${prefix}_WC_LAST_CHANGED_DATE "${${prefix}_WC_INFO}")

    endif(NOT ${git_svn_info_result} EQUAL 0)

  endmacro(Git_WC_INFO)
endif(Git_EXECUTABLE)
