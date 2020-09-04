# sample.netflow

This repository contains artifacts for 2 different applications [Netflow Map Viewer Application](README.md#netflow-map-viewer-application) and the [Netflow To Database Application](README.md#netflow-to-database-application).

Both applications simulate the collection of network traffic data from IP routers or L3 switches. 
The Netflow messages are parsed and the data volume is aggregated. The transferred data volumes per source/destination/protocol-group is transferred 
from the collector job to the viewer or store job. 
The aggregation time interval can be configured. 
The Netflow Map Viewer Application visualizes the aggregated data, including the geographical locations of source and destination. 
The Netflow To Database Application stores the aggregated data into a database.

## Netflow Map Viewer Application

The Netflow Map Viewer Application is a is simple out of the box running demonstration for an application that simulates the collection of network 
statistics and presents them centrally in a web display. The Netflow Map Viewer Application is composed of 2 jobs; the `NetflowViewerCollector` and the `NetflowViewer`.

### NetflowViewerCollector

* The `NetflowViewerCollector` simulates the collection of Netflow data from Edge devices, makes the first data aggregation and transmits the data to `NetflowViewer`.
* The connection from `NetflowViewerCollector` to `NetflowViewer` is currently a HTTP Post and requires the Endpoint-Monitor application in Cloud Pak for Data.

### NetflowViewer

* The `NetflowViewer` translates the IP addresses into location data, makes the final data aggregation and provides the “Views” for a Web-Browser.
* The `NetflowViewer` provides a raw data view, the Location Stream View and the Netflow View.
* Due to connection limitations (no websocket connections), the Netflow View is currently not available in Cloud Pak for Data.

## Netflow To Database Application

The Netflow To Database Application is a demonstration for an application that collects network statistics and puts them in 
a central database, the Netflow To Database Application is composed of 2 Streams Jobs: `NetflowStore` and `NetflowStoreCollector`.

**Note:** The Netflow To Database Application is still under construction.

### NetflowStoreCollector

* The `NetflowStoreCollector` collects the Netflow data from the router and makes the data aggregation and transmits the data to `NetflowStore`.
* One or more  `NetflowStoreCollector` job are located in every datacenter.
* The connection from `NetflowStoreCollector` to `NetflowStore` is currently a HTTP Post and requires the Endpoint-Monitor application on Cloud Pak for Data.
* The application logic is able to compensate network outages up to a certain amount of time.

### NetflowStore

* The `NetflowStore` pushes the netflow information into a database.
* The `NetflowStore` provides a raw data view of the pushed data and a web page with some statistics information.

## Requirements

This application requires the following Streams toolkits:

* com.ibm.streamsx.network version 3.2.1 or higher
* com.ibm.streamsx.inet version 3.3.0 or higher
* com.ibm.streamsx.inetserver version 4.3.2 or higher

Additionally the Netflow To Database Application requires toolkit:
* com.ibm.streamsx.jdbc version 1.6.0

## How to build

### Build from Command Line

Clone the repository or download the source archive.
Move to the project directories NetflowViewerCollector, NetflowViewer, NetflowStore or NetflowStoreCollector and execute command `make`.

The build scripts assume that the toolkits are installed in ${STREAMS_INSTALL}/toolkits/
You can overwrite the default toolkit locations by setting environments STREAMS_NETWORK_TOOLKIT, STREAMS_INET_TOOLKIT, STREAMS_INETSERVER_TOOLKIT and STREAMS_JDBC_TOOLKIT

### Build with Streams Studio

Clone the repository or download the source archive.
Import all existing projects to your workspace.
Make sure that all required toolkits are listed in *Streams Explorer*
Right click the project and select `Build`

### Build the NetflowViewer with VsCode and IBM Streams extension

* Clone the repository or download the source archive.
* Open the `Explorer View` and right click the workspace and select `Add Folder to Workspace`. Navigate to your project 
directory, go to sub-directory `NetflowMapViewer/NetflowViewer` and select `add`.
* In the `Streams Explorer` connect to a Streams Instance, enter the credentials and refresh the toolkit list.
* Go back to the `Explorer View`.
* In the project directory right click the `Makefile` and select `build`.

Now the sab-file is built and loaded to the output directory. If the request times out open the `Extension View`, select 
the *IBM Streams* extension and open the `Extension Settings`. Increase the variable `Timeout For Requests`.

### Build the NetflowViewerCollector with VsCode and IBM Streams extension

If you want to run this job in an Micro Edge System omit this step and goto 
[Build the Edge Application Image NetflowViewerCollector with VsCode and IBM Streams extension](README.md#build-the-edge-application-image-netflowviewercollector-with-vscode-and-ibm-streams-extension)

* Clone the repository or download the source archive.
* Open the `Explorer View` and right click the workspace and select `Add Folder to Workspace`. Navigate to your project 
directory, go to sub-directory `NetflowMapViewer/NetflowViewerCollector` and select `add`.
* Go back to the `Explorer View`.
* In the project directory right click the `Makefile` and select `build`.

Now the sab-file is built and loaded to the output directory. If the request times out open the `Extension View`, select 
the *IBM Streams* extension and open the `Extension Settings`. Increase the variable `Timeout For Requests`.

### Build the Edge Application Image NetflowViewerCollector with VsCode and IBM Streams extension

If you want to run this job in a on premise Streams instance omit this step.

* Clone the repository or download the source archive.
* Open the `Explorer View` and right click the workspace and select `Add Folder to Workspace`. Navigate to your project 
directory, go to sub-directory `NetflowMapViewer/NetflowViewerCollector` and select `add`.
* Open the file `NetflowViewerCollector` and replace the default value of the `url` parameter according to your needs. see [Url Configuration](README.md#url-configuration)
* In the `Streams Explorer` connect to a Cloud Pak for Data Streams instances with image build enabled, enter the credentials and refresh the toolkit list.
* Go back to the `Explorer View`.
* In the project directory right click the `Makefile` and select `Build Edge Application Image`. Now a editor window `Configure edge application image build for sample.netflow.viewer.NetflowViewerCollector.sab` opens.
* Select the checkbox `Create a sample file`.
* Select a base image with a name like *streams-base-edge-application..*
* Enter the image name: *streams-sample-netflow-collector* and a version tag: *v0.0.1*
* Select the `Configuration type` advanced and click `Create sample configuration file` and save the configuration file *buildconfig.json*.
* Open *buildconfig.json* file in an editor and append the line *"rpms": ["libpcap"]* (don't forget to add the comma in the previous line) and save the changes.
* Click `Build Image`

Now the edge application image is build an pushed into the Openshift Image registry. 

Now you must package the Edge application Image see (Packaging and edge app)[https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0/svc-edge/usage-register-app.html]

## Run Netflow Map Viewer Application

### Run the NetflowViewer job

If you run this sample in an Clod Pack for Data Streams Instance you must install the [Streams Endpoint Monitor](https://github.com/IBMStreams/endpoint-monitor) 
The [README.md](https://github.com/IBMStreams/endpoint-monitor/blob/develop/README.md) contains the installation instructions.  

The `NetflowViewer` requires a certain amount of memory for the ip-location database. If you are going to run this job on a Clod Pack for Data Streams instance, you must increase 
the default Memory limit to 4GiB for the Applocation pod of this instance.  

Submit first the `NetflowViewer` job and provide the webserver port as submission time parameter. If the port is not provided, the default 6060 is used.  
If this application is submitted to a Cloud Pak for Data instance, you should enter a job name for this job. The job name 
is used from the streams-endpoint-monitor to build the path to the web server.

### Run the NetflowViewerCollector job

Now you can start the NetflowViewerCollector job.

If you are using an on premise Streams instance, submit the `NetflowViewerCollector` job and provide the url of your `NetflowViewer` job as submission time parameter.

To start the NetflowViewerCollector on an Micro Edge System, use the packaged edge application image from 
[Build the Edge Application Image NetflowViewerCollector with VsCode and IBM Streams extension](README.md#Build-the-edge-application-image-netflowViewerCollector-with-vscode-and-ibm-streams-extension) and 
follow the steps in [Deploying and edge app](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0/svc-edge/usage-deploy.html)

### Url Configuration

The parameter url of the `NetflowViewerCollector` is:

* OnPrem              http://\<hostname\>:\<webserver port\>/InjectedTuples/ports/output/0/inject
* Cloud Pak for Data  https://\<exposed route of streams-endpoint-monitor\>/\<job name\>/InjectedTuples/ports/output/0/inject

If the `NetflowCollector` job has no job name you must substitute \<job name\> with streams/jobs/\<jobid\>

To view the Location Stream View open with your browser the url:

* OnPrem             http://\<hostname\>:\<webserver port\>/LocationStreamView/ports/input/0/tuples
* Cloud Pak for Data https://\<exposed route of streams-endpoint-monitor\>/\<job name\>/LocationStreamView/ports/input/0/tuples

To view the Netflow visualization open with your browser the url:

* OnPrem             http://\<hostname\>:\<webserver port\>/NetflowViewer
* Cloud Pak for Data not available
