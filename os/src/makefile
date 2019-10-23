# default target
default: all

all:
	@echo "sub:   "$(__project_path__)
	@echo "sub:   "$(__makefile__)

# -- name section here ------------------------------------------------------
__makefile__ := $(abspath $(firstword $(MAKEFILE_LIST)))
__project_path__ := $(patsubst %/,%,$(dir $(__makefile__)))