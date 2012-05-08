
# host specific settings and modules
 

# SAGA core settings
export SAGA_LOCATION=/home/cctsg/install/saga/saga//1.6/gcc-4.4.6/
export LD_LIBRARY_PATH=:/home/cctsg/install/saga/external/boost/1.44.0/gcc-4.4.6//lib/::/home/cctsg/install/saga/external/postgresql/9.0.2/gcc-4.4.6//lib/::/home/cctsg/install/saga/external/sqlite3/3.6.13/gcc-4.4.6//lib/::/home/cctsg/install/saga/saga//1.6/gcc-4.4.6//lib/:/home/cctsg/install/saga/external//python/2.7.1/gcc-4.4.6//lib/:$LD_LIBRARY_PATH
export PATH=:/home/cctsg/install/saga/external//python/2.7.1/gcc-4.4.6//bin/::/home/cctsg/install/saga/saga//1.6/gcc-4.4.6//bin/:$PATH

# SAGA Python bindings settings
export PATH=/home/cctsg/install/saga/external//python/2.7.1/gcc-4.4.6//bin/:$PATH
export PYTHONPATH=/home/cctsg/install/saga/saga//1.6/gcc-4.4.6//lib/python2.7/site-packages/:/home/cctsg/install/saga/saga//1.6/gcc-4.4.6//lib/python2.7/site-packages//BigJob-0.4.63-py2.7.egg/:/home/cctsg/install/saga/external//python/2.7.1/gcc-4.4.6//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/home/cctsg/install/saga/saga//1.6/gcc-4.4.6//lib/python2.7/site-packages//BigJob-0.4.63-py2.7.egg/:$PYTHONPATH

