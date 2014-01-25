# Dependency tracing module for GNU Make
# author: Radoslaw Zarzynski
# date: 3rd November 2013

# razbuild demo
ROOT ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# define function for acquiring the list of all directories
# which have been marked (with razbuild.index)...
find  = $(foreach cdir, $(dir $(wildcard $1/*/razbuild.mk)),		\
		$(abspath $(cdir)) $(call find,$(cdir)))

# ... and run it on the root of source tree
DIRS := $(call find, $(ROOT))

# obtain names of targets by stripping the root directory path
TGTS := $(subst $(ROOT)/,, $(DIRS))
DEPS := $(wildcard $(addsuffix /razbuild.depends, $(DIRS)))

# include all existing dependency files
#include $(DEPS)

dbg:
	@echo "--> root dir: $(ROOT)"
	@echo "--> subdirs (1st level): $(DIRS)"
	@echo "--> depends (1st level): $(DEPS)"
	@echo "--> targets: $(TGTS)"

do:
	$(MAKE) -C $(DIRS) dbg

$(addsuffix -patch, $(TGTS)):
	@echo "ktos zawolal $@"

$(addsuffix -configure, $(TGTS)): %-configure : %-patch
	@echo "ktos zawolal $@"

$(addsuffix -build, $(TGTS)): %-build : %-configure
	@echo "ktos zawolal $@"

$(addsuffix -install, $(TGTS)): %-install : %-build
	@echo "ktos zawolal $@"

$(TGTS) : % : %-build
	@echo "ktos zawolal $@"


test2 test3 test4 : % :
	@echo "ktos zawolal $@"

ifndef test2
test2 :
	@echo $(origin DIRS)
	@echo "ktos zawolal $@"
endif
