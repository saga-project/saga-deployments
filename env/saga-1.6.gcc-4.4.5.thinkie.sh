
# host specific settings and modules
  export GLOBUS_LOCATION=/usr/local/packages/globus-5.0.2
  export LD_LIBRARY_PATH=$GLOBUS_LOCATION/lib/:$LD_LIBRARY_PATH
  export PATH=$GLOBUS_LOCATION/bin/:$PATH


# SAGA core settings
export SAGA_LOCATION=/home/merzky/test/csa/saga//1.6/gcc-4.4.5/
export LD_LIBRARY_PATH=:/home/merzky/test/csa/external/boost/1.44.0/gcc-4.4.5//lib/::/home/merzky/test/csa/external/postgresql/9.0.2/gcc-4.4.5//lib/::/home/merzky/test/csa/external/sqlite3/3.6.13/gcc-4.4.5//lib/::/home/merzky/test/csa/saga//1.6/gcc-4.4.5//lib/:/home/merzky/test/csa/external//python/2.7.1/gcc-4.4.5//lib/:$LD_LIBRARY_PATH
export PATH=:/home/merzky/test/csa/external//python/2.7.1/gcc-4.4.5//bin/::/home/merzky/test/csa/saga//1.6/gcc-4.4.5//bin/:$PATH

# SAGA Python bindings settings
export PATH=/home/merzky/test/csa/external//python/2.7.1/gcc-4.4.5//bin/:$PATH
export PYTHONPATH=/home/merzky/test/csa/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages/:/home/merzky/test/csa/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages//BigJob-0.4.60-py2.7.egg/:/home/merzky/test/csa/external//python/2.7.1/gcc-4.4.5//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/home/merzky/test/csa/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages//BigJob-0.4.60-py2.7.egg/:$PYTHONPATH

