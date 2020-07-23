# sample.netflow

This sample collects and aggregates network traffic data from IP routers or L3 switches. 
The Netflow Collector parses Netflow messages and aggregates the transferred data sizes per source/destination/protocol. 
The aggregation time interval can be configured. 
The Netflow Viewer visualizes the aggregated data, including the geographical locations of source and destination.

This repository contains artifacts for 2 different applications `NetflowCollector` and the `NetflowVieWer`.

## Netflow Sample

The Netflow Sample is a is simple out of the box running demonstration for an application that collects network statistics and presents them centrally in a web display. The Netflow Sample is composed of 2 jobs; the `NetflowCollector` and the `NetflowVieWer`.

### NetflowCollector

* The `NetflowCollector` collects the Netflow data from the Edge devices, makes the first data aggregation and transmits the data to `NetflowViewer`
* The connection from `NetflowCollector` to `NetflowViewer` is currently a HTTP Post and requires the Endpoint-Monitor application on CP4D,

### NetflowViewer

* The `NetflowViewer` translates the IP addresses into location data, makes the final data aggregation and provides the “Views” for a Web-Browser.
* The `NetflowViewer` provides a raw data view, the Location Stream View and the Netflow View.
* Due to connection limitations (no websocket connections), the Netflow View is currently not available in CP4D

## Netflow Demo

The Netflow Demo is a demonstration for an application that collects network statistics and puts them in a central database, the Netflow Demo is composed of 2 Streams Jobs: `NetflowStore` and `NetflowStoreCollector`.

### NetflowStoreCollector

* The `NetflowStoreCollector` collects the Netflow data from the router and makes the data aggregation and transmits the data to `NetflowStore`.
* One or more  `NetflowStoreCollector` job are located in every datacenter.
* The connection from `NetflowStoreCollector` to `NetflowStore` is currently a HTTP Post and requires the Endpoint-Monitor application on CP4D,
* The application logic is able to compensate network outages up to a certain amount of time

### NetflowStore

* The `NetflowStore` pushes the netflow information into a database.
* The `NetflowStore` provides a raw data view of the pushed data and a web page with some statistics information.

## Requirements

This application requires the following Streams toolkits:

* com.ibm.streamsx.network version 3.2.1 or higher
* com.ibm.streamsx.inet version 3.1.0 or higher
* com.ibm.streamsx.inetserver version 4.3.2 or higher
* com.ibm.streamsx.jdbc version 1.6.0

## How to build

### Command line build

Clone the repository or download the source archive.
Move to the project directories NetflowCollector, NetflowStore, NetflowStoreCollector, NetflowViewer. Execute command `make`.

The build scripts assume that the toolkits are installed in ${STREAMS_INSTALL}/toolkits/
You can overwrite the default toolkit locations by setting environments STREAMS_NETWORK_TOOLKIT, STREAMS_INET_TOOLKIT, STREAMS_INETSERVER_TOOLKIT and STREAMS_JDBC_TOOLKIT

### Build with Stremas Studio

Clone the repository or download the source archive.
Import all existing projects to your workspace.
Make sure that all required toolkits are listed in *Streams Explorer*
Right click the project and select `Build`


## Use the Netflow Sample

Submit first the `NetflowViewer` job and provide the webserver port as submission time parameter. If the port is not provided, the default 6060 is used.

Submit the `NetflowCollector` job and provide the url of your `NetflowViewer` job as submission time parameter.

The url of the `NetflowCollector` is:

* OnPrem http://\<hostname\>:\<webserver port\>/InjectedTuples/ports/output/0/inject
* CP4D   https://\<exposed route of streams-endpoint-monitor\>/\<job name\>/InjectedTuples/ports/output/0/inject

If the `NetflowCollector` job has no job name you must substitute \<job name\> with streams/jobs/\<jobid\>

To view the Location Stream View open with your browser the url:

* OnPrem http://\<hostname\>:\<webserver port\>/LocationStreamView/ports/input/0/tuples
* CP4D   https://\<exposed route of streams-endpoint-monitor\>/\<job name\>/LocationStreamView/ports/input/0/tuples

To view the Netflow visualization open with your browser the url:

* OnPrem http://\<hostname\>:\<webserver port\>/NetflowViewer
* CP4D   not available

