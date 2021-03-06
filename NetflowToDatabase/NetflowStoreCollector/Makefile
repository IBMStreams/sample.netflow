# Copyright (C)2020 International Business Machines Corporation and
# # others. All Rights Reserved.
.PHONY: build all distributed clean

STREAMS_INET_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.inet
STREAMS_NETWORK_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.network

ifeq ($(STREAMS_STUDIO_BUILDING), 1)
    $(info Building from Streams Studio, use env vars set by studio)
    SPLC = $(STREAMS_STUDIO_SC_PATH)
    DATA_DIR = $(STREAMS_STUDIO_DATA_DIRECTORY)
    OUTPUT_DIR = $(STREAMS_STUDIO_OUTPUT_DIRECTORY)
    TOOLKIT_PATH = $(STREAMS_STUDIO_SPL_PATH)
else
    $(info build use env settings)
    ifndef STREAMS_INSTALL
        $(error require streams environment STREAMS_INSTALL)
    endif
    SPLC = $(STREAMS_INSTALL)/bin/sc
    DATA_DIR = data
    OUTPUT_DIR = output
    TOOLKIT_PATH = $(STREAMS_INET_TOOLKIT):$(STREAMS_NETWORK_TOOLKIT)
endif

SPL_MAIN_COMPOSITE = sample.netflow.store::NetflowStoreCollector
SPLC_FLAGS = -a
SPL_CMD_ARGS ?=

build: distributed

all: clean build

distributed:
	$(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --output-dir $(OUTPUT_DIR) $(SPL_CMD_ARGS)

clean:
	$(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --output-dir $(OUTPUT_DIR) -C $(SPL_CMD_ARGS)
	rm -rf output
