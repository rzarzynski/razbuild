include ../../inc.mk

dir2:
	@echo "dir2 dziala"
	@echo $(MAKEFILE_LIST)
	@echo $(realpath $(lastword $(MAKEFILE_LIST)))
