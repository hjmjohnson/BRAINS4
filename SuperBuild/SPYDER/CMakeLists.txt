

FILE(WRITE ${SPYDER_binary}/spyder_config.sh  "
#!/bin/bash

${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade sphinx
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade rope
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade pyflakes
#pip install --upgrade IPython
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade pylint
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade readline
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade nose
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade DateUtils
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade pydicom
${CMAKE_CURRENT_BINARY_DIR}/bin/pip-2.6 install --upgrade pyxnat

cd ${SPYDER_binary}
curl -O http://www.riverbankcomputing.co.uk/static/Downloads/sip4/sip-4.12.2.tar.gz
tar -xzvf sip-4.12.2.tar.gz
cd ${SPYDER_binary}/sip-4.12.2
${SPYDER_PYTHON_EXECUTABLE} configure.py
make
make install

cd ${SPYDER_binary}
curl -O http://www.riverbankcomputing.co.uk/static/Downloads/PyQt4/PyQt-mac-gpl-4.8.4.tar.gz
tar -xzvf PyQt-mac-gpl-4.8.4.tar.gz
cd PyQt-mac-gpl-4.8.4/
${SPYDER_PYTHON_EXECUTABLE} configure.py --qmake=/usr/bin/qmake
make -j 8 -k ; make
make install

cd ${SPYDER_binary}
curl -O http://spyderlib.googlecode.com/files/spyder-2.0.11.zip
unzip spyder-2.0.11.zip
cd spyder-2.0.11
${SPYDER_PYTHON_EXECUTABLE} setup.py install


")

