// ------------------------- global constants  -----------------

var socketPort = Number(location.port); // port for data stream's WebSocket
var socketRetryTime = 1000; // how often to try connecting to a WebSocket, in milliseconds 

var connectedImage = "images/greenCheck.png"; // image to display for connected streams
var disconnectedImage = "images/redX.png"; // image to display for disconnected streams
var waitingImage = "images/waiting.gif"; // image to display while waiting for images

//var sourceCoordinates = [41.209447, -73.801918];
// Berlin
var sourceCoordinates = [52.409184, 13.368369];
var yorktownSize = 1;

var markers = {};

var opacityConnected = 0.5;
var opacityFadeoutStep = 0.05;
var opacityFadeoutInterval = 100;

// ------------------------- location stream handler ------------------------------------------

function processLocationStream(socket) {

	// create a web socket to receive data tuples from Streams
	var url = "ws://" + (location.host.split(":", 1))[0] + ":" + socket
			+ "/LocationStreamSocket/ports/input/0/wssend";
	var websocket = new WebSocket(url);

	// display initial icons and status messages
	$("#titleStatus").attr({
		title : "waiting for " + url,
		src : disconnectedImage
	});

	// this function will be executed when the web socket connects to Streams
	websocket.onopen = function() {
		$("#titleStatus").attr({
			title : "connected to " + websocket.url,
			src : connectedImage
		});
	};

	// this function will be executed when the web socket disconnects from Streams
	websocket.onclose = function(event) {

		for ( var location in markers) {
			var marker = markers[location];
			markerGroup.removeLayer(marker.circle);
			markerGroup.removeLayer(marker.line);
			delete markers[location];
		}

		$("#titleStatus").attr({
			title : "disconnected from " + websocket.url,
			src : disconnectedImage
		});

		setTimeout(function() {
			processLocationStream(socket);
		}, socketRetryTime);
		websocket = null;
	};

	// this function will be executed when an error occurs on the web socket
	websocket.onerror = function() {
	}

	// this function will be executed when the web socket receives a tuple from Streams
	websocket.onmessage = function(event) {

		// decode the message from Streams
		var data = JSON.parse(event.data);
		//	    if (!data.tuples) return;
		// console.log(JSON.stringify(data, null, "    "));

		if (!data.hasOwnProperty('tuple'))
			return;

		var country = data.tuple.country;
		var stateprovince = data.tuple.stateprovince;
		var city = data.tuple.city;
		var latitude = data.tuple.dstLatitude;
		var longitude = data.tuple.dstLongitude;
		var srcLatitude = data.tuple.srcLatitude;
		var srcLongitude = data.tuple.srcLongitude;
		sourceCoordinates = [srcLatitude, srcLongitude];
		var flowDuration = data.tuple.flowDuration;
//		var flowRate = data.tuple.flowRate;
		var flowRate = 40.0;

		var location = country + stateprovince + city;

		// console.log("all values " + location + " " 	+ latitude + " " + longitude + " " + flowDuration + " " + flowRate);

		// get current geographical bounds of visible area on map
		var bounds = map.getBounds();
		// return;       
		// handle each data tuple in this message
		//	    data.tuples.forEach( function(tuple) { 
		//	    data.forEach( function(tuple) { 
		if (!bounds.contains(sourceCoordinates)
					&& !bounds.contains([latitude,
							longitude]))
				return;

			if (location in markers) {
				var marker = markers[location];
				var scale = Math.log10(flowRate);
				marker.circle.setRadius(scale);
				marker.line.setStyle({
					weight : scale
				});
				var when = Date.now() + flowDuration * 1000;
				if (marker.timeout < when) {
					// console.log("extending " + location + " for " + flowDuration + " seconds at " + flowRate + " bytes/second");
					marker.timeout = when;
				}
				if (marker.opacity < opacityConnected) {
					// console.log("restoring " + location + " for " + flowDuration + " seconds at " + flowRate + " bytes/second");
					marker.opacity = opacityConnected;
					marker.circle.setStyle({
						fillOpacity : marker.opacity
					});
					marker.line.setStyle({
						opacity : marker.opacity
					});
				}

			} else {
				var when = Date.now() + flowDuration * 1000;
				var where = [latitude, longitude];
				var label = city != ""
						? city
						: stateprovince != ""
								? stateprovince
								: country != ""
										? country
										: "unknown";
				var shade = latitude == 0
						&& longitude == 0
						? "gray"
						: city.substr(0, 3) == "IBM"
								? "blue"
								: "green";
				var scale = Math.log10(flowRate);
				var o = opacityConnected;
				var marker = {
					coordinates : where,
					opacity : o,
					rate : flowRate,
					timeout : when,
					circle : L.circleMarker(where, {
						radius : scale,
						stroke : false,
						fillColor : shade,
						fillOpacity : opacityConnected
					}),
					line : L.polyline([sourceCoordinates, where], {
						weight : scale,
						color : shade,
						opacity : opacityConnected
					}),
				};
				marker.circle.bindLabel(label, {
					className : "location-label-" + shade,
					offset : [0, 0],
					direction : longitude < sourceCoordinates[1]
							? "left"
							: "right",
					opacity : 1.0,
					noHide : true
				});
				marker.circle.addTo(markerGroup);
				marker.line.addTo(markerGroup);
				markers[location] = marker;
				//console.log("added " + location + " for " + flowDuration + " seconds at " + flowRate + " bytes/second");
			}

	//	});
	};
}

// ------------------------- fadeout timer handler ------------------------------------------

function processFadeout() {

	//console.log("fadeout timer popped ...");
	var now = Date.now();
	var sumRate = 0;
	for ( var location in markers) {
		var marker = markers[location];
		sumRate += marker.rate;
		if (now < marker.timeout)
			continue;

		if (marker.opacity > opacityFadeoutStep) {
			marker.opacity = marker.opacity - opacityFadeoutStep;
			marker.circle.setStyle({
				fillOpacity : marker.opacity
			});
			marker.line.setStyle({
				opacity : marker.opacity
			});
			continue;
		} else {
			markerGroup.removeLayer(marker.circle);
			markerGroup.removeLayer(marker.line);
			delete markers[location];
			//console.log("deleted location " + location);
		}
	}

	var s = Math.round(Math.log(sumRate));
	if (s != yorktownSize) {
		//console.log("setting Yorktown rate to " + s);
		yorktownMarker.setRadius(s);
		yorktownSize = s;
	}
}

// ------------------------ create map and imagery tile layers -------------------------------------------

// get today's and yesterday's dates in "YYYY-MM-DD" format
var date = new Date();
var today = date.toISOString().split("T")[0];
date.setTime(Date.now() - 24 * 60 * 60 * 1000);
var yesterday = date.toISOString().split("T")[0];

// create map layers for various tile servers

var OpenStreetMapLayer = L
		.tileLayer(
				"http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
				{
					attribution : 'map &copy; <a href="http://openstreetmap.org/">OpenStreetMap</a>',
					maxZoom : 18
				});

var NasaViirsCityLights2012Layer = L
		.tileLayer(
				'http://map1.vis.earthdata.nasa.gov/wmts-webmerc/VIIRS_CityLights_2012/default//GoogleMapsCompatible_Level8/{z}/{y}/{x}.jpg',
				{
					attribution : 'imagery &copy; <a href="https://earthdata.nasa.gov">NASA</a>',
					maxZoom : 8
				});

var NasaModisTodayLayer = L
		.tileLayer(
				'http://map1.vis.earthdata.nasa.gov/wmts-webmerc/MODIS_Terra_CorrectedReflectance_TrueColor/default/{date}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.jpg',
				{
					attribution : 'imagery &copy; <a href="https://earthdata.nasa.gov">NASA</a>',
					date : today,
					maxZoom : 9
				});

var NasaModisYesterdayLayer = L
		.tileLayer(
				'http://map1.vis.earthdata.nasa.gov/wmts-webmerc/MODIS_Terra_CorrectedReflectance_TrueColor/default/{date}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.jpg',
				{
					attribution : 'imagery &copy; <a href="https://earthdata.nasa.gov">NASA</a>',
					date : yesterday,
					maxZoom : 9
				});

var EsriTopographyLayer = L
		.tileLayer(
				'http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
				{
					attribution : 'map &copy; <a href="https://www.esri.com/">Esri</a>'
				});

var EsriSatelliteImageLayer = L
		.tileLayer(
				'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
				{
					attribution : 'imagery &copy; <a href="https://www.esri.com/">Esri</a>'
				});

// create labels for map layers
var mapLayers = {
	"NASA 'true color' satellite image (today)" : NasaModisTodayLayer,
	"NASA 'true color' satellite image (yesterday)" : NasaModisYesterdayLayer,
	"NASA 'city lights' satellite image (2012)" : NasaViirsCityLights2012Layer,
	"ESRI topography map" : EsriTopographyLayer,
	"ESRI composite satellite image" : EsriSatelliteImageLayer,
	"Open Street Map" : OpenStreetMapLayer,
};

// ------------------------ draw the map ------------------------------------------------------

// draw the basic map
var map = L.map('map', {
	// North Amerika
	//center : [37.8, -96.9],
	//zoom : 4,
	// World
	center : [15, 0],
	zoom : 3,
	fullscreenControl : true
});
//OpenStreetMapLayer.addTo(map);
EsriTopographyLayer.addTo(map);

// draw map tile and imagery layer control
L.control.layers(mapLayers).addTo(map);

// create a layer group for location markers
var markerGroup = L.layerGroup();
markerGroup.addTo(map);

// create a layer group for IBM Yorktown
var yorktownMarker = L.circleMarker(sourceCoordinates, {
	radius : yorktownSize,
	stroke : false,
	fillColor : 'SkyBlue',
	fillOpacity : 1.0
});
//yorktownMarker.bindLabel("IBM Yorktown", {
	yorktownMarker.bindLabel("IBM Berlin", {
	className : "location-label-blue",
	offset : [0, 0],
	opacity : 1.0,
	noHide : true
});
var yorktownGroup = L.layerGroup([yorktownMarker]);
yorktownGroup.addTo(map);

// ------------------------ clickable HTML objects ------------------------------------------------------

$(document).tooltip();

$('#titleOverlay').appendTo('#map');

// zoom and re-center the map when focus buttons are clicked
$('#focusOverlay').appendTo('#map');
$('#focusOverlay input[type=submit]').click(function(event) {
	var coordinates = $(this).data("coordinates").trim().split(/ +/);
	map.setView([coordinates[0], coordinates[1]], coordinates[2]);
});

// toggle the information overlay on and off when the 'information' icon is clicked
$('#informationOverlay').appendTo('#map');
$("#informationIcon").click(
		function() {
			$("#informationOverlay").attr(
					{
						class : $("#informationOverlay").hasClass(
								"informationOverlayHidden")
								? "informationOverlayVisible"
								: "informationOverlayHidden"
					});
			if ($("#informationOverlay").hasClass("informationOverlayVisible"))
				$("#informationOverlay").width(
						$("#informationOverlay img").width());
		});
$("#informationOverlay").click(function() {
	$("#informationOverlay").attr({
		class : "informationOverlayHidden"
	});
});

// toggle the credits overlay on and off when the 'credits' icon is clicked
$('#creditsOverlay').appendTo('#map');
$("#creditsIcon").click(
		function() {
			$("#creditsOverlay").attr(
					{
						class : $("#creditsOverlay").hasClass(
								"creditsOverlayHidden")
								? "creditsOverlayVisible"
								: "creditsOverlayHidden"
					});
			if ($("#creditsOverlay").hasClass("creditsOverlayVisible"))
				$("#creditsOverlay").width($("#creditsOverlay img").width());
		});
$("#creditsOverlay").click(function() {
	$("#creditsOverlay").attr({
		class : "creditsOverlayHidden"
	});
});

//map.on( 'click', function(e) { alert("mouse click at " + e.latlng + ", map center at " + map.getCenter() + ", zoom level " + map.getZoom()); } );

// ------------------------ start processing ------------------------------------------------------

setInterval(processFadeout, opacityFadeoutInterval);

processLocationStream(socketPort);
