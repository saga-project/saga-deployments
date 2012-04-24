
# host specific settings and modules
 

# SAGA core settings
export SAGA_LOCATION=/home/amerzky/csa/saga//1.6/gcc-4.4.3/
export LD_LIBRARY_PATH=:/home/amerzky/csa/external/boost/1.44.0/gcc-4.4.3//lib/::/home/amerzky/csa/external/postgresql/9.0.2/gcc-4.4.3//lib/::/home/amerzky/csa/external/sqlite3/3.6.13/gcc-4.4.3//lib/::/home/amerzky/csa/saga//1.6/gcc-4.4.3//lib/:/home/amerzky/csa/external//python/2.7.1/gcc-4.4.3//lib/:$LD_LIBRARY_PATH
export PATH=:/home/amerzky/csa/external//python/2.7.1/gcc-4.4.3//bin/::/home/amerzky/csa/saga//1.6/gcc-4.4.3//bin/:$PATH

# SAGA Python bindings settings
export PATH=/home/amerzky/csa/external//python/2.7.1/gcc-4.4.3//bin/:$PATH
export PYTHONPATH=/home/amerzky/csa/saga//1.6/gcc-4.4.3//lib/python2.7/site-packages/:/home/amerzky/csa/saga//1.6/gcc-4.4.3//lib/python2.7/site-packages//BigJob-0.4.61-py2.7.egg/:/home/amerzky/csa/external//python/2.7.1/gcc-4.4.3//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/home/amerzky/csa/saga//1.6/gcc-4.4.3//lib/python2.7/site-packages//BigJob-0.4.61-py2.7.egg/:$PYTHONPATH

