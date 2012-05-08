
# host specific settings and modules
        module load git;        module load python;        module load torque;

# SAGA core settings
export SAGA_LOCATION=/N/soft/SAGA/saga//1.6/gcc-4.1.2/
export LD_LIBRARY_PATH=:/N/soft/SAGA/external/boost/1.44.0/gcc-4.1.2//lib/::/N/soft/SAGA/external/postgresql/9.0.2/gcc-4.1.2//lib/::/N/soft/SAGA/external/sqlite3/3.6.13/gcc-4.1.2//lib/::/N/soft/SAGA/saga//1.6/gcc-4.1.2//lib/:/N/soft/SAGA/external//python/2.7.1/gcc-4.1.2//lib/:$LD_LIBRARY_PATH
export PATH=:/N/soft/SAGA/external//python/2.7.1/gcc-4.1.2//bin/::/N/soft/SAGA/saga//1.6/gcc-4.1.2//bin/:$PATH

# SAGA Python bindings settings
export PATH=/N/soft/SAGA/external//python/2.7.1/gcc-4.1.2//bin/:$PATH
export PYTHONPATH=/N/soft/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages/:/N/soft/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages//BigJob-0.4.49-py2.7.egg/:/N/soft/SAGA/external//python/2.7.1/gcc-4.1.2//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/N/soft/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages//BigJob-0.4.49-py2.7.egg/:$PYTHONPATH

