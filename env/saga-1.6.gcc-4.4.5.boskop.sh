
# host specific settings and modules
 

# SAGA core settings
export SAGA_LOCATION=/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/saga//1.6/gcc-4.4.5/
export LD_LIBRARY_PATH=:/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external/boost/1.44.0/gcc-4.4.5//lib/::/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external/postgresql/9.0.2/gcc-4.4.5//lib/::/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external/sqlite3/3.6.13/gcc-4.4.5//lib/::/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/saga//1.6/gcc-4.4.5//lib/:/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external//python/2.7.1/gcc-4.4.5//lib/:$LD_LIBRARY_PATH
export PATH=:/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external//python/2.7.1/gcc-4.4.5//bin/::/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/saga//1.6/gcc-4.4.5//bin/:$PATH

# SAGA Python bindings settings
export PATH=/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external//python/2.7.1/gcc-4.4.5//bin/:$PATH
export PYTHONPATH=/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages/:/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages//BigJob-0.4.63-py2.7.egg/:/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/external//python/2.7.1/gcc-4.4.5//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/home/merzky/projects/saga/svn-saga-projects/deployment/tg-csa/deploy/saga//1.6/gcc-4.4.5//lib/python2.7/site-packages//BigJob-0.4.63-py2.7.egg/:$PYTHONPATH

