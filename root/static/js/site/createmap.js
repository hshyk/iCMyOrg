var currLat;
var currLong;

function createMap(divId, latitude, longitude, zoom) {
	
	var latlng;
	var zoom;

	if (createMap_isNumber(latitude) && createMap_isNumber(longitude)) {
		latlng = new google.maps.LatLng(latitude,longitude);
		if (zoom) {
			zoom = 8;
		}
		else {
			zoom = 5;
		}
	}
	else {
		latlng = new google.maps.LatLng(0,0);
		zoom = 1;
	}

	
	return $(divId).gmap({'zoom':zoom, 'center': latlng, zoomControlOptions: {
    	style: google.maps.ZoomControlStyle.LARGE
	  } }).bind('init');
	

}

function createMap_addMovablePointToMap(divId) {
	
	 var map = $(divId).gmap('get', 'map');
	 $(map).addEventListener('click', function(event) {
		$(divId).gmap('clear', 'markers');
		$(divId).gmap('addMarker', {
			'position': event.latLng, 
			'draggable': false, 
			'bounds': false
		}, function(map, marker) {
			$('#latitude').val(marker.getPosition().lat());
			$('#longitude').val(marker.getPosition().lng());
		});
	});
}

function createMap_SetZoomTimer(divId, zoom) {
	window.setTimeout(
	'createMap_SetZoom(\''+divId+'\', '+zoom+')'
	,600);
	
}

function createMap_SetZoom(divId, zoom) {
	var map=$(divId).gmap('get','map');
	map.setZoom(zoom);
}


/*
function createMap_setMapBounds(divId) {
	
	var strictBounds = new google.maps.LatLngBounds(
     
     new google.maps.LatLng(,),
	 new google.maps.LatLng(,)
   );
	
	var map = $(divId).gmap('get', 'map');

   // Listen for the dragend event
   $(map).addEventListener('dragend', function() {
     if (strictBounds.contains(this.getCenter())) return;

     // We're out of bounds - Move the map back within the bounds

     var c = this.getCenter(),
         x = c.lng(),
         y = c.lat(),
         maxX = strictBounds.getNorthEast().lng(),
         maxY = strictBounds.getNorthEast().lat(),
         minX = strictBounds.getSouthWest().lng(),
         minY = strictBounds.getSouthWest().lat();

     if (x < minX) x = minX;
     if (x > maxX) x = maxX;
     if (y < minY) y = minY;
     if (y > maxY) y = maxY;

     this.setCenter(new google.maps.LatLng(y, x));
   });
}
*/
function createMap_addMapPin(divId, content) {
	return function() {
		$(divId).gmap('openInfoWindow', {'content': content}, this);
	}
}

function createMap_addallMapMarkers(divId, markers) {
	for (var marker = 0; marker < markers.length; marker++) {	
		$(divId).gmap('addMarker', {'position': markers[marker]['position'], 'icon': markers[marker]['icon'],  'bounds': true}).click(createMap_addMapPin(divId, markers[marker]['content']));
	}

}



function createMap_isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}