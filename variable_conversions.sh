#!/bin/bash 

varold=$1
varnew=$2
  echo "going to do sed \"s#${varold}#${varnew}#g\" " and  "going to do grep -l \"${varold}" ${file}\"
 for file in \
   `find ./* -name Root -type f | grep -v '.svn'` \
   `find ./* -name CMakeLists.txt -type f | grep -v '.svn'` \
             `find ./* -name  "*.txx" -type f | grep -v '.svn'` `find ./* -name  "*.[ch][cxp]*" -type f | grep -v '.svn'` `find ./* -name  "*.h" -type f | grep -v '.svn'`; do
    grep -l "${varold}" ${file} >/dev/null;
    if [ $? -eq 0 ]; then
      echo "sed \"s#${varold}#${varnew}#g\" ${file} "
      sed "s#${varold}#${varnew}#g" ${file} > ${file}.tmp
      mv ${file}.tmp ${file}
#    else
#      echo "NOTHING TO BE DONE FOR ${file}"
    fi
  done

