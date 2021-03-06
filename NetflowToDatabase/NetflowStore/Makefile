# Copyright (C)2020 International Business Machines Corporation and
# others. All Rights Reserved.

.PHONY: all distributed clean 

# assume toolkit default locations
STREAMS_INETSERVER_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.inetserver
STREAMS_NETWORK_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.network
STREAMS_JDBC_TOOLKIT ?= $(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.jdbc

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
    TOOLKIT_PATH = $(STREAMS_INETSERVER_TOOLKIT):$(STREAMS_NETWORK_TOOLKIT):$(STREAMS_JDBC_TOOLKIT)
endif

SPLC_FLAGS ?= -a
SPL_CMD_ARGS ?=
SPLC = $(STREAMS_INSTALL)/bin/sc

SPL_MAIN_COMPOSITE = sample.netflow.store::NetflowStore

build: distributed

all: clean build

# We are in Cloud Pak for Data environment: do not use data directory
distributed:
	$(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --output-dir $(OUTPUT_DIR) $(SPL_CMD_ARGS)

clean: 
	$(SPLC) -C $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --output-dir $(OUTPUT_DIR) -C $(SPL_CMD_ARGS)
	rm -rf output

