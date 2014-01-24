
function noSelectionErrors() {
	switch($('#observed_location').val()) 
	{
		case 'address':
			address = $('#address').val();
			if (address == '') {
				alert('You must enter an address')
				return false;
			}
			break;
		case 'current':
			return true;
			break;
		case 'map':
			if ($('#latitude').val() == '' || $('#longitude').val() == '') {
				alert('We are unable to retrieve the map data');
				return false;
			}
			address = $('#latitude').val() + ', ' + $('#longitude').val();
			break;
		default:
			alert('You must select a location type');
			return false;
	}

	return true;
}

function getPostData() {
	var address;
	var address_type = $('#observed_location').val();
	switch($('#observed_location').val()) 
	{
		case 'address':
			address = $('#address').val();
			break;
		case 'current':
			if (locationShared) {
				address = $('#latitude').val() + ', ' + $('#longitude').val();
			}
			else {
				address_type = 'ip';
			}
			break;
		case 'map':
			address = $('#latitude').val() + ', ' + $('#longitude').val();
			break;
	}
	
	return { address: address, day: $('#day').val(), month: $('#month').val(),  page: page, observed_location: address_type  }
}

function addObservations(data) {
	
	if (page ==  1) {
		var map = createMap('#search_location_map_canvas', null, null);
		//createMap_setMapBounds('#search_location_map_canvas');
		locationSelector_addAllMarkers('#search_location_map_canvas', data);
		google.maps.event.trigger(map, 'resize');
		locationSelector_markerDescriptions('#search_location_map_canvas');
	}
}