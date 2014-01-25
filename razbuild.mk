# Dependency tracing module for GNU Make
# author: Radoslaw Zarzynski
# date: 3rd November 2013
# license: GNU GPL v2

# razbuild demo
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

THIS  = $(call get_pkg_name, $(lastword $(MAKEFILE_LIST)))

get_pkg_name = $(subst $(ROOT)/,, $(abspath $(dir $1)))
# define function for acquiring the list of all directories
# which have been marked (with razbuild.index)...
find  = $(foreach cdir, $(dir $(wildcard $1/*/razbuild.mk)),		\
		$(abspath $(cdir)) $(call find,$(cdir)))

# ... and run it on the root of source tree
DIRS := $(call find, $(ROOT))

# obtain names of targets by stripping the root directory path
TGTS := $(subst $(ROOT)/,, $(DIRS))
DEPS := $(wildcard $(addsuffix /razbuild.depends, $(DIRS)))

# parse all existing dependency files if necessary
ifndef BLD_OPT_NODEPS
include $(DEPS)
endif

dbg:
	@echo "--> root dir: $(ROOT)"
	@echo "--> subdirs (1st level): $(DIRS)"
	@echo "--> depends (1st level): $(DEPS)"
	@echo "--> targets: $(TGTS)"

do:
	$(MAKE) -C $(DIRS) dbg

$(addsuffix -fetch, $(TGTS)) :
	@echo sciagam $@
	sleep 1

$(TGTS) : % : %-fetch
	#$(MAKE) -C $@

ifdef BLD_OPT_FORCE
.PHONY: $(TGTS)
endif
