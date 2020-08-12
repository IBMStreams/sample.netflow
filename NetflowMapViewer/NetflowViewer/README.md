# NetflowViewer
Streams Netflow Viewer demonstration

Streams Netflow Viewer uses the following streams opeartors:
- **PacketLiveSource**:
 PacketLiveSource is an operator for the IBM Streams product that captures live network 
 packets from an ethernet interface, parses their network headers, and emits tuples 
 containing packet data. The operator may be configured with one or more output ports, 
 and each port may be configured to emit different tuples, as specified by output filters. 
 The tuples may contain the entire packet, the payload portion of the packet, or 
 individual fields from the network headers, as specified by output attribute assignments. 

- **NetflowMessageParser**
 NetflowMessageParser is an operator for the IBM Streams product that parses individual 
 fields of Netflow messages received in input tuples, and emits tuples containing message 
 data. The operator may be configured with one or more output ports, and each port 
 may be configured to emit different tuples, as specified by output filters. 
 The tuples contain individual fields from the input message, as specified by 
 output attribute assignments. 
 
- **IPAddressLocation**
 IPAddressLocation is an operator for the IBM Streams product that finds the geographical location of 
 IP addresses received in input tuples, based on the subnets they are part of, and emits output tuples containing the country, 
 state or province, city, latitude, and longitude of the subnets. The operator may be configured with one or more output ports, 
 and each port may be configured to emit different tuples, as specified by output filters.
 The IPAddressLocation operator consumes input tuples containing IP version 
 4 and 6 addresses, selects messages to emit as output tuples with filter expressions, 
 and assigns values to them with 
 output attribute assignment expressions. Output filters and attribute assignments are SPL expressions. 
 They may use any of the built-in SPL functions, and any of these functions, 
 which are specific to the IPAddressLocation operator: 
 
- **WebSocketSend**
 WebSocketSend Operator transmits tuples received on the input port via WebSocket protocol to 
 connected clients. Upon startup, this operator is registered to the common pe-wide 
 jetty web server. 
 Clients may connect to the websocket context under /input/0/wssend. 
 As tuple arrives on the input port a message is triggered and transmitted to all currently connected clients. 
 Clients can connect and disconnect at any time. 
   
- **WebContext**
 WebContext embeds a Jetty web server to provide HTTP or HTTPS REST access to files defined 
 by the context and contextResourceBase parameters. 
 Limitations: default no security access is provided to the data, HTTPS must be explicitly configured.
    


# Requirements
This SPL application requires the following packages installed
* `streamsx.network` , `streamsx.inet` and `streamsx.inetserver` installed in `$STREAMS_INSTALL/toolkits`.
* `libcurl` (version 7.19.7 or higher) installed.
* Developers needs additionally the `libcurl-devel`.
* `opnessl`
* Developers needs additionally the `openssl-devel` package.
* `libpcap` (version 1.8.1 or higher) installed.
* Developers needs additionally the `libpcap-devel-1.8` package.

# Directories

## sample.netflow.viewer
The SPL namespace directory. The SPL-application is located in this directory.

`sample.netflow.viewer/NetflowViewer.spl`

## geo
The directory contains the GeLite2 Database archive.

## etc/geo
GeLite2 Database files are located in `etc/geo` directory.
```
geo/mergedIBMandMaxmindData.zip
geo/GeoLite2-City-Blocks-IPv4.csv
geo/GeoLite2-City-Blocks-IPv6.csv
geo/GeoLite2-City-Locations-en.csv
```

You can download the updated GeLite2 Database from Maxmind.

You now need an account at Maxmind to download the GeLite2 Database.

https://www.maxmind.com/en/accounts/332295/geoip/downloads

## opt/web
The Java scrips and html files are located in `web` directory.

Lits of java scripts:

### NetflowViewer.js
The main java script is `NetflowViewer.js`.

The script `NetflowViewer.js` creates a web socket to receive data tuples from Streams. 

`function processLocationStream(socket)`


### Leaflet.fullscreen
Leaflet is the leading open-source JavaScript library for mobile-friendly interactive maps.

https://github.com/Leaflet/Leaflet.fullscreen

### Leaflet.label
Leaflet.label is plugin for adding labels to markers & shapes on leaflet powered maps. 

https://github.com/Leaflet/Leaflet.label

### JQuery-UI
JQuery_Ui is a collection of animated visual effects, GUI widgets, and themes implemented with jQuery, CSS, HTML and JavaScript.

https://jqueryui.com/

### D3
D3 is a JavaScript library for visualizing data with HTML, SVG, and CSS.

https://d3js.org/

### strftime
strftime is a JavaScript supports localization and timezones. 

https://github.com/samsonjs/strftime


It is possible to show the results of demo in an internet browser.
`your-host-name:6060/NetflowViewer/`


## script
The shell scripts are located in script directory.
```
script/getMaxmindLocationData.sh
script/logthis.sh
script/runNetflowViewer.sh
```
`runNetflowViewer.sh` makes the SPL application and starts the standalone file.

`output/unbundle/NetflowViewer/NetflowViewer/bin/standalone`

Befor you start the application you have to check:

1- The path of libpcap-1.8.1 library.

`libpcapDirectory=$HOME/libpcap-1.8.1`

2 - unzip the geo database file.

```
 cd geo
 unzip mergedIBMandMaxmindData.zip
```

3- Change the name of netwerk interface with your test system.

You can find the name of your network interface vi `ifconfig` command.

`networkInterface=eno1`

The script `runNetflowViewer.sh` starts a Jetty web server to provide HTTP.

It takes about 2 minutes to load IP subnets data from:

`./geo/GeoLite2-City-Blocks-IPv4.csv` and 
`./geo/GeoLite2-City-Blocks-IPv6.csv` files.

Now you can check the results in a web browser.

`your-host-name:6060/NetflowViewer/`
