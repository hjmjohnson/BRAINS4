cmake_minimum_required(VERSION 2.8)

set(SPYDER_binary ${SPYDER_GLOBAL_ROOT}/SPYDER)
if(APPLE)
  set(SPYDER_EASY_INSTALL_EXECUTABLE ${SPYDER_GLOBAL_ROOT}/Library/Framework/Python.framework/Versions/2.6/bin/easy_install-2.6)
  set(SPYDER_PYTHON_EXECUTABLE ${SPYDER_GLOBAL_ROOT}/Library/Framework/Python.framework/Versions/2.6/bin/python2.6)
else()
  set(SPYDER_EASY_INSTALL_EXECUTABLE ${SPYDER_GLOBAL_ROOT}/bin/easy_install-2.6)
  set(SPYDER_PYTHON_EXECUTABLE ${SPYDER_GLOBAL_ROOT}/bin/python2.6)
endif()

FILE(WRITE ${SPYDER_binary}/spyder_config.sh  "
#!/bin/bash -x


${SPYDER_EASY_INSTALL_EXECUTABLE} pip
${SPYDER_EASY_INSTALL_EXECUTABLE}  mercurial
${SPYDER_EASY_INSTALL_EXECUTABLE}  sphinx
${SPYDER_EASY_INSTALL_EXECUTABLE}  rope
${SPYDER_EASY_INSTALL_EXECUTABLE}  pyflakes
#pip install  IPython
${SPYDER_EASY_INSTALL_EXECUTABLE}  pylint
${SPYDER_EASY_INSTALL_EXECUTABLE}  readline
${SPYDER_EASY_INSTALL_EXECUTABLE}  nose
${SPYDER_EASY_INSTALL_EXECUTABLE}  DateUtils
#${SPYDER_EASY_INSTALL_EXECUTABLE}  pydicom
#${SPYDER_EASY_INSTALL_EXECUTABLE}  pyxnat

cd ${SPYDER_binary}
if [ ! -f sip-4.12.3.tar.gz ]; then
  curl -O http://www.riverbankcomputing.co.uk/static/Downloads/sip4/sip-4.12.3.tar.gz
  tar -xzvf sip-4.12.3.tar.gz
fi
cd ${SPYDER_binary}/sip-4.12.3
#${SPYDER_PYTHON_EXECUTABLE} configure.py
${SPYDER_PYTHON_EXECUTABLE} configure.py
make
make install

cd ${SPYDER_binary}
if [ ! -f PyQt-mac-gpl-4.8.4.tar.gz ]; then
  curl -O http://www.riverbankcomputing.co.uk/static/Downloads/PyQt4/PyQt-mac-gpl-4.8.4.tar.gz
  tar -xzvf PyQt-mac-gpl-4.8.4.tar.gz
fi
cd PyQt-mac-gpl-4.8.4/
${SPYDER_PYTHON_EXECUTABLE} configure.py --qmake=/usr/bin/qmake << EOF
yes
EOF
make -j 8 -k ; make
make install

cd ${SPYDER_binary}
if [ ! -f spyder-2.0.11.zip ]; then
  curl -O http://spyderlib.googlecode.com/files/spyder-2.0.11.zip
  unzip spyder-2.0.11.zip
fi
cd spyder-2.0.11
${SPYDER_PYTHON_EXECUTABLE} setup.py install

")

