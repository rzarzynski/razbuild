# Dependency tracing module for GNU Make
# author: Radoslaw Zarzynski
# date: 3rd November 2013
# license: GNU GPL v2

# Convert file system path provided in the first argument $1 into
# package name. Please note that package name may be consisted
# with multiple directory names. This structure allows logically
# split packages into categories, subcategoties and so on.
#
# Example:
#   dir2pkgname($(ROOT)/opensource/busybox) -> opensource/busybox
dir2pkgname = $(subst $(ROOT)/,, $(abspath $(dir $1)))

# Convert package name provided in the first argument $1 into absolute
# file system path where the package files live in.
pkgname2dir = $(abspath $(ROOT)/$(strip $1))

# Define function for recursivelly acquiring the list of all directories
# which contain file specified in the first argument $1, staring from
# directory location provided as the second argument $2.
find-marked = $(foreach cdir, $(dir $(wildcard $2/*/$(strip $1))),	\
	$(abspath $(cdir)) $(call find-marked, $1, $(cdir)))

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# ... and run it on the root of source tree
DIRS := $(call find-marked, razbuild.mk, $(ROOT))

# Obtain names of targets by stripping the root directory path.
TGTS := $(subst $(ROOT)/,, $(DIRS))

RBLD_STATDIR := status

# Parse all existing dependency files if necessary. Please be aware
# that dependencies are resolved only once: for the package that
# is the root of dependency graph. There is no need to perform
# such action for deps, deps of deps and so on. To speed up the build
# all invocation of make in these situation will be with RBLD_OPT_NODEPS
# param supplied (see $(filter-out $(THIS), $(TGTS)) : % : %-fetch).
ifndef RBLD_OPT_NODEPS
    THIS  = $(call dir2pkgname, $(lastword $(MAKEFILE_LIST)))
    DEPS := $(wildcard $(addsuffix /razbuild.depends, $(DIRS)))

    include $(DEPS)
endif

THIS := $(call dir2pkgname, $(firstword $(MAKEFILE_LIST)))

ifdef RBLD_OPT_FORCE
.PHONY: $(TGTS)
else
.INTERMEDIATE : $(TGTS)

vpath fetch		$(RBLD_STATDIR)
vpath extract	$(RBLD_STATDIR)
vpath patch		$(RBLD_STATDIR)
vpath configure	$(RBLD_STATDIR)
vpath build		$(RBLD_STATDIR)
vpath install	$(RBLD_STATDIR)
endif

# Define the proper dependencies between jobs and its order.
patch     :         extract
configure : $(THIS) patch
build     : $(THIS) configure
install   : $(THIS) build

# The body of a job (read: commands which will be runned to perform
# a given target) should be provided by makefile that is including
# this file.
fetch extract patch configure build: | $(RBLD_STATDIR)
	$(rule-$@)
	touch $(abspath $(RBLD_STATDIR)/$@)

clean: $(THIS)
	$(RM) -r $(RBLD_STATDIR)
	$(rule-$@)

# The install target has to put all result files created during
# package compilation in separate, per-package root directory.
# After that, content of such directory should be filtered
# accordingly to a given pattern and copied into final root dir
# which location shall be provided using the FUSION_DESTDIR param.
install:
#ifndef FUSION_DESTDIR
#	$(error "The location of final temporary root directory is unknown!")
#	$(error "Please use the FUSION_DESTDIR param.")
#else
	$(rule-$@)
#endif

# Some jobs should be done for all packages before we go further.
$(addsuffix -fetch, $(TGTS)) :
	@echo sciagam $(subst -fetch, ,$@)
	#$(MAKE) -C $(ROOT)/$(subst -fetch,,$@) fetch RBLD_OPT_NODEPS=true

# Rule for handling depedencies of root of current depedency graph.
$(filter-out $(THIS), $(TGTS)) :
	$(MAKE) -C $(ROOT)/$@ RBLD_OPT_NODEPS=true $(MAKECMDGOALS)

# ... and the root themself.
$(THIS):

$(RBLD_STATDIR) :
	mkdir -p $@

