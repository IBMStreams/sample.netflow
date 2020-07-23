.PHONY: all distributed clean 

TOOLKITS_PATH = $(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.network:$(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.inetserver:$(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.inet:$(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.jdbc


SPLC_FLAGS ?= -a
SPLC = $(STREAMS_INSTALL)/bin/sc

SPL_CMD_ARGS ?= --data-directory=data -t $(TOOLKITS_PATH)
SPL_MAIN_COMPOSITE = application::NetflowViewer


all: distributed

distributed:
# unzip geo files
	mkdir -p etc/gep; unzip -o geo/mergedIBMandMaxmindData.zip -d etc/geo;
	JAVA_HOME=$(STREAMS_INSTALL)/java $(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) $(SPL_CMD_ARGS)
#	output/bin/standalone

clean: 
	$(SPLC) $(SPLC_FLAGS) -C -M $(SPL_MAIN_COMPOSITE)
	rm -rf output

