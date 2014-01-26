# Template file for handling component-related procedures.
# author: Radoslaw Zarzynski
# date: 25th January 2014
# license: GNU GPL v2

RBLD_WORKDIR ?= work
RBLD_STATDIR ?= status

RBLD_CONFCMD ?= ./configure
RBLD_MAKECMD ?= make
RBLD_INSTCMD ?= make install

RBLD_FNALDIR ?= /tmp/test

include ../../razbuild.mk

# The template could only be used when appropriate variables have
# been set. Perform sanity checks.
ifndef RBLD_WORKSRC
    $(error RBLD_WORKSRC is not set)
endif

# Supply some predefined rules for usual, regular use cases. It may
# be overriden if package has special needs regarding, for example,
# compilation method.
define rule-extract
	$(if $(RBLD_ARCHIVE),
		$(info  Using default rule for $@),
		$(error RBLD_ARCHIVE not set while using fallback rule))
	tar -C $(RBLD_WORKDIR) -xf $(RBLD_ARCHIVE)
endef

define rule-configure
	cd $(RBLD_WORKDIR)/$(RBLD_WORKSRC) && $(RBLD_CONFCMD)
endef

define rule-build
	cd $(RBLD_WORKDIR)/$(RBLD_WORKSRC) && $(RBLD_MAKECMD)
endef

define rule-install
	cd $(RBLD_WORKDIR)/$(RBLD_WORKSRC) && echo $(RBLD_INSTCMD)
endef

#VPATH := $(RBLD_STATDIR)
fetch extract patch configure build: | $(RBLD_WORKDIR) $(RBLD_STATDIR)

$(RBLD_WORKDIR) $(RBLD_STATDIR):
	mkdir $@

clean:
	$(RM) -r $(RBLD_WORKDIR) $(RBLD_STATDIR)
