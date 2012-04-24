#!/usr/bin/perl -w

BEGIN {
  use strict;
  use Data::Dumper;

  sub help (;$$);
}


################################################################################
#
#
#
sub help (;$$)
{
  my $ret = shift || 0;
  my $msg = shift || undef;

  if ( defined $msg )
  {
    print "\n\n    Error: $msg\n";
  }

  print <<EOT;

    $0 -h | --help  
            
       -l | --list  
       -d | --deploy 
       -c | --check all,job,file,... 
            
       -e | --experimental 
       -g | --git-push
       -f | --force 
       -n | --noop
       -V | --verbose 
            
       -t | --target   [all,host1,host2,...] 
       -m | --module   [all,module1,module2,...]
       -v | --version  [version]
       -p | --pass pw  
       -u | --user id  
            
       -r | --run_test [host] ['test args']
       -x | --execute  


  opem operandi:
    -h : this help message *duh*

  modus operandi:
    -l : list available target hosts
    -d : deploy version/modules on targets          (default:  off)
    -c : check csa deployment (unit tests)          (default:  off)
                                                               
  sapor operandi:                                            
    -e : experimental software deployment           (default:  off)
    -g : push results back into git                 (default:  off)
    -f : force re-deploy                            (default:  off)
    -n : run 'make -n' to show what *would* be done (default:  off)
    -V : echo commands to be run                    (default:  off)

  parameter operandi:
    -v : version to deploy (see csa_packages file)  (default: auto)
    -t : target hosts to deploy on                  (default:   "")
    -m : modules to deploy                          (default:   "")
    -p : git password                               (default:   "")
    -u : git user id                                (default:   "")

  interno operandi:
    -x : maintainance action, use with care!        (default:  off)
    -r : run a specific test on the *local* machine (default:  off)

EOT

  exit ($ret);
}
################################################################################

my $pwd         = `pwd`;  chomp ($pwd);
my $csa_root    = $0;

# remove file name from root
$csa_root =~ s/[^\/]+$//i;

# make root absolute
#$csa_root =~ s/^\.\/(.+)$/$pwd$1/io;
$csa_root =~ s/^\.\//$pwd\//i;

my $CSA_HOSTS   = "$csa_root/csa_hosts";
my $CSA_PACK    = "$csa_root/csa_packages";
my $CSA_TEST    = "$csa_root/csa_tests";
my $CSA_TESTEPS = "$csa_root/csa_test_eps";
my $ENV         = `which env`;  chomp ($ENV);
my $MAKE        = "make --no-print-directory -f make.saga.csa.mk ";
my $giturl_orig = "https://github.com/saga-project/saga-deployments.git";
my $giturl      = $giturl_orig;
my %csa_hosts   = ();
my %csa_packs   = ();
my %csa_tests   = ();

my @modules     = ();
my @hosts       = ();
my @tests       = ();

my $do_check    = 0;
my $do_deploy   = 0;
my $do_exe      = 0;
my $do_exp      = 0;
my $do_force    = 0;
my $do_list     = 0;
my $do_git_up   = 0;
my $run_test    = 0;

my $test_mode   = "";
my $test_info   = "";

my $noop        = 0;
my $verb        = 0;

my $exp         = "";
my $force       = "";
my $version     = "";
my $def_version = "";

my $gituser     = "";
my $gitpass     = "";

################################################################################



if ( ! scalar (@ARGV) )
{
  help (-1);
}

while (my $arg   = shift )
{
  if    ( $arg   =~ /^(-l|--list)$/o )
  {
    $do_list     = 1;
  }
  elsif ( $arg   =~ /^(-c|--check)$/o )
  {
    my $tmp      = shift || "job";
    @tests       = split (/,/, $tmp);
    $do_check    = 1;
    help (-2, "cannot parse checks '$tmp'") if $tmp =~ /^-/o; 
  }
  elsif ( $arg   =~ /^(-v|--version)$/o )
  {
    $version     = shift || "-";
    help (-2, "cannot parse version '$version'") if $version =~ /^-/o; 
  }
  elsif ( $arg   =~ /^(-t|--target|--targets|--targethosts)$/o )
  {
    my $tmp      = shift || "all";
    @hosts       = split (/,/, $tmp);
    help (-2, "cannot parse target '$tmp'") if $tmp =~ /^-/o; 
  }
  elsif ( $arg   =~ /^(-m|--module|--modules)$/o )
  {
    my $tmp      = shift || "all";
    @modules     = split (/,/, $tmp);
    help (-2, "cannot parse modules '$tmp'") if $tmp =~ /^-/o; 
  }
  elsif ( $arg   =~ /^(-u|--user)$/o )
  {
    $tmp         = shift || "-";
    help (-2, "cannot parse git user '$tmp'") if $tmp =~ /^-/o; 
    $gituser     = $tmp;
  }
  elsif ( $arg   =~ /^(-p|--pass)$/o )
  {
    $tmp         = shift || "-";
    help (-2, "cannot parse git pass '$tmp'") if $tmp =~ /^-/o; 
    $gitpass     = $tmp;
  }
  elsif ( $arg   =~ /^(-n|--nothing|--noop|--no)$/o )
  {
    $noop        = 1;
  }
  elsif ( $arg   =~ /^(-V|--verb|--verbose)$/o )
  {
    $verb        = 1;
  }
  elsif ( $arg   =~ /^(-e|--exp|--esa|--experimental)$/o )
  {
    $do_exp      = 1;
    $exp         = "CSA_ESA=true";
  }
  elsif ( $arg   =~ /^(-f|--force)$/o )
  {
    $do_force    = 1;
    $force       = "CSA_FORCE=true";
  }
  elsif ( $arg   =~ /^(-g|--git|--git-push)$/o )
  {
    $do_git_up   = 1;
  }
  elsif ( $arg   =~ /^(-r|--run|--run-test)$/o )
  {
    $run_test    = 1;
    $test_host   = shift || "-";
    $test_info   = shift || "-";

    help (-2, "cannot parse test host name '$test_host'")  if $test_host =~ /^-/o; 
    help (-2, "cannot parse test infos     '$test_info'" ) if $test_info =~ /^-/o; 
  }
  elsif ( $arg   =~ /^(-d|--deploy)$/o )
  {
    $do_deploy   = 1;
  }
  elsif ( $arg   =~ /^(-x|--execute)$/o )
  {
    $do_exe      = 1;
  }
  elsif ( $arg   =~ /^(-h|--help)$/o )
  {
    help (0);
  }
  elsif ( $arg   =~ /^-/o )
  {
    warn "WARNING: cannot parse command line flag '$arg'\n";
  }
  else
  {
    help (-1);
  }
}

if ( ! scalar (@hosts) )
{
  $hosts[0] = 'all';
}

if ( ! scalar (@modules) )
{
  $modules[0] = 'all';
}


if ( $do_git_up )
{
  if ( ! $gituser ) { help (-1, "-g requires -u") }
  if ( ! $gitpass ) { help (-1, "-g requires -p") }

  $giturl =~ s|^(https://)(.+)$|$1$gituser:$gitpass\@$2|io;
}

# {
#   if ( $arg =~ /^(-j|--job)$/io )
#   {
#    $do_test    = 1;
#    my $tmp     = shift || "all";
#    @middleware = split (/,/, $tmp);
#   }
# }

################################################################################
#
# read and parse csa packages file
#
{
  my $tmp = ();

  open   (TMP, "<$CSA_PACK") || die "ERROR  : cannot open '$CSA_PACK': $!\n";
  @tmp = <TMP>;
  close  (TMP);
  chomp  (@tmp);

  my $tmp_version = "";

  LINE_P:
  foreach my $tmp ( @tmp )
  {
    if ( $tmp =~ /^\s*(?:#.*)?$/io )
    {
      # skip comment lines and empty lines
    }
    elsif ( $tmp =~ /^\s*default\s*:\s*(\S+)\s*$/ )
    {
      $def_version = $1;
      next LINE_P;
    }
    elsif ( $tmp =~ /^\s*version\s*:\s*(\S+)\s*$/ )
    {
      $tmp_version = $1;
      $csa_packs {$tmp_version} = ();
      next LINE_P;
    }
    elsif ( $tmp =~ /^\s*(\S+)\s+(\S+)(?:\s+(\S.*?))?\s*$/io )
    {
      my $tmp_mod  = $1;
      my $tmp_src  = $2;
      my $tmp_tgt  = $3 || "";
      my @tmp_tgts = split (/[\s,]+/, $tmp_tgt);

      # if tgt's have only negatives, add star as default positive
      # if 'esa' is listed as target, only use this module in 'esa' mode
      my $has_positive = 0;
      my $use_module   = 1;

      foreach my $tgt ( @tmp_tgts )
      {
        if ( $tgt eq 'esa' )
        {
          if ( ! $do_exp )
          {
            $use_module = 0;
          }
        }
        elsif ( $tgt !~ /^\!/o )
        {
          $has_positive = 1;
        }
      }

      if ( grep (/^esa$/, @tmp_tgts) )
      {
        # remove 'esa' from targets
        @tmp_tgts = grep (!/^esa$/, @tmp_tgts);

      }

      if ( 0 == $has_positive )
      {
        splice (@tmp_tgts, 0, 0, '*');
      }


      if ( $use_module )
      {
        push ( @{$csa_packs{$tmp_version}{'modules'}}, {'name' => $tmp_mod,
                                                        'src'  => $tmp_src, 
                                                        'tgt'  => \@tmp_tgts});
      }
      else
      {
        # print "ignore esa module $tmp_mod\n";
      }
    }
    else
    {
      die "WARNING: Cannot parse csa package line '$tmp'\n";
    }
  }
}


################################################################################
#
# fall back to default version if needed
#
{
  if ( $version eq "" )
  {
    $version = $def_version;
    # print "no version specified - using default version: $version\n";
  }

  if ( ! exists $csa_packs{$version} )
  {
    print " -- error: undefined version '$version'\n";
    exit -1;
  }
}

################################################################################
#
# read and parse csa host file
#
{
  my $tmp = ();

  open   (TMP, "<$CSA_HOSTS") || die "ERROR  : cannot open '$CSA_HOSTS': $!\n";
  @tmp = <TMP>;
  close  (TMP);
  chomp  (@tmp);

  foreach my $tmp ( @tmp )
  {
    if ( $tmp =~ /^\s*(?:#.*)?$/io )
    {
      # skip comment lines and empty lines
    }
    elsif ( $tmp =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+'((?:ssh|gsissh)\s*?.*?)'\s*(?:\s+(\S+?)?\s+(\S+?)?)\s*$/io )
    {
      my $host   = $1;
      my $fqhn   = $2;
      my $path   = $3;
      my $access = $4;
      my $local  = $5;
      my $remote = $6;

      if ( exists ( $csa_hosts{$host} ) )
      {
        warn "WARNING: duplicated csa host '$host'\n"
      }

      $csa_hosts {$1}{'fqhn'}   = $fqhn;
      $csa_hosts {$1}{'path'}   = $path;
      $csa_hosts {$1}{'access'} = $access;
      $csa_hosts {$1}{'local'}  = $local;
      $csa_hosts {$1}{'remote'} = $remote;
    }
    else
    {
      warn "WARNING: Cannot parse csa host line '$tmp'\n";
    }
  }
}


if ( grep (/all/, @modules) )
{
  @modules = grep (!/all/, @modules);
  foreach my $entry ( @{$csa_packs{$version}{'modules'}} )
  {
    push (@modules, $entry->{'name'});
  }
}

################################################################################
#
# modules need to be re-ordered, as we assume that the order given in the
# csa_packages file is significant (i.e. resolves dependenncies).
# FWIW, this procedure also weeds out duplicates.
#
# TODO: for each module, we should also include all modules listed before 
# that one, to actually satisfy not specified dependencies...
#
{
  my  @tmp = @modules;
  @modules = ();

  foreach my $entry ( @{$csa_packs{$version}{'modules'}} )
  {
    my $name = $entry->{'name'};
    if ( grep (/^$name$/, @tmp) )
    {
      push (@modules, $entry);
    }
  }
}


if ( grep (/all/, @hosts) )
{
  @hosts = sort keys ( %csa_hosts );
}

if ( ! scalar (@hosts) )
{
  if ( $do_check || $do_deploy || $do_exe )
  {
    die "no targets given\n";
  }
}

my $modstring = "";
foreach my $entry ( @modules )
{
  $modstring .= "$entry->{name} ";
}

my $checkstring = $do_check;
if ( $do_check )
{
  $checkstring .= " :";
  foreach my $check ( @tests )
  {
    $checkstring .= " $check";
  }
}


################################################################################
#
# print summery of actions and parameters
#
#if ( ! $run_test )
{
  print <<EOT;
+------------------------------------------------------------------------------------------------------
|
| csa root      : $csa_root
|
| targets       : @hosts
| modules       : $modstring
| version       : $version
|
| exec          : $do_exe
| deploy        : $do_deploy
| check         : $checkstring
|
| force         : $do_force
| experimental  : $do_exp
|
| git           : $giturl_orig
|
+------------------------------------------------------------------------------------------------------
EOT
}


################################################################################
#
# list mode simply lists the known hosts
#
if ( $do_list )
{
  print "\n";
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  printf "| %-15s | %-40s | %-35s |\n", "host", "fqhn", "path";
  print "+-----------------+------------------------------------------+-------------------------------------+\n";

  foreach my $host ( sort keys (%csa_hosts) )
  {
    if ( ! exists $csa_hosts{$host} )
    {
      warn "WARNING: Do not know how to handle host '$host'\n";
    }
    else
    {
      my $fqhn = $csa_hosts{$host}{'fqhn'};
      my $path = $csa_hosts{$host}{'path'};
    
      printf "| %-15s | %-40s | %-35s |\n", $host, $fqhn, $path;
    }
  }
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  print "\n";
}


################################################################################
#
# for each csa host, execute some maintainance op
#
if ( $do_exe )
{
  print "\n";
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  printf "| %-15s | %-40s | %-35s |\n", "host", "fqhn", "path";

  foreach my $host ( @hosts )
  {
    if ( ! exists $csa_hosts{$host} )
    {
      print " -- warning: unknown host '$host'\n";
    }
    else
    {
      my $fqhn   = $csa_hosts{$host}{'fqhn'};
      my $path   = $csa_hosts{$host}{'path'};
      my $access = $csa_hosts{$host}{'access'};
      my $CPP    = "gcc-`$path/csa/cpp_version`";

    # my $exe    = "rm -rf $path/csa";
    # my $exe    = "chmod -R a+rX $path/";
    # my $exe    = "rm -v  $path/saga/$version/$CPP/share/saga/saga_adaptor_ssh_job.ini";
    # my $exe    = "rm -rf $path/saga/$version/$CPP/lib/python*/site-packages/bigjob* " .
    #              "       $path/saga/$version/$CPP/lib/python*/site-packages/saga/bigjob*";
    # my $exe    = "rm -rv $path/README.saga-$version.$CPP.$host" .
    #              "       $path/csa/doc/README.saga-$version.$CPP.$host" .
    #              "       $path/saga/$version/$CPP/share/saga/config/python.m4" .
    #              "       $path/saga/$version/$CPP/lib/python*";
    # my $exe    = "eval `grep \"  export\" $path/README.saga-1.6.*.$host` ; " .
    #              "python -c \"import saga ; print saga ; import bigjob ; print bigjob\"";
    # my $exe    = "rm -rv $path/src/saga-client-bigjob-*" .
    #              "       $path/saga/$version/$CPP/lib/python*/site-packages/* " .
    #              "       $path/external/python/2.7.1/$CPP/lib/python*/site-packages/*" .
    #              "       $path/saga/$version/$CPP/share/saga/config/python.m4" ;
    # my $exe    = "rm -rv $path/csa/{doc,mod,test}/ ; " .
    #              "cd     $path/     ; test -d csa || git co https://git.cct.lsu.edu/repos/saga-projects/deployment/tg-csa csa ; " .
    #              "cd     $path/csa/ ; git pull";
    # my $exe    = "rm -rv $path/src/saga-adaptor-ssh-*";
    # my $exe    = "rm -rv $path/csa/";
      my $exe    = "git --version ; module load git ; git --version";

      print "+-----------------+------------------------------------------+-------------------------------------+\n";
      printf "| %-15s | %-40s | %-35s |\n", $host, $fqhn, $path;
      print "+-----------------+------------------------------------------+-------------------------------------+\n";

      my $cmd = "$access $fqhn '$exe'";

      print " -- $cmd\n" if ( $verb || $noop );
      
      unless ( $noop ) { 
        if ( 0 != system ($cmd) ) {
          print " -- error: cannot run $cmd\n";
        }
      }
    }
  }
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  print "\n";

}


################################################################################
#
# deploy some modules on some targets
#
if ( $do_deploy )
{
  # ! check, so do the real deployment

  print "\n";
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  printf "| %-15s | %-40s | %-35s |\n", "host", "fqhn", "path";

  foreach my $host ( @hosts )
  {
    if ( ! exists $csa_hosts{$host} )
    {
      warn " -- warning: unknown host '$host'\n";
    }
    else
    {
      my $fqhn   = $csa_hosts{$host}{'fqhn'};
      my $path   = $csa_hosts{$host}{'path'};
      my $access = $csa_hosts{$host}{'access'};

      print "+-----------------+------------------------------------------+-------------------------------------+\n";
      printf "| %-15s | %-40s | %-35s |\n", $host, $fqhn, $path;
      print "+-----------------+------------------------------------------+-------------------------------------+\n";

      foreach my $entry ( @modules )
      {
        my $mod_name = $entry->{'name'};
        my $mod_src  = $entry->{'src'};
        my @mod_tgts = @{$entry->{'tgt'}};

        print " -- build $mod_name ($version) (@mod_tgts)\n";

        if ( ! grep (/\!$host/, @mod_tgts)    &&
             ( grep (/\*/,      @mod_tgts) ||
               grep (/$host/,   @mod_tgts) )  )
        {
          my $cmd = "$access $fqhn 'mkdir -p $path;" .
                                   " cd $path && test -d csa && (cd csa && git pull) || git clone $giturl csa;". 
                                   " $ENV" .
                                   " CSA_HOST=$host" .
                                   " CSA_LOCATION=$path" .
                                   " CSA_SAGA_VERSION=$version" .
                                   " CSA_SAGA_SRC=\"$mod_src\"" .
                                   " CSA_SAGA_TGT=$mod_name-$version" .
                                   " $exp $force" .
                                   " $MAKE -C $path/csa/ $mod_name ' " ;

          print " -- deploy: $cmd\n" if ( $verb || $noop );
          
          unless ( $noop ) {
            if ( 0 != system ($cmd) ) {
              print " -- error: cannot deploy $mod_name on $host\n";
            }
          }

          if ( $mod_name eq "documentation" )
          {
            if ( $do_git_up )
            {
              my $cmd = "$access $fqhn 'cd $path/csa/ &&" .
                                       " git add -f doc/README.saga-$version.*.$host* &&" .
                                       " git add -f mod/module.saga-$version.*.$host* &&" .
                                       " git add -f env/saga-$version.*.$host*.sh &&" .
                                       " git commit -am \"automated update\" &&" .
                                       " git push $giturl ' " ;

              print " -- deploy: $cmd\n" if ( $verb || $noop );
              
              unless ( $noop ) {
                if ( 0 != system ($cmd) ) {
                  print " -- error: cannot commit documentation\n";
                }
              }
            }
          }
          print "\n";
        }
        else
        {
          print "module $mod_name disabled on $host\n";
        }
      }
    }
  }
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  print "\n";
}



################################################################################
#
# run the test suite on the target hosts
#
# running checks requires security setup to be in place.  That is required even
# for some local checks (local ssh etc).  
#
# We expect ssh access to be available already.   For gsissh and gram, we  copy
# the X509 from the local host (running $0) to the target host (running the
# test).  We store the cert in $CSA_LOCATION/csa/test/x509_test.pem, and set
# X509_USER_PROXY to point to it.  Note that this does not check the SAGA
# contexts.
#
if ( $do_check )
{
  print "\n";
  print "+-----------------+------------------------------------------+-------------------------------------+\n";
  printf "| %-15s | %-40s | %-35s |\n", "host", "fqhn", "path";

  foreach my $host ( @hosts )
  {
    if ( ! exists $csa_hosts{$host} )
    {
      print " -- warning: unknown host '$host'\n";
    }
    else
    {
      my $fqhn   = $csa_hosts{$host}{'fqhn'};
      my $path   = $csa_hosts{$host}{'path'};
      my $access = $csa_hosts{$host}{'access'};

      print "+-----------------+------------------------------------------+-------------------------------------+\n";
      printf "| %-15s | %-40s | %-35s |\n", $host, $fqhn, $path;
      print "+-----------------+------------------------------------------+-------------------------------------+\n";

      {
        # copy the x509 proxy if available
        {
          my $uid = `id -u`;
          chomp ($uid);

          my $proxy = "/tmp/x509up_u$uid";
          if ( -r $proxy )
          {
            my $tgt = "$path/csa/test/x509_test.pem";
            my $cmd = "cat $proxy | $access $fqhn 'cat > $tgt ; chmod 0600 $tgt'";

            print " -- check : $cmd\n" if ( $verb || $noop );

            unless ( $noop ) {
              if ( 0 != system ($cmd) ) {
                print "WARNING: copy x509 proxy failed.\n";
              }
            }
          }
        }

        # running the test suite ('make test')
        { 
          my $tmp = join (',', @tests);
          my $cmd = "$access $fqhn 'mkdir -p $path;" .
                    " cd $path && test -d csa && (cd csa && git pull) || git clone $giturl csa;". 
                    " $ENV" .
                    " CSA_HOST=$host" .
                    " CSA_LOCATION=$path" .
                    " CSA_SAGA_VERSION=$version" .
                    " CSA_TESTS=$tmp" .
                    " $exp" .
                    " $MAKE -C $path/csa/ test ' " ;

          print " -- check: $cmd\n" if ( $verb || $noop );
          
          unless ( $noop ) {
            if ( 0 != system ($cmd) ) {
              print " -- error: cannot run csa checks\n";
            }
          }
        }
      }

      if ( $do_git_up )
      {
        my $cmd = "$access $fqhn ' cd $path/csa/ && " .
                                 " git add -f test/test.saga-$version.*.$host* && " .
                                 " git commit -am \"automated update\" && " .
                                 " git push $giturl ' " ;

        print " -- check: $cmd\n" if ( $verb || $noop );
        
        unless ( $noop ) {
          if ( 0 != system ($cmd) ) {
            print " -- error: cannot commit csa checks\n";
          }
        }
      }
    }
  }
  print "\n";
}



################################################################################
#
# run a single test on localhost
#
# we assume ssh keys to be in place, and point X509_USER_PROXY to
# $CSA_LOCATION/csa/test/x509_test.pem, if that exists
#
if ( $run_test )
{
  my @tests      = ();
  my $test_types = ();

  my $x509       = "$csa_root/test/x509_test.pem";

  if ( -r $x509 )
  {
    $ENV{'X509_USER_PROXY'} = $x509;
    print "using $x509 as X509_USER_PROXY\n";
  }

  # we now collect all tests to be run from the tests struct.  We run all tests
  # of the given type, for the given host
  {
    open   (TMP, "<$CSA_TESTEPS") || die "ERROR  : cannot open '$CSA_HOSTS': $!\n";
    @tmp = <TMP>;
    close  (TMP);
    chomp  (@tmp);

    @test_infos = split (/,/, $test_info );

    foreach my $line ( @tmp )
    {
      if ( $line =~ /^\s*(?:#.*)?$/io )
      {
        # skip comment lines and empty lines
      }
      elsif ( $line =~
        /^\s*(\S+)\s+(job|file|core|bigjob)\s+(\S+)\s+(.*?)\s*$/io )
      {
        my $host = $1;
        my $type = $2;
        my $name = $3;
        my $info = $4;

        if ( $host eq $test_host ||
             $host eq '*'        )
        {
          if ( grep ($type,    @test_infos) ||
               grep (/^all$/,  @test_infos) )
          {
            $info =~ s/\s+/ /iog;

            my %test = ('host' => $test_host, 
                        'type' => $type,
                        'name' => $name, 
                        'info' => $info
                        );
            push (@tests, \%test);
          }
        }
      }
    }
  }

  # print Dumper \@tests;

  my $tests_ok   = 0;
  my $tests_nok  = 0;

  my $out        = "";
  my $err        = "";

  printf "+-%-12s-+-%-7s-+-%-10s-+-%-55s-+-----+ \n", '-'x12, '-'x7,  '-'x10, '-'x55;
  printf "| %-12s | %-7s | %-10s | %-55s | res | \n", 'host', 'type', 'name', 'info';
  printf "+-%-12s-+-%-7s-+-%-10s-+-%-55s-+-----+ \n", '-'x12, '-'x7,  '-'x10, '-'x55;
  
  foreach my $test ( @tests)
  {
    my $host = $test->{'host'};
    my $type = $test->{'type'};
    my $name = $test->{'name'};
    my $info = $test->{'info'};

    my $cmd  = "bash -c '. $csa_root/../env.saga.sh ; python $csa_root/test/csa_test_$type.py $info true 2>&1'";

    print " -- test: $cmd\n" if ( $verb || $noop );
        
    my $out = "";
    unless ( $noop ) {
      $out  = qx{$cmd};
    }

    if ( ! defined $out )
    {
      $out = "could not run test - [FAILURE]";
    }

    my $msg = $out;

    $out =~ s/^(.*)\s*\[SUCCESS\][\s\n]?$/$1/is;
    $out =~ s/^(.*)\s*\[FAILURE\][\s\n]?$/$1/is;

    $msg =~ s/^.*\s*\[SUCCESS\][\s\n]?$/ ok/iso;
    $msg =~ s/^.*\s*\[FAILURE\][\s\n]?$/nok/iso;


    printf "| %-12s | %-7s | %-10s | %-55s | %3s |\n", $host, $type, $name, $info, $msg;

    if ( $msg eq ' ok' )
    {
      $tests_ok++;
    }
    else
    {
      $tests_nok++;

      $err .= sprintf "| %-99s |\n", " Error for $host / $type / $name / $info : ";
      foreach my $line ( split (/\n/, $out) )
      {
        $err .= sprintf "| %-99s |\n", $line;
      }
      $err .= sprintf "+-%-12s-+-%-7s-+-%-10s-+-%-55s-+-----+\n", '-'x12, '-'x7, '-'x10, '-'x55;
    }
  }


  printf "+-%-12s-+-%-7s-+-%-10s-+-%-55s-+-----+ \n", '-'x12, '-'x7, '-'x10, '-'x55;
  print  $err;
  printf "| %-99s |\n", "ok : $tests_ok";
  printf "| %-99s |\n", "nok: $tests_nok";
  printf "+-%-12s-+-%-7s-+-%-10s-+-%-55s-+-----+ \n", '-'x12, '-'x7, '-'x10, '-'x55;
}

