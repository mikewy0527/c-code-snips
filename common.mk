.EXTRA_PREREQS := $(abspath $(lastword $(MAKEFILE_LIST)))

CC := clang
COMPILER_SUFFIX = $(lastword $(subst -, ,$(CC)))
BUILD_TYPE := release
LIB_TYPE := shared
JLEVEL := $(shell nproc)
ARCH := $(shell uname -m)
STD_VER := gnu17

TOP_DIR := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
BUILD_DIR := $(TOP_DIR)/build/$(ARCH)/$(BUILD_TYPE)

PREFIX := $(TOP_DIR)/out
ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

USE_RPATH := false
ifeq ($(LIB_TYPE),shared)
	ifeq ($(shell [[ "$(patsubst %/,%,$(PREFIX))" != "/usr" && \
			 "$(patsubst %/,%,$(PREFIX))" != "/usr/local" \
		      ]] && echo true),true)
		USE_RPATH := true
	endif
endif

CPPFLAGS :=
CFLAGS :=
CXXFLAGS :=
LDFLAGS :=

CPPFLAGS += -MD -MP
CFLAGS += -fdiagnostics-color=always
CFLAGS += -std=$(STD_VER)

ifeq ($(BUILD_TYPE),debug)
	CPPFLAGS += -DDEBUG
	CFLAGS += -Og
	CFLAGS += -ggdb
	CFLAGS += -Werror
else
	CPPFLAGS += -DNDEBUG
	CFLAGS += -O3
	CFLAGS += -fno-strict-overflow
	CFLAGS += -fno-strict-aliasing
endif
CFLAGS += -g3

CFLAGS += -Wall -Wextra
CFLAGS += -Winvalid-pch
CFLAGS += -Wformat=2
CFLAGS += -Werror=implicit
CFLAGS += -Werror=incompatible-pointer-types
CFLAGS += -Werror=int-conversion
CFLAGS += -Werror=implicit-function-declaration
CFLAGS += -Wstack-protector
CFLAGS += -Wshadow
CFLAGS += -Wpadded
CFLAGS += -Wconversion
CFLAGS += -Wswitch-enum
CFLAGS += -Wimplicit-fallthrough
CFLAGS += -Werror=format-security
ifneq ($(COMPILER_SUFFIX), clang)
	CFLAGS += -Werror=format-overflow
	CFLAGS += -Werror=format-truncation
endif

CFLAGS += -fstrict-flex-arrays=3
CFLAGS += -fno-delete-null-pointer-checks

CFLAGS += -fno-plt
CFLAGS += -fPIC
CFLAGS += -fpic
CFLAGS += -fexceptions
CFLAGS += --param=ssp-buffer-size=4
CFLAGS += -grecord-gcc-switches
CFLAGS += -fasynchronous-unwind-tables

LDFLAGS += -Wl,-O1
LDFLAGS += -Wl,--export-dynamic
LDFLAGS += -Wl,--as-needed
LDFLAGS += -Wl,--sort-common
LDFLAGS += -Wl,-z,defs
LDFLAGS += -Wl,-z,pack-relative-relocs
LDFLAGS += -Wl,-z,nodlopen

LDFLAGS += -Wl,-z,noexecstack
LDFLAGS += -flto
CFLAGS += -fsanitize=address
CFLAGS += -fno-omit-frame-pointer
CFLAGS += -fno-common
ifneq ($(COMPILER_SUFFIX), clang)
	CFLAGS += -Wtrampolines
	CFLAGS += -flto
	LDFLAGS += -fsanitize=address
else
	LDFLAGS += -lasan
endif

ifneq ($(COMPILER_SUFFIX), clang)
	GCC_VER_GTE_1411 := $(shell expr $$($(CC) -dumpversion | \
		    awk -F. '{print $$3+100*($$2+100*$$1)}') \>= 140101)
endif
ifneq ($(GCC_VER_GTE_1411),)
	CFLAGS += -Whardened
	CFLAGS += -fhardened
else
	CPPFLAGS += -U_FORTIFY_SOURCE
	CPPFLAGS += -D_FORTIFY_SOURCE=3
	CPPFLAGS += -D_GLIBCXX_ASSERTIONS
	CFLAGS += -ftrivial-auto-var-init=zero
	CFLAGS += -fPIE
	CFLAGS += -fpie
	ifneq ($(COMPILER_SUFFIX), clang)
		LDFLAGS  += -pie
	endif
	LDFLAGS += -Wl,-z,now
	LDFLAGS += -Wl,-z,relro
	CFLAGS += -fstack-protector-strong
	CFLAGS += -fstack-clash-protection
	CFLAGS += -fcf-protection=full
endif

CFLAGS += $(CPPFLAGS)
CXXFLAGS += $(CFLAGS)

.EXTRA_PREREQS += $(foreach MK_FILE, $(MAKEFILE_LIST),$(abspath $(MK_FILE)))
