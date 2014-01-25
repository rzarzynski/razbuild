# Template file for handling component-related procedures.
# author: Radoslaw Zarzynski
# date: 25th January 2014
# license: GNU GPL v2

define rule-configure
	@echo "Running default handler for $@"
endef

define rule-configure
	@echo "Running overwritten handler for $@"
endef

fetch extract patch configure:
	$(rule-$@)

# The install target has to put all result files created during
# package compilation in separate, per-package root directory.
# After that, content of such directory should be filtered
# accordingly to a given pattern and copied into final root dir
# which location shall be provided using the FUSION_DESTDIR param.

ifndef FUSION_DESTDIR
	$(error "The location of final temporary root directory is unknown!")
	$(error "Please use the FUSION_DESTDIR param.")
endif
install:
	$(rule-$@)
