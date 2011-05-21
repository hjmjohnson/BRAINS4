cmake_minimum_required(VERSION 2.8)

set(SPYDER_binary ${SPYDER_GLOBAL_ROOT}/SPYDER)

FILE(WRITE ${SPYDER_binary}/spyder_config.sh  "
#!/bin/bash -x

${SPYDER_GLOBAL_ROOT}/bin/easy_install-2.6 pip

${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  sphinx
${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  rope
${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  pyflakes
#pip install  IPython
${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  pylint
${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  readline
${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  nose
${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  DateUtils
#${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  pydicom
#${SPYDER_GLOBAL_ROOT}/bin/pip-2.6 install  pyxnat

cd ${SPYDER_binary}
if [ ! -f sip-4.12.2.tar.gz ]; then
  curl -O http://www.riverbankcomputing.co.uk/static/Downloads/sip4/sip-4.12.2.tar.gz
  tar -xzvf sip-4.12.2.tar.gz
fi
cd ${SPYDER_binary}/sip-4.12.2
${SPYDER_PYTHON_EXECUTABLE} configure.py
make
make install

cd ${SPYDER_binary}
if [ ! -f PyQt-mac-gpl-4.8.4.tar.gz ]; then
  curl -O http://www.riverbankcomputing.co.uk/static/Downloads/PyQt4/PyQt-mac-gpl-4.8.4.tar.gz
  tar -xzvf PyQt-mac-gpl-4.8.4.tar.gz
fi
cd PyQt-mac-gpl-4.8.4/
${SPYDER_PYTHON_EXECUTABLE} configure.py --qmake=/usr/bin/qmake
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

