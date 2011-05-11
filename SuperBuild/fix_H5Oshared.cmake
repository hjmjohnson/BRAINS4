file(READ ${fixfile} code)

string(REPLACE "static H5_inline " "" code "${code}")

file(WRITE ${fixfile} "${code}")