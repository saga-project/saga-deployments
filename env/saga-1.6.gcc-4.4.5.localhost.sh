
# host specific settings and modules
 

# SAGA core settings
export SAGA_LOCATION=/tmp/csa/install/saga//1.6/gcc-4.4.5/
export LD_LIBRARY_PATH=:/tmp/csa/install/external/boost/1.44.0/gcc-4.4.5//lib/::/tmp/csa/install/external/postgresql/9.0.2/gcc-4.4.5//lib/::/tmp/csa/install/external/sqlite3/3.6.13/gcc-4.4.5//lib/::/tmp/csa/install/saga//1.6/gcc-4.4.5//lib/:/tmp/csa/install/external//python/2.7.1/gcc-4.4.5//lib/:$LD_LIBRARY_PATH
export PATH=:/tmp/csa/install/external//python/2.7.1/gcc-4.4.5//bin/::/tmp/csa/install/saga//1.6/gcc-4.4.5//bin/:$PATH

# SAGA Python bindings settings
export PATH=/tmp/csa/install/external//python/2.7.1/gcc-4.4.5//bin/:$PATH
export PYTHONPATH=/tmp/csa/install/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages/:/tmp/csa/install/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages///:/tmp/csa/install/external//python/2.7.1/gcc-4.4.5//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/tmp/csa/install/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages///:$PYTHONPATH

