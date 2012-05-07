
# host specific settings and modules
        module load git;        module load python;        module load globus;

# SAGA core settings
export SAGA_LOCATION=/lustre/scratch/proj/saga/saga//1.6/gcc-4.3.2/
export LD_LIBRARY_PATH=:/lustre/scratch/proj/saga/external/boost/1.44.0/gcc-4.3.2//lib/::/lustre/scratch/proj/saga/external/postgresql/9.0.2/gcc-4.3.2//lib/::/lustre/scratch/proj/saga/external/sqlite3/3.6.13/gcc-4.3.2//lib/::/lustre/scratch/proj/saga/saga//1.6/gcc-4.3.2//lib/:/lustre/scratch/proj/saga/external//python/2.7.1/gcc-4.3.2//lib/:$LD_LIBRARY_PATH
export PATH=:/lustre/scratch/proj/saga/external//python/2.7.1/gcc-4.3.2//bin/::/lustre/scratch/proj/saga/saga//1.6/gcc-4.3.2//bin/:$PATH

# SAGA Python bindings settings
export PATH=/lustre/scratch/proj/saga/external//python/2.7.1/gcc-4.3.2//bin/:$PATH
export PYTHONPATH=/lustre/scratch/proj/saga/saga//1.6/gcc-4.3.2//lib/python2.7/site-packages/:/lustre/scratch/proj/saga/saga//1.6/gcc-4.3.2//lib/python2.7/site-packages//BigJob-0.4.64-py2.7.egg/:/lustre/scratch/proj/saga/external//python/2.7.1/gcc-4.3.2//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/lustre/scratch/proj/saga/saga//1.6/gcc-4.3.2//lib/python2.7/site-packages//BigJob-0.4.64-py2.7.egg/:$PYTHONPATH

