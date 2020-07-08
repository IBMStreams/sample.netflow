.PHONY: all distributed clean 

TOOLKITS_PATH = $(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.network:$(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.inetserver:$(STREAMS_INSTALL)/toolkits/com.ibm.streamsx.inet


SPLC_FLAGS ?= -a
SPLC = $(STREAMS_INSTALL)/bin/sc

SPL_CMD_ARGS ?= --data-directory=data -t $(TOOLKITS_PATH)
SPL_MAIN_COMPOSITE = application::NetflowCollector


all: distributed

distributed:
# unzip geo files
	JAVA_HOME=$(STREAMS_INSTALL)/java $(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) $(SPL_CMD_ARGS)
#	output/bin/standalone

clean: 
	$(SPLC) $(SPLC_FLAGS) -C -M $(SPL_MAIN_COMPOSITE)
	rm -rf output

