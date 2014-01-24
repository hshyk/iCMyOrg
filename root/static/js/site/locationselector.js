var currLat;
var currLong;
var locationShared = false;

function locationSelector()
{
	locationSelector_initializeGeo();
	$('#address').attr('style', 'visibility:hidden;');
}

function locationSelector_showOptions(selectdivId, mapdivId, lat, long, zoom) {
	
	locationSelector_showLocationOptions($(selectdivId).val(), mapdivId, lat, long, zoom);
	$(selectdivId).change(function() {
		locationSelector_showLocationOptions($(selectdivId).val(), mapdivId, lat, long, zoom);
	})
}

function locationSelector_initializeGeo() {
	$.geolocation.getCurrentPosition(success_callback, error_callback, {enableHighAccuracy:true});
}

function locationSelector_showLocationOptions(typeOfLocation, mapdivId, lat, long, zoom) {
	$("label[for=address]").attr('style', 'display:none;');
	$('#address').attr('style', 'display:none;');
	$("label[for=previous_locations]").parent().attr('style', 'display:none;');
	$(mapdivId).remove();

	switch(typeOfLocation){
		case 'current':	
	  		break;
		case 'address':
	 		$("label[for=address]").attr('style', 'display:block;');
			$('#address').attr('style', 'display:block;'); 
	  	break;
		case 'map':
			$('#latitude').val('');
			$('#longitude').val('');
			$("label[for=address]").after('<p>&nbsp;</p><div id="'+mapdivId.replace("#", "")+'"style="width: 100%; height: 300px;"></div><p>&nbsp;</p>');
			var map = createMap(mapdivId, lat, long, zoom);
			//createMap_setMapBounds(mapdivId);
			createMap_addMovablePointToMap(map, mapdivId);	
	 	break;
		case 'previous':
			$("label[for=previous_locations]").parent().attr('style', 'display:block;');
			break;
		default:
			$('#latitude').val('');
			$('#longitude').val('');
	}
}



function locationSelector_addAllMarkers(divId, data) {
	$(divId).gmap('clear', 'markers');
	$(divId).attr('style', 'width:100%;height:300px;');

	$.each (data, function(key, value) {
		var position = +value['latitude']+', '+value['longitude'];
		var icon = mapMarkers[value['type']]['icon'];
		var content = '';
		var file = '';
		
		if (value['image_id'] > 0 ) {
			file = value['filename'] + "/thumb.jpg";
		}
		else {
			file = value['filename']
		} 
			
		content += "<div style='float:left;padding-right: 5px;'>" +
				"<a href='" + value['url'] + "' />" +
				"<img src='" +file + "'>" +
				"</a></div><span style='font-size: 12px;'>"+
				"<strong><a href='" + value['url'] + "' />" + value['common_name'] + "</a></strong><br />" +
				"" + value['date_observed'] + "<br />";
		if (value['observed_by'] != undefined) {
			content += "Observed By: " + value['observed_by'];
		}
		content += "</span></div>";
				
		$(divId).gmap('addMarker', {'position': position, 'icon': icon,  'bounds': true}).click(createMap_addMapPin(divId, content));
	});	  
}

function locationSelector_markerDescriptions(divId) {
	
	$('#markerdescriptions').remove();
	$(divId).parent().after('<div id="markerdescriptions" style="padding-top: 10px;"></div>');

	for (var key in mapMarkers) {
		$('#markerdescriptions').append('<img src="'+mapMarkers[key]['icon']+'" /> - '+mapMarkers[key]['description']+'<br />');
	}

}


function success_callback(p) {
	currLat = p.coords.latitude;
	currLong = p.coords.longitude;
	$('#latitude').val(p.coords.latitude);
	$('#longitude').val(p.coords.longitude);
	locationShared = true;
}

function error_callback(p) {
	//$("#observed_location option[value='current']").remove();
	locationShared = false;
	$('#latitude').val('');
	$('#longitude').val('');
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

