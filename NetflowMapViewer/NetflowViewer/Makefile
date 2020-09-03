# Copyright (C)2020 International Business Machines Corporation and
# others. All Rights Reserved.

.PHONY: build build-clean geofiles geofiles-clean all clean

# assume toolkit default locations
STREAMS_INETSERVER_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.inetserver
STREAMS_NETWORK_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.network
STREAMS_INET_TOOLKIT ?= ${STREAMS_INSTALL}/toolkits/com.ibm.streamsx.inet

SPL_MAIN_COMPOSITE = sample.netflow.viewer::NetflowViewer

SPLC_FLAGS ?= -a
SPL_CMD_ARGS ?=

ifeq ($(STREAMS_STUDIO_BUILDING), 1)
    $(info Building from Streams Studio, use env vars set by studio)
    SPLC = $(STREAMS_STUDIO_SC_PATH)
    DATA_DIR = $(STREAMS_STUDIO_DATA_DIRECTORY)
    OUTPUT_DIR = $(STREAMS_STUDIO_OUTPUT_DIRECTORY)
    TOOLKIT_PATH = $(STREAMS_STUDIO_SPL_PATH)
else ifdef STREAMS_BUILDSERVICE
    $(info Building using buildservice)
    ifeq ($(STREAMS_INSTALL),)
        $(error error: environment variable STREAMS_INSTALL has to be set)
    endif
    SPLC = $(STREAMS_INSTALL)/bin/sc
    OUTPUT_DIR = output
    TOOLKIT_PATH = ../toolkits:$(STREAMS_INSTALL)/toolkits
    SPLC_FLAGS := $(SPLC_FLAGS) --rebuild-toolkits
else
    $(info Building using environment settings)
    ifndef STREAMS_INSTALL
        $(error require streams environment STREAMS_INSTALL)
    endif
    SPLC = $(STREAMS_INSTALL)/bin/sc
    OUTPUT_DIR = output
    TOOLKIT_PATH = $(STREAMS_INETSERVER_TOOLKIT):$(STREAMS_NETWORK_TOOLKIT):$(STREAMS_INET_TOOLKIT)
endif

# We are in Cloud Pak for Data environment: do not use data directory
build: geofiles
	$(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --output-dir $(OUTPUT_DIR) $(SPL_CMD_ARGS)

build-clean:
	$(SPLC) -C $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --output-dir $(OUTPUT_DIR) -C $(SPL_CMD_ARGS)
	rm -rf output

geofiles:
	mkdir -p etc/geo
	unzip -ou geo/mergedIBMandMaxmindData.zip -d etc/geo

geofiles-clean:
	rm -rf etc/geo

all: clean build

clean: build-clean geofiles-clean

	