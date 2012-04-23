
# this makefile supports the CSA deployment procedure on different DCIs.  
# It requires the environment variable CSA_LOCATION to be set (will complain
# otherwise), and needs 'wget', 'svn co', and the usual basic SAGA compilation
# requirements (compiler, linker etc.).  Boost, sqlite3 and postgresql are
# installed in external/.  We also expect the SAGA version to be set as
# CSA_SAGA_VERSION, which should be available as release tag in svn.  Otherwise,
# we are going to install trunk.   Finally, CSA_SAGA_CHECK will not install
# anything, but print status information for an existing deployment.
#
# NOTE: this makefile should only be used in conjunction with csa_deploy.pl, 
# and won't be of much use otherwise...
#

ifndef CSA_LOCATION
 $(error CSA_LOCATION not set - should point to the CSA space allocated on this TG machine)
endif

# get rid of symlinks in CSA_LOCATION
CSA_TMP_LOCATION  = $(shell cd $(CSA_LOCATION) && pwd -P)
CSA_LOCATION     := $(CSA_TMP_LOCATION)

ifdef CSA_ESA
	CSA_ROOT        = $(CSA_LOCATION)/csa/
	CSA_EXT_DIR     = $(CSA_LOCATION)/external/
	CSA_SRC_DIR     = $(CSA_LOCATION)/src/
	CSA_TGT_DIR     = $(CSA_LOCATION)/saga-esa/
	CSA_SUFFIX      = .esa
	CSA_SUBDIR      = saga-esa
else
	CSA_ROOT        = $(CSA_LOCATION)/csa/
	CSA_EXT_DIR     = $(CSA_LOCATION)/external/
	CSA_SRC_DIR     = $(CSA_LOCATION)/src/
	CSA_TGT_DIR     = $(CSA_LOCATION)/saga/
#	CSA_SUFFIX      =
#	CSA_SUBDIR      =
	CSA_LINK_INFO   = yes
endif


# never ever build parallel
.NOTPARALLEL:

SRCDIR         = $(CSA_SRC_DIR)
EXTDIR         = $(CSA_EXT_DIR)

DATE           = $(shell date '+%Y-%m-%d-%H-%M')
LOG            = $(CSA_ROOT)/test/test.saga-$(CSA_SAGA_VERSION).$(CC_NAME).$(CSA_HOST)$(CSA_SUFFIX).$(DATE).log

# to be call'ed by individual tests.  The first check expects the call to
# succeed, the second expects it to fail (like running /bin/false).  
# Parameters:
#  $1: module to check
#  $2: name of test
#  $3: command to run

# NOTE that, in 'force' mode, the CHECK files have a dummy postfix - we always 
# want to recreate them...
ifdef CSA_FORCE
  FORCE        = .dummy
endif

########################################################################
# 
# make helper to remove white space from vars
#
empty   = 
space   = $(empty) $(empty)
nospace = $(subst $(space),$(empty),$1)

J       = -j 1

########################################################################
#
# compiler to be used for *everything*
#
CC         = gcc
CXX        = g++


########################################################################
# 
# find out gcc version
#
# gcc --version is stupidly formatted.  Worse, that format is inconsistent over
# different distribution channels.  Thus this detour to get the version directly
# via gcc compiler macros:
ifeq "$(CSA_HOST)" "localhost"
 CC_VERSION  = $(shell (gcc --version | head -1 | rev | cut -f 1 -d ' '| rev))
else
 CC_VERSION  = $(shell (rm -f cpp_version ; make cpp_version ; ./cpp_version) | tail -n 1)
endif
CC_NAME      = $(notdir $(CC))-$(CC_VERSION)
MAKE_VERSION = $(shell make --version | head -1)


########################################################################
# 
# report setup
#
info:
	@rm -f $(LOG) 
	@touch $(LOG)
	@echo "log file                  $(LOG)"                  2>&1 | tee -a $(LOG)
	@echo "hostname                  $(CSA_HOST)"             2>&1 | tee -a $(LOG)
	@echo "time stamp                $(DATE)"                 2>&1 | tee -a $(LOG)
	@echo "csa  location             $(CSA_LOCATION)"         2>&1 | tee -a $(LOG)
	@echo "csa  target               $(CSA_TGT_DIR)"          2>&1 | tee -a $(LOG)
	@echo "saga version              $(CSA_SAGA_VERSION)"     2>&1 | tee -a $(LOG)
	@echo "make version              $(MAKE_VERSION)"         2>&1 | tee -a $(LOG)
	@echo "compiler version          $(CC_NAME)"              2>&1 | tee -a $(LOG)


########################################################################
#
# basic tools
#
SED        = $(shell which sed)
ENV        = $(shell which env)
WGET       = $(shell which wget) --no-check-certificate
CHMOD      = $(shell which chmod)


SVN        = $(shell which svn 2>/dev/null)
SVNCO      = $(SVN) co
SVNUP      = $(SVN) up

ifeq "$(SVN)" ""
 $(error Could not find svn binary)
endif

MYPATH     = "/bin/:/usr/bin/:$(GLOBUS_LOCATION)/bin:"$(shell dirname $(SED))

##########################################################################
# #
# # target dependencies
# #
# # NOTE: dependencies are now resolved in csa_deploy.pl
# #
# .PHONY: all
# all:                      saga-core saga-adaptors saga-bindings saga-clients documentation
# 
.PHONY: externals
externals::                boost postgresql sqlite3
boost::                    python
# 
# .PHONY: saga-core
# saga-core::                externals
# 
.PHONY: saga-adaptors
saga-adaptors::            saga-adaptor-x509
saga-adaptors::            saga-adaptor-globus 
saga-adaptors::            saga-adaptor-ssh 
saga-adaptors::            saga-adaptor-bes 
saga-adaptors::            saga-adaptor-glite
saga-adaptors::            saga-adaptor-aws 
saga-adaptors::            saga-adaptor-drmaa
saga-adaptors::            saga-adaptor-torque
saga-adaptors::            saga-adaptor-pbspro
saga-adaptors::            saga-adaptor-condor
# 
.PHONY: saga-bindings
saga-bindings::            saga-binding-python
# saga-bindings::            saga-core

# .PHONY: saga-binding-python
# saga-binding-python::      python
# 
.PHONY: saga-clients saga-client-mandelbrot saga-client-bigjob
saga-clients::             saga-client-mandelbrot saga-client-bigjob
# saga-client-mandelbrot::   saga-core
# saga-client-bigjob::       saga-core saga-binding-python            

########################################################################
# 
# default target makes only sense for checking
#
.PHONY: all
all:


########################################################################
#
# base
#
# create the basic directory infrastructure, documentation, etc
#
.PHONY: base
base:: $(CSA_SRC_DIR) $(CSA_TGT_DIR) $(CSA_EXT_DIR) $(CSA_ROOT)

$(CSA_SRC_DIR):
	@mkdir -p $@

$(CSA_TGT_DIR):
	@mkdir -p $@

$(CSA_EXT_DIR):
	@mkdir -p $@

# always do an svn up, on check
.PHONY: $(CSA_ROOT) 
$(CSA_ROOT):
#	 now done by csa_deploy itself
#	 @test -d $@ || $(SVNCO) https://svn.cct.lsu.edu/repos/saga-projects/deployment/tg-csa $@
#	 @test -d $@ && cd $@ && $(SVNUP)


########################################################################
#
# externals
#

########################################################################
# python
PYTHON_VERSION   = 2.7.1
PYTHON_SVERSION  = 2.7
PYTHON_LOCATION  = $(CSA_EXT_DIR)/python/$(PYTHON_VERSION)/gcc-$(CC_VERSION)/
PYTHON_PATH      = $(PYTHON_LOCATION)/bin
PYTHON_MODPATH   = $(PYTHON_LOCATION)/lib/$(PYTHON_SVERSION)/site-packages/
PYTHON_CHECK     = $(PYTHON_PATH)/python
PYTHON_SRC       = http://python.org/ftp/python/$(PYTHON_VERSION)/Python-$(PYTHON_VERSION).tar.bz2
SAGA_ENV_VARS   += PYTHON_LOCATION=$(PYTHON_LOCATION)
SAGAPY_ENV_LIBS += $(PYTHON_LOCATION)/lib/
SAGA_ENV_BINS   += $(PYTHON_LOCATION)/bin/

.PHONY: python
python:: base $(PYTHON_CHECK)$(FORCE)

$(PYTHON_CHECK)$(FORCE):
	@echo "python                    installing"
	@cd $(SRCDIR) ; $(WGET) $(PYTHON_SRC)
	@cd $(SRCDIR) ; tar jxvf Python-$(PYTHON_VERSION).tar.bz2
	@cd $(SRCDIR)/Python-$(PYTHON_VERSION)/ ; \
                ./configure --prefix=$(PYTHON_LOCATION) --enable-shared --enable-unicode=ucs4 && make $J && make install


########################################################################
# boost
BOOST_LOCATION  = $(CSA_EXT_DIR)boost/1.44.0/$(CC_NAME)/
BOOST_CHECK     = $(BOOST_LOCATION)/include/boost/version.hpp
BOOST_SRC       = http://garr.dl.sourceforge.net/project/boost/boost/1.44.0/boost_1_44_0.tar.bz2
SAGA_ENV_VARS  += BOOST_LOCATION=$(BOOST_LOCATION)
SAGA_ENV_LIBS  += $(BOOST_LOCATION)/lib/

SAGA_ENV_LDPATH = $(call nospace, $(foreach d,$(SAGA_ENV_LIBS) $(SAGAPY_ENV_LIBS),:$(d)))
SAGA_ENV        = PATH=$(SAGA_ENV_PATH):$(MYPATH) LD_LIBRARY_PATH=$(SAGA_ENV_LDPATH):$$LD_LIBRARY_PATH $(SAGA_ENV_VARS)

.PHONY: boost
boost:: base $(BOOST_CHECK)$(FORCE)

$(BOOST_CHECK)$(FORCE):
	@echo "boost                     installing"
	@cd $(SRCDIR) ; $(WGET) $(BOOST_SRC)
	@cd $(SRCDIR) ; tar jxvf boost_1_44_0.tar.bz2
	@cd $(SRCDIR)/boost_1_44_0 ; $(ENV) $(SAGA_ENV) ./bootstrap.sh \
                               --with-libraries=test,thread,system,iostreams,filesystem,program_options,python,regex,serialization \
                               --with-python=$(PYTHON_LOCATION)/bin/python \
                               --with-python-root=$(PYTHON_LOCATION) \
                               --with-python-version=2.7 \
                               --prefix=$(BOOST_LOCATION) && ./bjam $J && ./bjam install


########################################################################
# postgresql
POSTGRESQL_LOCATION = $(CSA_EXT_DIR)postgresql/9.0.2/$(CC_NAME)/
POSTGRESQL_CHECK    = $(POSTGRESQL_LOCATION)/include/pg_config.h
POSTGRESQL_SRC      = http://ftp7.de.postgresql.org/ftp.postgresql.org/source/v9.0.2/postgresql-9.0.2.tar.bz2
SAGA_ENV_VARS      += POSTGRESQL_LOCATION=$(POSTGRESQL_LOCATION)
SAGA_ENV_LIBS      += :$(POSTGRESQL_LOCATION)/lib/

.PHONY: postgresql
postgresql:: base $(POSTGRESQL_CHECK)$(FORCE)

$(POSTGRESQL_CHECK)$(FORCE):
	@echo "postgresql                installing"
	@cd $(SRCDIR) ; $(WGET) $(POSTGRESQL_SRC)
	@cd $(SRCDIR) ; tar jxvf postgresql-9.0.2.tar.bz2
	@cd $(SRCDIR)/postgresql-9.0.2/ ; ./configure --prefix=$(POSTGRESQL_LOCATION) --without-readline && make $J && make install


########################################################################
# sqlite3
SQLITE3_LOCATION = $(CSA_EXT_DIR)sqlite3/3.6.13/$(CC_NAME)/
SQLITE3_CHECK    = $(SQLITE3_LOCATION)/include/sqlite3.h
SQLITE3_SRC      = http://www.sqlite.org/sqlite-amalgamation-3.6.13.tar.gz
SAGA_ENV_VARS   += SQLITE3_LOCATION=$(SQLITE3_LOCATION)
SAGA_ENV_LIBS   += :$(SQLITE3_LOCATION)/lib/

.PHONY: sqlite3
sqlite3:: base $(SQLITE3_CHECK)$(FORCE)

$(SQLITE3_CHECK)$(FORCE):
	@echo "sqlite3                   installing"
	@cd $(SRCDIR) ; $(WGET) $(SQLITE3_SRC)
	@cd $(SRCDIR) ; tar zxvf sqlite-amalgamation-3.6.13.tar.gz
	@cd $(SRCDIR)/sqlite-3.6.13/ ; ./configure --prefix=$(SQLITE3_LOCATION) && make $J && make install


########################################################################
#
# saga-core
#
SAGA_LOCATION   = $(CSA_TGT_DIR)/$(CSA_SAGA_VERSION)/$(CC_NAME)/
SAGA_CORE_CHECK = $(SAGA_LOCATION)/include/saga/saga.hpp
SAGA_ENV_VARS  += SAGA_LOCATION=$(SAGA_LOCATION)
SAGA_ENV_LIBS  += :$(SAGA_LOCATION)/lib/
SAGA_ENV_BINS  += :$(SAGA_LOCATION)/bin/

SAGA_ENV_LDPATH = $(call nospace, $(foreach d,$(SAGA_ENV_LIBS),:$(d)))
SAGA_ENV_PATH   = $(call nospace, $(foreach d,$(SAGA_ENV_BINS),:$(d)))
SAGA_ENV        = PATH=$(SAGA_ENV_PATH):$(MYPATH) LD_LIBRARY_PATH=$(SAGA_ENV_LDPATH):$$LD_LIBRARY_PATH $(SAGA_ENV_VARS)

ifeq "$(CSA_HOST)" "abe"
  # boost assumes that all linux hosts know this define.  Well, abe does not.
  SAGA_ENV_VARS += CPPFLAGS="-D__NR_eventfd=323"
endif

.PHONY: saga-core
saga-core:: base $(SAGA_CORE_CHECK)$(FORCE)

$(SAGA_CORE_CHECK)$(FORCE):
	@echo "saga-core                 installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT) 
	@cd $(SRCDIR)/$(CSA_SAGA_TGT) ; $(ENV) $(SAGA_ENV) \
                 ./configure --prefix=$(SAGA_LOCATION) && make clean && make $J && make install


########################################################################
#
# python bindings
#
SAGA_PYTHON_CHECK    = $(SAGA_LOCATION)/share/saga/config/python.m4 
SAGA_PYTHON_MODPATH  = $(SAGA_LOCATION)/lib/python$(PYTHON_SVERSION)/site-packages/

SAGA_ENV_LDPATH      = $(call nospace, $(foreach d,$(SAGA_ENV_LIBS) $(SAGAPY_ENV_LIBS),:$(d)))
SAGAPY_ENV_LDPATH    = 
SAGA_ENV             = PATH=$(SAGA_ENV_PATH):$(MYPATH) LD_LIBRARY_PATH=$(SAGA_ENV_LDPATH):$$LD_LIBRARY_PATH $(SAGA_ENV_VARS)

.PHONY: saga-binding-python
saga-binding-python:: base $(SAGA_PYTHON_CHECK)$(FORCE)

$(SAGA_PYTHON_CHECK)$(FORCE):
	@echo "saga-binding-python       installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT) ; $(ENV) $(SAGA_ENV) \
                   ./configure && make clean && make $J && make install


########################################################################
#
# saga-adaptors
#
########################################################################


########################################################################
# saga-adaptor-x509
SA_X509_CHECK    = $(SAGA_LOCATION)/share/saga/saga_adaptor_x509_context.ini

.PHONY: saga-adaptor-x509
saga-adaptor-x509:: base $(SA_X509_CHECK)$(FORCE)
	@$(call CHECK, $@, install, test -e $(SA_X509_CHECK))

$(SA_X509_CHECK)$(FORCE):
	@echo "saga-adaptor-x509         installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-globus
SA_GLOBUS_CHECK    = $(SAGA_LOCATION)/share/saga/saga_adaptor_globus_gram_job.ini

.PHONY: saga-adaptor-globus
saga-adaptor-globus:: base $(SA_GLOBUS_CHECK)$(FORCE)
	@$(call CHECK, $@, install, test -e $(SA_GLOBUS_CHECK))

$(SA_GLOBUS_CHECK)$(FORCE):
	@echo "saga-adaptor-globus       installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-ssh
SA_SSH_CHECK    = $(SAGA_LOCATION)/share/saga/saga_adaptor_ssh_job.ini

.PHONY: saga-adaptor-ssh
saga-adaptor-ssh:: base $(SA_SSH_CHECK)$(FORCE)

$(SA_SSH_CHECK)$(FORCE):
	@echo "saga-adaptor-ssh          installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-aws
SA_AWS_CHECK    = $(SAGA_LOCATION)/share/saga/saga_adaptor_aws_context.ini

.PHONY: saga-adaptor-aws
saga-adaptor-aws:: base $(SA_AWS_CHECK)$(FORCE)

$(SA_AWS_CHECK)$(FORCE):
	@echo "saga-adaptor-aws          installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-drmaa
SA_DRMAA_CHECK  = $(SAGA_LOCATION)/share/saga/saga_adaptor_ogf_drmaa_job.ini

.PHONY: saga-adaptor-drmaa
saga-adaptor-drmaa:: base $(SA_DRMAA_CHECK)$(FORCE)

$(SA_DRMAA_CHECK)$(FORCE):
	@echo "saga-adaptor-drmaa        installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-condor
SA_CONDOR_CHECK  = $(SAGA_LOCATION)/share/saga/saga_adaptor_condor_job.ini

.PHONY: saga-adaptor-condor
saga-adaptor-condor:: base $(SA_CONDOR_CHECK)$(FORCE)

$(SA_CONDOR_CHECK)$(FORCE):
	@echo "saga-adaptor-condor       installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-glite 
SA_GLITE_CHECK  = $(SAGA_LOCATION)/share/saga/saga_adaptor_glite_sd.ini

.PHONY: saga-adaptor-glite
saga-adaptor-glite:: base $(SA_GLITE_CHECK)$(FORCE)

$(SA_GLITE_CHECK)$(FORCE):
	@echo "saga-adaptor-glite        installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-pbspro
SA_PBSPRO_CHECK  = $(SAGA_LOCATION)/share/saga/saga_adaptor_pbspro_job.ini

.PHONY: saga-adaptor-pbspro
saga-adaptor-pbspro:: base $(SA_PBSPRO_CHECK)$(FORCE)

$(SA_PBSPRO_CHECK)$(FORCE):
	@echo "saga-adaptor-pbspro       installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-torque
SA_TORQUE_CHECK  = $(SAGA_LOCATION)/share/saga/saga_adaptor_torque_job.ini

.PHONY: saga-adaptor-torque
saga-adaptor-torque:: base $(SA_TORQUE_CHECK)$(FORCE)

$(SA_TORQUE_CHECK)$(FORCE):
	@echo "saga-adaptor-torque       installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
# saga-adaptor-bes
SA_BES_CHECK    = $(SAGA_LOCATION)/share/saga/saga_adaptor_bes_hpcbp_job.ini

.PHONY: saga-adaptor-bes
saga-adaptor-bes:: base $(SA_BES_CHECK)$(FORCE)

$(SA_BES_CHECK)$(FORCE):
	@echo "saga-adaptor-bes          installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  && make clean && make $J && make install


########################################################################
#
# mandelbrot client
#
SC_MANDELBROT_CHECK    = $(SAGA_LOCATION)/bin/mandelbrot_client

.PHONY: saga-client-mandelbrot
saga-client-mandelbrot:: base $(SC_MANDELBROT_CHECK)$(FORCE)

$(SC_MANDELBROT_CHECK)$(FORCE):
	@echo "saga-client-mandelbrot    installing"
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) ./configure  --disable-master && make clean && make $J && make install


# ########################################################################
# #
# # bigjob client
# #
# SC_BIGJOB_CHECK      = $(SAGA_LOCATION)/bin/test-bigjob
# SUP                  = "saga-client-bigjob-supplemental.tgz"
# SUP_URL              = "http://download.saga-project.org/saga-interop/dist/csa/$(SUP)"
# 
# BIGJOB_SETUP_URL     = https://svn.cct.lsu.edu/repos/saga-projects/applications/bigjob/trunk/generic/setup.py
# BIGJOB_VERSION       = $(shell wget -qO - $(BIGJOB_SETUP_URL) | grep version | cut -f 2 -d "'")
# BIGJOB_EGG           = $(shell echo "BigJob-$(BIGJOB_VERSION)-py$(PYTHON_SVERSION).egg")
# SAGA_PYTHON_MODPATH := $(SAGA_PYTHON_MODPATH):$(SAGA_LOCATION)/lib/python$(PYTHON_SVERSION)/$(BIGJOB_EGG)/
# 
# # $(warning bigjob-version: $(BIGJOB_VERSION))
# # $(warning bigjob-egg    : $(BIGJOB_EGG))
# # $(warning bigjob-mod    : $(SAGA_PYTHON_MODPATH))
# 
# TEST_ENV                 = /usr/bin/env
# TEST_ENV                += PYTHONPATH=$(SAGA_PYTHON_MODPATH):$(PYTHON_MODPATH)
# TEST_ENV                += LD_LIBRARY_PATH=$(SAGA_ENV_LDPATH):$(SAGAPY_ENV_LDPATH):$$LD_LIBRARY_PATH
# 
# .PHONY: saga-client-bigjob
# saga-client-bigjob:: base $(SC_BIGJOB_CHECK)$(FORCE)
# 
# $(SC_BIGJOB_CHECK)$(FORCE):
# #	@echo "saga-client-bigjob        installing (supplementals)"
# #	@cd $(SAGA_LOCATION)/lib/python$(PYTHON_VERSION)/ ; wget $(SUP_URL) ; tar zxvf $(SUP) 
# 	@echo "saga-client-bigjob        installing"
# 	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
# 	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
# 	@rm -rf $(SC_BIGJOB_CHECK)
# 	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(ENV) $(SAGA_ENV) make install
# 	@sed -i $(SAGA_LOCATION)/lib/python2.7/site-packages/easy-install.pth -e 's/^.*BigJob.*$$//g'
# 
# 
########################################################################
#
# bigjob client
#
SC_BIGJOB_CHECK      = $(SAGA_LOCATION)/bin/test-bigjob
BJ_SETUPTOOLS        = "setuptools-0.6c11-py2.7.egg"
BJ_SETUPTOOLS_URL    = "http://pypi.python.org/packages/2.7/s/setuptools/$(BJ_SETUPTOOLS)"

BJ_SETUPTOOLS_GIT    = "setuptools-git-0.4.2.tar.gz"
BJ_SETUPTOOLS_GIT_URL= "http://pypi.python.org/packages/source/s/setuptools-git/$(BJ_SETUPTOOLS_GIT)"

BIGJOB_EGGS          = $(shell ls -d $(SAGA_PYTHON_MODPATH)/BigJob-*-py2.7.egg 2> /dev/null)
BIGJOB_EGG           = $(shell echo $(BIGJOB_EGGS) | sort -n | tail -n 1 | rev | cut -f 1 -d '/' | rev)
BIGJOB_VERSION       = $(shell echo $(BIGJOB_EGG)                        | rev | cut -f 2 -d '-' | rev)
BIGJOB_MODPATH      := $(SAGA_PYTHON_MODPATH)/$(BIGJOB_EGG)/
SAGA_PYTHON_MODPATH := $(SAGA_PYTHON_MODPATH):$(BIGJOB_MODPATH)

hallo:
	@echo BIGJOB_MODPATH = $(BIGJOB_MODPATH)

# $(warning bigjob-version: $(BIGJOB_VERSION))
# $(warning bigjob-eggs   : $(BIGJOB_EGGS))
# $(warning bigjob-egg    : $(BIGJOB_EGG))
# $(warning bigjob-mod    : $(BIGJOB_MODPATH))

TEST_ENV                 = /usr/bin/env
TEST_ENV                += PATH=$(PYTHON_LOCATION)/bin/:$(SAGA_LOCATION)/bin/:$(MYPATH)
TEST_ENV                += PYTHONPATH=$(SAGA_PYTHON_MODPATH):$(PYTHON_MODPATH)
TEST_ENV                += LD_LIBRARY_PATH=$(SAGA_ENV_LDPATH):$(SAGAPY_ENV_LDPATH):$$LD_LIBRARY_PATH

.PHONY: saga-client-bigjob
saga-client-bigjob:: base $(SC_BIGJOB_CHECK)$(FORCE)

$(SC_BIGJOB_CHECK)$(FORCE):
	@echo "saga-client-bigjob        installing"
	@rm -rf $(SC_BIGJOB_CHECK)
	@cd $(SRCDIR) ; rm -f $(BJ_SETUPTOOLS)     ; wget $(BJ_SETUPTOOLS_URL)     && $(TEST_ENV) sh $(BJ_SETUPTOOLS)
	@cd $(SRCDIR) ; rm -f $(BJ_SETUPTOOLS_GIT) ; wget $(BJ_SETUPTOOLS_GIT_URL) && \
      tar zxvf $(BJ_SETUPTOOLS_GIT) && cd setuptools-git-0.4.2 && \
      $(TEST_ENV) $(PYTHON_CHECK) setup.py install --prefix=$(SAGA_LOCATION)
	@cd $(SRCDIR) ; $(TEST_ENV) $(PYTHON_LOCATION)/bin/easy_install -U --prefix=$(SAGA_LOCATION) bigjob
	@sed -i $(SAGA_LOCATION)/lib/python$(PYTHON_SVERSION)/site-packages/easy-install.pth -e 's/^.*BigJob.*$$//g'

#	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) && $(SVNUP)                 $(CSA_SAGA_TGT) ; true
#	@cd $(SRCDIR) ; test -d $(CSA_SAGA_TGT) || $(SVNCO) $(CSA_SAGA_SRC) $(CSA_SAGA_TGT)
#	@cd $(SRCDIR)/$(CSA_SAGA_TGT)/ ; $(TEST_ENV) $(PYTHON_CHECK) setup.py install --prefix=$(SAGA_LOCATION)

########################################################################
#
# documentation
#
# create some basic documentation about the installed software packages
#
CSA_SHELLRC_SRC   = $(CSA_ROOT)/env/saga-env.stub
CSA_SHELLRC_CHECK = $(CSA_ROOT)/env/saga-$(CSA_SAGA_VERSION).$(CC_NAME).$(CSA_HOST)$(CSA_SUFFIX).sh
CSA_README_SRC    = $(CSA_ROOT)/doc/README.stub
CSA_README_CHECK  = $(CSA_ROOT)/doc/README.saga-$(CSA_SAGA_VERSION).$(CC_NAME).$(CSA_HOST)$(CSA_SUFFIX)
CSA_MODULE_SRC    = $(CSA_ROOT)/mod/module.stub
CSA_MODULE_CHECK  = $(CSA_ROOT)/mod/module.saga-$(CSA_SAGA_VERSION).$(CC_NAME).$(CSA_HOST)$(CSA_SUFFIX)

.PHONY: documentation
documentation:: base $(CSA_SHELLRC_CHECK)$(FORCE) $(CSA_README_CHECK)$(FORCE) $(CSA_MODULE_CHECK)$(FORCE) permissions

$(CSA_SHELLRC_CHECK)$(FORCE): $(CSA_SHELLRC_SRC)
	@echo "SHELLRC                   creating"
	@cp -fv $(CSA_SHELLRC_SRC) $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_VERSION###|$(CSA_SAGA_VERSION)|ig;'          $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_LOCATION###|$(SAGA_LOCATION)|ig;'            $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_LDLIBPATH###|$(SAGA_ENV_LDPATH)|ig;'         $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_PATH###|$(SAGA_ENV_PATH)|ig;'                $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_MODPATH###|$(SAGA_PYTHON_MODPATH)|ig;'       $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###PYTHON_PATH###|$(PYTHON_LOCATION)/bin/|ig;'       $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###PYTHON_MODPATH###|$(PYTHON_MODPATH)|ig;'          $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_PYTHON###|$(PYTHON_LOCATION)/bin/python|ig;' $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_PYLOCATION###|$(PYTHON_LOCATION)|ig;'        $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_PYVERSION###|$(PYTHON_VERSION)|ig;'          $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###SAGA_PYSVERSION###|$(PYTHON_SVERSION)|ig;'        $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###CSA_LOCATION###|$(CSA_LOCATION)|ig;'              $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###CC_NAME###|$(CC_NAME)|ig;'                        $(CSA_SHELLRC_CHECK)
	@$(SED) -i -e 's|###BIGJOB_MODPATH###|$(BIGJOB_MODPATH)|ig;'          $(CSA_SHELLRC_CHECK)
ifdef CSA_LINK_INFO
	@rm -f                       $(CSA_LOCATION)/env.saga.sh
	@ln -s  $(CSA_SHELLRC_CHECK) $(CSA_LOCATION)/env.saga.sh
endif

$(CSA_README_CHECK)$(FORCE): $(CSA_README_SRC)
	@echo "README                    creating"
	@cp -fv $(CSA_README_SRC) $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_VERSION###|$(CSA_SAGA_VERSION)|ig;'          $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_LOCATION###|$(SAGA_LOCATION)|ig;'            $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_LDLIBPATH###|$(SAGA_ENV_LDPATH)|ig;'         $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_PATH###|$(SAGA_ENV_PATH)|ig;'                $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_MODPATH###|$(SAGA_PYTHON_MODPATH)|ig;'       $(CSA_README_CHECK)
	@$(SED) -i -e 's|###PYTHON_PATH###|$(PYTHON_LOCATION)/bin/|ig;'       $(CSA_README_CHECK)
	@$(SED) -i -e 's|###PYTHON_MODPATH###|$(PYTHON_MODPATH)|ig;'          $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_PYTHON###|$(PYTHON_LOCATION)/bin/python|ig;' $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_PYLOCATION###|$(PYTHON_LOCATION)|ig;'        $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_PYVERSION###|$(PYTHON_VERSION)|ig;'          $(CSA_README_CHECK)
	@$(SED) -i -e 's|###SAGA_PYSVERSION###|$(PYTHON_SVERSION)|ig;'        $(CSA_README_CHECK)
	@$(SED) -i -e 's|###CSA_LOCATION###|$(CSA_LOCATION)|ig;'              $(CSA_README_CHECK)
	@$(SED) -i -e 's|###CC_NAME###|$(CC_NAME)|ig;'                        $(CSA_README_CHECK)
	@$(SED) -i -e 's|###BIGJOB_MODPATH###|$(BIGJOB_MODPATH)|ig;'          $(CSA_README_CHECK)
ifdef CSA_LINK_INFO
	@rm -f                      $(CSA_LOCATION)/README.saga
	@ln -s  $(CSA_README_CHECK) $(CSA_LOCATION)/README.saga
endif
	
$(CSA_MODULE_CHECK)$(FORCE): $(CSA_MODULE_SRC)
	@echo "module                    creating"
	@cp -fv $(CSA_MODULE_SRC) $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_VERSION###|$(CSA_SAGA_VERSION)|ig;'          $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_LOCATION###|$(SAGA_LOCATION)|ig;'            $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_LDLIBPATH###|$(SAGA_ENV_LDPATH)|ig;'         $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_PATH###|$(SAGA_ENV_PATH)|ig;'                $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_MODPATH###|$(SAGA_PYTHON_MODPATH)|ig;'       $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###PYTHON_PATH###|$(PYTHON_LOCATION)/bin/|ig;'       $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###PYTHON_MODPATH###|$(PYTHON_MODPATH)|ig;'          $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_PYTHON###|$(PYTHON_LOCATION)/bin/python|ig;' $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_PYLOCATION###|$(PYTHON_LOCATION)|ig;'        $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_PYVERSION###|$(PYTHON_VERSION)|ig;'          $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###SAGA_PYSVERSION###|$(PYTHON_SVERSION)|ig;'        $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###CSA_LOCATION###|$(CSA_LOCATION)|ig;'              $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###CC_NAME###|$(CC_NAME)|ig;'                        $(CSA_MODULE_CHECK)
	@$(SED) -i -e 's|###BIGJOB_MODPATH###|$(BIGJOB_MODPATH)|ig;'          $(CSA_MODULE_CHECK)
ifdef CSA_LINK_INFO
	@rm -f                      $(CSA_LOCATION)/module.saga
	@ln -s  $(CSA_MODULE_CHECK) $(CSA_LOCATION)/module.saga
endif

.PHONY: permissions
permissions:
	@echo "fixing permissions"
	@-$(CHMOD) -R a+rX $(SAGA_LOCATION)
	@-$(CHMOD) -R a+rX $(EXTDIR)
	@-$(CHMOD)    a+rX $(CSA_LOCATION)


.PHONY: test
test: info
	@bash -c 'cd $(CSA_LOCATION) && source env.saga.sh && cd csa && ./csa_deploy.pl -r $(CSA_HOST) $(LOG) $(CSA_TESTS)'


