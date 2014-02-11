# Fetching module for RAZBUILD system.
# author  : Radoslaw Zarzynski
# date    : 10th February 2014
# license : GNU GPL v2

WGET     := wget

#RBLD_ARCHIVES := a.tar.gz b.tar.bz2

#RBLD_FETCH_URI[a.tar.gz] := test
#RBLD_FETCH_URI[b.tar.gz] := test2

# Obtain list of all archives with specified URI for downloading.
FETCHABLE  = $(foreach archive, $(RBLD_ARCHIVES),					\
	$(if $(RBLD_FETCH_URI[$(archive)]),$(archive)))

FETCHTGTS  = $(addprefix fetch-, $(FETCHABLE))

define rule-fetch
	@echo Everything fetched successfuly.
endef

$(FETCHTGTS)  : fetch-% :
	$(WGET) -O $* $(RBLD_FETCH_URI[$*])

fetch         : $(FETCHTGTS)
extract       : fetch

purge-fetch   :
	$(RM) $(FETCHABLE)

.INTERMEDIATE : $(FETCHTGTS)

JOBS  := $(JOBS) fetch-all
