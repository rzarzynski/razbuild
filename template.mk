# Template file for handling component-related procedures.
# author: Radoslaw Zarzynski
# date: 25th January 2014
# license: GNU GPL v2

RBLD_WORKDIR ?= $(abspath work)
STATDIR ?= status

RBLD_CONFCMD ?= ./configure
RBLD_MAKECMD ?= make
RBLD_INSTCMD ?= make DESTDIR=$(RBLD_TEMPDIR) install

RBLD_TEMPDIR ?= $(RBLD_WORKDIR)/tmp_destdir
RBLD_FNALDIR ?= /tmp/test

# The template could only be used when appropriate variables have
# been set. Perform sanity checks.
ifndef RBLD_WORKSRC
    $(error RBLD_WORKSRC is not set)
endif

# Supply some predefined rules for usual, regular use cases. It may
# be overriden if package has special needs regarding, for example,
# compilation method.
define rule-fetch
endef

define rule-extract
	$(if $(RBLD_ARCHIVE),
		$(info  Using default rule for $@),
		$(error RBLD_ARCHIVE not set while using fallback rule))
	tar -C $(RBLD_WORKDIR) -xf $(RBLD_ARCHIVE)
endef

define rule-patch
endef

define rule-configure
	cd $(RBLD_WORKDIR)/$(RBLD_WORKSRC) && $(RBLD_CONFCMD)
endef

define rule-build
	cd $(RBLD_WORKDIR)/$(RBLD_WORKSRC) && $(RBLD_MAKECMD)
endef

define rule-install
	cd $(RBLD_WORKDIR)/$(RBLD_WORKSRC) && $(RBLD_INSTCMD)
endef

define rule-filter
endef

define rule-fusion
endef

define rule-clean
	$(RM) -r $(RBLD_WORKDIR) $(STATDIR)
endef

include ../../razbuild.mk

$(JOBS): | $(RBLD_WORKDIR) $(STATDIR) \
	$(RBLD_TEMPDIR)

$(RBLD_WORKDIR) $(RBLD_TEMPDIR):
	mkdir -p $@
