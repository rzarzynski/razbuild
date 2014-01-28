# Dependency tracing module for GNU Make
# author: Radoslaw Zarzynski
# date: 3rd November 2013
# license: GNU GPL v2

# Convert file system path provided in the first argument $1 into
# package name. Please note that package name may be consisted
# with multiple directory names. This structure allows logically
# split packages into categories, subcategories and so on.
#
# Example:
#   dir2pkgname($(ROOT)/opensource/busybox) -> opensource/busybox
dir2pkgname = $(subst $(ROOTDIR)/,, $(abspath $(dir $1)))

# Convert package name provided in the first argument $1 into absolute
# file system path where the package files live in.
pkgname2dir = $(abspath $(ROOTDIR)/$(strip $1))

# Define function for recursively acquiring the list of all directories
# which contain file specified in the first argument $1, staring from
# directory location provided as the second argument $2.
find-marked = $(foreach cdir, $(dir $(wildcard $2/*/$(strip $1))),	\
	$(abspath $(cdir)) $(call find-marked, $1, $(cdir)))

# The top directory (aka root) of the whole build system structure is
# resolved basing on last the entry of MAKEFILE_LIST variable. It stores
# location of file currently executed by make (the included ones too!).
ROOTDIR    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# ... and run it on the root of source tree
PKGDIRS    := $(call find-marked, razbuild.mk, $(ROOTDIR))

# Obtain names of all indexed packages by stripping root directory path.
ALLPKGS    := $(subst $(ROOTDIR)/,, $(PKGDIRS))

STATDIR    := status

# All jobs (aka targets) should be stored on list. The core advantage
# of such idea is extendability.
JOBS       := fetch extract patch configure build install

# Parse all existing dependency files if necessary. Please be aware
# that dependencies are resolved only once: for the package that
# is the root of dependency graph. There is no need to perform
# such action for deps, deps of deps and so on. To speed up the build
# all invocation of make in these situation will be with RBLD_OPT_NODEPS
# param supplied (see $(filter-out $(THIS), $(ALLPKGS)) : % : %-fetch).
ifndef RBLD_OPT_NODEPS
    THIS    = $(call dir2pkgname, $(lastword $(MAKEFILE_LIST)))
    DEPS   := $(wildcard $(addsuffix /razbuild.depends, $(PKGDIRS)))

    include $(DEPS)
endif

THIS       := $(call dir2pkgname, $(firstword $(MAKEFILE_LIST)))

ifdef RBLD_OPT_FORCE
.PHONY        : $(ALLPKGS)
else
# Below pseudorule 
.INTERMEDIATE : $(ALLPKGS)

# Set directory where job early-exit files will be stored. Existence
# of such file in package's status directory will suppress execution
# all commands of the job. Concept behind this behaviour is to avoid
# performing already done actions.
$(foreach job, $(JOBS), $(eval vpath $(job) $(STATDIR)))
endif

# Define the proper dependencies between jobs and its order.
clean     : $(THIS)
extract   : $(THIS)
patch     :         extract-deps
configure : $(THIS) patch
build     : $(THIS) configure
install   : $(THIS) build

# The body of a job (read: commands which will be runned to perform
# a given target) should be provided by makefile that is including
# this file.
$(JOBS): | $(STATDIR)
	$(rule-$@)
	touch $(STATDIR)/$@

clean:
	$(RM) -r $(STATDIR)
	$(rule-$@)

# The install target has to put all result files created during
# package compilation in separate, per-package root directory.
# After that, content of such directory should be filtered
# accordingly to a given pattern and copied into final root dir
# which location shall be provided using the FUSION_DESTDIR param.
#ifndef FUSION_DESTDIR
#	$(error "The location of final temporary root directory is unknown!")
#	$(error "Please use the FUSION_DESTDIR param.")
#endif

# Handle cases when user wants to run the given job on whole dependency
# graph.
# Some jobs should be done for all packages before we go further.
$(addsuffix -deps, extract) : %-deps :
	$(MAKE) $*

# Rule for handling depedencies of root of current depedency graph.
$(filter-out $(THIS), $(ALLPKGS)) :
	$(MAKE) -C $(ROOTDIR)/$@ RBLD_OPT_NODEPS=true $(MAKECMDGOALS)

$(STATDIR) :
	mkdir -p $@
