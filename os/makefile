# -- Useful variables -------------------------------------------------------

# default target
default: all

all:
	@echo "main:   "$(__project_path__)
	@echo "main:   "$(__makefile__)
	@echo "main:   "$(MAKE)

	@echo "=== Building project ==="
	$(MAKE) --directory=src


# -- name section here ------------------------------------------------------
__makefile__ := $(abspath $(firstword $(MAKEFILE_LIST)))
__project_path__ := $(patsubst %/,%,$(dir $(__makefile__)))






















# mkfile_path := $(abspath $(firstword $(MAKEFILE_LIST)))
# PROJECT_PATH := $(patsubst %/,%,$(dir $(mkfile_path)))
# MAKE_INCLUDE=$(PROJECT_PATH)/config/make.global
# SUB_MAKE_INCLUDE=$(PROJECT_PATH)/config/submake.global


# need to be placed at the end of the file

### mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
### export PROJECT_PATH := $(patsubst %/,%,$(dir $(mkfile_path)))
### export MAKE_INCLUDE=$(PROJECT_PATH)/config/make.global
### export SUB_MAKE_INCLUDE=$(PROJECT_PATH)/config/submake.global
### include $(MAKE_INCLUDE)



# --------------------------------------------------------------------------->
# Function: string-downcase(string)
# Returns:  Returns the text in lower case
# Example:
#   $(call string-upcase,THE1 QUICK2 BROWN3 FOX4)
#   => the1 quick2 brown3 fox4
# ---------------------------------------------------------------------------<
#string-downcase = $(guile (string-downcase "$1"))

# LOCAL_PATH := $(shell pwd)

# # asd ifeq ($(BUILD_QEMU_IMAGES),true)
# #   subdir_makefiles=$(call first-makefiles-under,$(LOCAL_PATH))
# #   $(foreach mk,$(subdir_makefiles),$(info including $(mk) ...)$(eval include $(mk)))
# # endif

# .PHONY: build
# build:
# 	#@echo $(call string-downcase,THE1 QUICK2 BROWN3 FOX4)
# 	@echo ${MAKE_VERSION}



# echo $(LOCAL_PATH)


# TARGET_EXEC ?= a.out

# BUILD_DIR ?= ./build
# SRC_DIRS ?= ./src

# SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.s)
# OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
# DEPS := $(OBJS:.o=.d)

# INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# CPPFLAGS ?= $(INC_FLAGS) -MMD -MP

# $(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
# 	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# # assembly
# $(BUILD_DIR)/%.s.o: %.s
# 	$(MKDIR_P) $(dir $@)
# 	$(AS) $(ASFLAGS) -c $< -o $@

# # c source
# $(BUILD_DIR)/%.c.o: %.c
# 	$(MKDIR_P) $(dir $@)
# 	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# # c++ source
# $(BUILD_DIR)/%.cpp.o: %.cpp
# 	$(MKDIR_P) $(dir $@)
# 	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@


# .PHONY: clean

# clean:
# 	$(RM) -r $(BUILD_DIR)

# -include $(DEPS)

# MKDIR_P ?= mkdir -p