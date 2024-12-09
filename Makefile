.EXTRA_PREREQS := $(abspath $(lastword $(MAKEFILE_LIST)))

include common.mk

SUBDIRS :=

SUBDIRS += lib
SUBDIRS += test

PHONY_CMPL_PFX := COMPILE_
PHONY_CMPL_SUBDIRS := $(addprefix $(PHONY_CMPL_PFX),$(SUBDIRS))

PHONY_INST_PFX := INSTALL_
PHONY_INST_SUBDIRS := $(addprefix $(PHONY_INST_PFX),$(SUBDIRS))

PHONY_UNINST_PFX := UNINSTALL_
PHONY_UNINST_SUBDIRS := $(addprefix $(PHONY_UNINST_PFX),$(SUBDIRS))

PHONY_CLEAN_PFX := CLEAN_
PHONY_CLEAN_SUBDIRS := $(addprefix $(PHONY_CLEAN_PFX),$(SUBDIRS))

.PHONY: all \
	$(BUILD_TYPE) $(PHONY_CMPL_SUBDIRS) \
	install $(PHONY_INST_SUBDIRS) \
	uninstall $(PHONY_UNINST_SUBDIRS) \
	clean $(PHONY_CLEAN_SUBDIRS) \

all: $(BUILD_TYPE)

$(BUILD_TYPE): $(PHONY_CMPL_SUBDIRS)
$(PHONY_CMPL_SUBDIRS):
	$(MAKE) -C $(subst $(PHONY_CMPL_PFX),,$@) -j$(JLEVEL)

install: $(PHONY_INST_SUBDIRS)
$(PHONY_INST_SUBDIRS):
	$(MAKE) -C $(subst $(PHONY_INST_PFX),,$@) install

uninstall: $(PHONY_UNINST_SUBDIRS)
$(PHONY_UNINST_SUBDIRS):
	$(MAKE) -C $(subst $(PHONY_UNINST_PFX),,$@) uninstall

clean: $(PHONY_CLEAN_SUBDIRS)
$(PHONY_CLEAN_SUBDIRS):
	$(MAKE) -C $(subst $(PHONY_CLEAN_PFX),,$@) clean

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

.EXTRA_PREREQS += $(foreach MK_FILE, $(MAKEFILE_LIST),$(abspath $(MK_FILE)))
