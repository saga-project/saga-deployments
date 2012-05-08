
# host specific settings and modules
         module load python;

# SAGA core settings
export SAGA_LOCATION=/gpfs/software/x86_64/el5/hotel/SAGA/saga//1.6/gcc-4.1.2/
export LD_LIBRARY_PATH=:/gpfs/software/x86_64/el5/hotel/SAGA/external/boost/1.44.0/gcc-4.1.2//lib/::/gpfs/software/x86_64/el5/hotel/SAGA/external/postgresql/9.0.2/gcc-4.1.2//lib/::/gpfs/software/x86_64/el5/hotel/SAGA/external/sqlite3/3.6.13/gcc-4.1.2//lib/::/gpfs/software/x86_64/el5/hotel/SAGA/saga//1.6/gcc-4.1.2//lib/:/gpfs/software/x86_64/el5/hotel/SAGA/external//python/2.7.1/gcc-4.1.2//lib/:$LD_LIBRARY_PATH
export PATH=:/gpfs/software/x86_64/el5/hotel/SAGA/external//python/2.7.1/gcc-4.1.2//bin/::/gpfs/software/x86_64/el5/hotel/SAGA/saga//1.6/gcc-4.1.2//bin/:$PATH

# SAGA Python bindings settings
export PATH=/gpfs/software/x86_64/el5/hotel/SAGA/external//python/2.7.1/gcc-4.1.2//bin/:$PATH
export PYTHONPATH=/gpfs/software/x86_64/el5/hotel/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages/:/gpfs/software/x86_64/el5/hotel/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages//BigJob-0.4.63-py2.7.egg/:/gpfs/software/x86_64/el5/hotel/SAGA/external//python/2.7.1/gcc-4.1.2//lib/2.7/site-packages/:$PYTHONPATH

# BigJob settings
export PYTHONPATH=/gpfs/software/x86_64/el5/hotel/SAGA/saga//1.6/gcc-4.1.2//lib/python2.7/site-packages//BigJob-0.4.63-py2.7.egg/:$PYTHONPATH

