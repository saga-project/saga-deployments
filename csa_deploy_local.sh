#!/bin/sh

if test $# -ne 1; then
  echo 
  echo "    usage: $0 <prefix>"
  echo 
  exit 1
fi

prefix=$1

export CSA_HOST=localhost
export CSA_LOCATION=$prefix
export CSA_SAGA_VERSION=1.6

mkdir -p $CSA_LOCATION
mkdir -p $CSA_LOCATION/csa/
mkdir -p $CSA_LOCATION/csa/env/
mkdir -p $CSA_LOCATION/csa/doc/
mkdir -p $CSA_LOCATION/csa/mod/

cp csa_hostenv       $CSA_LOCATION/csa/
cp env/saga-env.stub $CSA_LOCATION/csa/env/
cp doc/README.stub   $CSA_LOCATION/csa/doc/
cp mod/module.stub   $CSA_LOCATION/csa/mod/

env CSA_SAGA_SRC="none"                                                                    CSA_SAGA_TGT=externals-1.6              make -f make.saga.csa.mk externals 
env CSA_SAGA_SRC="https://svn.cct.lsu.edu/repos/saga/core/branches/egi-release"            CSA_SAGA_TGT=saga-core-1.6              make -f make.saga.csa.mk saga-core 
env CSA_SAGA_SRC="https://svn.cct.lsu.edu/repos/saga/bindings/python/branches/egi-release" CSA_SAGA_TGT=saga-binding-python-1.6    make -f make.saga.csa.mk saga-binding-python 
env CSA_SAGA_SRC="https://svn.cct.lsu.edu/repos/saga-adaptors/x509/branches/egi-release"   CSA_SAGA_TGT=saga-adaptor-x509-1.6      make -f make.saga.csa.mk saga-adaptor-x509 
env CSA_SAGA_SRC="https://svn.cct.lsu.edu/repos/saga-adaptors/globus/branches/egi-release" CSA_SAGA_TGT=saga-adaptor-globus-1.6    make -f make.saga.csa.mk saga-adaptor-globus 
env CSA_SAGA_SRC="https://github.com/saga-project/saga-adaptors-ssh.git/trunk/"            CSA_SAGA_TGT=saga-adaptor-ssh-1.6       make -f make.saga.csa.mk saga-adaptor-ssh 
env CSA_SAGA_SRC="https://svn.cct.lsu.edu/repos/saga-adaptors/torque/trunk"                CSA_SAGA_TGT=saga-adaptor-torque-1.6    make -f make.saga.csa.mk saga-adaptor-torque 
env CSA_SAGA_SRC="https://svn.cct.lsu.edu/repos/saga-projects/applications/mandelbrot"     CSA_SAGA_TGT=saga-client-mandelbrot-1.6 make -f make.saga.csa.mk saga-client-mandelbrot 
env CSA_SAGA_SRC="https://github.com/saga-project/BigJob/trunk/"                           CSA_SAGA_TGT=saga-client-bigjob-1.6     make -f make.saga.csa.mk saga-client-bigjob 
env CSA_SAGA_SRC="none"                                                                    CSA_SAGA_TGT=documentation-1.6          make -f make.saga.csa.mk documentation 


