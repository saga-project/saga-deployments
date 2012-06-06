#!/bin/bash 

type=$1
root=/tmp/saga/

rm    -rf $root || exit -1
mkdir -p  $root || exit -1
cd        $root || exit -1

########################################################################
#
# create a single rpm
#
# arg 1: name of package
# arg 2: svn repos url
#
function create_rpm()
{
  name=$1
  url=$2

  echo     "svn co    $name"
  svn co   $url       $name
  echo     "package   $name"
  make -C  $name rpm 
  ls -la   $name/$name*.rpm
  echo     "install   $name"
  sudo rpm -i $name/$name*.x86_64.rpm
}



########################################################################
#
# create a single deb
#
# arg 1: name of package
# arg 2: svn repos url
#
function create_deb()
{
  name=$1
  url=$2

  echo     svn co    $name
  svn co   $url      $name
  echo     package   $name
  make -C  $name deb 
  ls -la   $name/$name*.deb
  echo     install   $name
  sudo dpkg -i $name/$name*.deb
}



########################################################################
#
# create all rpm packages
#
function do_rpm()
{
  sudo rpm -e `rpm -qa | grep saga`
  echo "creating  rpm packages"

  create_rpm saga-core            https://svn.cct.lsu.edu/repos/saga/core/branches/egi-release
  create_rpm saga-bindings-python https://svn.cct.lsu.edu/repos/saga/bindings/python/branches/egi-release
  create_rpm saga-adaptors-x509   https://svn.cct.lsu.edu/repos/saga-adaptors/x509/branches/egi-release
  create_rpm saga-adaptors-globus https://svn.cct.lsu.edu/repos/saga-adaptors/globue/branches/egi-release
  create_rpm saga-adaptors-ssh    https://svn.cct.lsu.edu/repos/saga-adaptors/ssh/branches/egi-release
  create_rpm saga-adaptors-bes    https://svn.cct.lsu.edu/repos/saga-adaptors/bes/branches/egi-release
  create_rpm saga-adaptors-glite  https://svn.cct.lsu.edu/repos/saga-adaptors/glite/branches/egi-release

  mv $root/*.rpm $root/
  mv $root/*.tgz $root/
}



########################################################################
#
# create all deb packages
#
function do_deb ()
{
  sudo dpkg --purge `dpkg -l | grep saga | cut -f 2,3 -d ' '`
  echo "creating  deb packages"

  create_deb saga-core            https://svn.cct.lsu.edu/repos/saga/core/branches/egi-release
  create_deb saga-bindings-python https://svn.cct.lsu.edu/repos/saga/bindings/python/branches/egi-release
  create_deb saga-adaptors-x509   https://svn.cct.lsu.edu/repos/saga-adaptors/x509/branches/egi-release
  create_deb saga-adaptors-globus https://svn.cct.lsu.edu/repos/saga-adaptors/globue/branches/egi-release
  create_deb saga-adaptors-ssh    https://svn.cct.lsu.edu/repos/saga-adaptors/ssh/branches/egi-release
  create_deb saga-adaptors-bes    https://svn.cct.lsu.edu/repos/saga-adaptors/bes/branches/egi-release
  create_deb saga-adaptors-glite  https://svn.cct.lsu.edu/repos/saga-adaptors/glite/branches/egi-release

  mv $root/*.deb $root/
  mv $root/*.tgz $root/
}




########################################################################
#
# main routine: 
#
# then we just check the requested type, and invoke the correct 
# builder routine...
if test "$type" == "rpm"; then 
  do_rpm || exit -1
  exit 0
fi

if test "$type" == "deb"; then
  do_deb || exit -1
  exit 0
fi

printf "\n\tUsage: $0 <rpm|deb>\n\n"
exit -1




