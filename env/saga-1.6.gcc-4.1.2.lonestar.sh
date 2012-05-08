
# host specific settings and modules
      module load git;      module load python;      module load globus;

# SAGA core settings
export SAGA_LOCATION=/share1/projects/xsede/SAGA/saga//1.6/gcc-4.1.2/
export LD_LIBRARY_PATH=:/share1/projects/xsede/SAGA/external/boost/1.44.0/gcc-4.1.2//lib/::/share1/projects/xsede/SAGA/external/postgresql/9.0.2/gcc-4.1.2//lib/::/share1/projects/xsede/SAGA/external/sqlite3/3.6.13/gcc-4.1.2//lib/::/share1/projects/xsede/SAGA/saga//1.6/gcc-4.1.2//lib/:/share1/projects/xsede/SAGA/external//python/2.7.1/gcc-4.1.2//lib/:$LD_LIBRARY_PATH
export PATH=:/share1/projects/xsede/SAGA/external//python/2.7.1/gcc-4.1.2//bin/::/share1/projects/xsede/SAGA/saga//1.6/gcc-4.1.2//bin/:$PATH

# SAGA Python bindings settings
export PATH=/share1/projects/xsede/SAGA/external//python/2.7.1/gcc-4.1.2//bin/:$PATH
export PYTHONPATH=/share1/projects/xsede/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages/:/share1/projects/xsede/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages//BigJob-0.4.50-py2.7.egg/:/share1/projects/xsede/SAGA/external//python/2.7.1/gcc-4.1.2//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/share1/projects/xsede/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages//BigJob-0.4.50-py2.7.egg/:$PYTHONPATH

