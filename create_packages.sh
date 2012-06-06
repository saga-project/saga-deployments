#!/bin/bash 

type=$1
root=/tmp/saga/

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

  mkdir -p $root/src
  cd       $root/src

  echo     "svn co    $name"
  svn co   $url > /dev/null
  echo     "package   $name"
  make -C  $name rpm > /dev/null
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
function create_rpm()
{
  name=$1
  url=$2

  mkdir -p $root/src
  cd       $root/src

  echo     svn co    $name
  svn co   $url > /dev/null
  echo     package   $name
  make -C  $name rpm > /dev/null
  ls -la   $name/$name*.rpm
  echo     install   $name
  sudo rpm -i $name/$name*.x86_64.rpm
  

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
}




########################################################################
#
# main routine: 
#

# First, clean out remnants from earlier installs
sudo rm -rf $root


# then we just check the requested type, and invoke the correct 
# builder routine...
if test "$type" == "rpm"; then 
  do_rpm
  exit 0
fi

if test "$type" == "deb"; then
  do_deb
  exit 0
fi

printf "\n\tUsage: $0 <rpm|deb>\n\n"
exit -1




