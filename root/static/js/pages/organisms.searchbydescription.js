function loadDescriptionPage() {
	
	observationDateAdult();
	observationDate();
	//observationLocation();
	
	$("#description_add").click(function()
	{
		submitForm = true;
		description_id++;
		
		addDescriptionField(description_id);
		
		checkDescriptionButtons();						
	 });
	
	$("#description_remove").click(function()
	{
		submitForm = true;
		removeDescriptionField();
		if (description_id >= 2)
		{
			description_id--;
		}	

		checkDescriptionButtons();
			
	});

	for (i = 1; i <= description_id; i++)
	{
		descID = i+''
		
		addDescriptionField(descID);
	}
	
	pageLoad = false;
	
	checkDescriptionButtons();
	/*
	if(geo_position_js.init())
	{
		geo_position_js.getCurrentPosition(success_callback,error_callback,{enableHighAccuracy:true});
	}
	*/
	$('#character_type_id').change(function() {
		observationDateAdult();
		while (description_id > 0) {
			removeDescriptionField();
			description_id--;
			checkDescriptionButtons();
		}
		
		description_id++;
		addDescriptionField(description_id);
		getStates($('#characters1').val(), 1);
	});
	
	$('#observed_day').change(function() {
		observationDate();						   
	});
	
	/*$('#observed_location').change(function() {
		observationLocation();						   
	});*/
}

function observationDateAdult() {
	
	if ($("select[name=character_type_id] option:selected").text() != "Adult") {
		$('#observed_day').val("0");
		observationDate();
		//$('#observed_day').attr('style', 'visibility:hidden;');
		//$("label[for='observed_day']").attr('style', 'display:none;');	
		$('#observed_day').val('0');
		//$('#observed_day').attr("disabled", "disabled");
		var observeSel = $('#observed_day');
		if (jQuery.isFunction(observeSel.selectmenu)) {
			observeSel.selectmenu('disable');
			observeSel.selectmenu("disable", true);
		}
	}
	else {
		var observeSel = $('#observed_day');
		if (jQuery.isFunction(observeSel.selectmenu)) {
			observeSel.selectmenu('enable');
			observeSel.selectmenu("enable", true);
		}

		$("label[for='observed_day']").attr('style', 'display:block;');	
	}
}
function observationDate() {
	

	if ($('#observed_day').val() == 1) {
		$('.dayobserved').attr('style', 'display:table;');
		//$('#observed_date').attr('height', '200px;');
		$('#observed_daydiv').attr('style', 'margin-bottom:-20px;');
	}
	else {
		
	//	.addClass('ui-disabled');

		$('.dayobserved').attr('style', 'display:none;');
		//$('#observed_date').attr('height', '60px;');
		$('#observed_daydiv').attr('style', 'margin-bottom:0px;'); 
	}
	
}

function observationLocation() {

	if ($('#observed_location').val() == "address") {
		$('.locationobserved').attr('style', 'display:block;');
		//$('.locationobserved').attr('style', 'padding-top:-80px;');
	}
	else {
		$('.locationobserved').attr('style', 'display:none;');	
	}
	
}

function addDescriptionField(descID) {
	
	
	var d = '<label class="label">Choose a characterstic</label> ' + 
			'<select id="characters' + descID + '" name="characters' + descID + '">' + 
			'</select><br />';
			
	var stateSelect ='<div class="statevalues"  id="stateselect' + descID + '">' +
						'<label class="label">Choose a state for the characterstic</label>' +
					'<select id="states' + descID + '"  name="states' + descID + '">' + 
					'</select>' +
					'</div>';
			
	$('.all_descriptions').append('<div class="description" id="description_set' + descID +'">' + d +'</div>');
	$('#description_set' + descID).append(stateSelect);
		
	getCharacters(descID, $('#character_type_id').val());

	if (pageLoad) {
		$('#characters' + descID).val(userSelect['characters' + descID]);
	}
	
	if (submitForm == true) {
		getStates($('#characters' + descID).val(), descID.toString(), userSelect['states' + descID], userSelect['statevalue' + descID]);
	}
	

	$('#characters' + descID.toString()).change(function() {
		var state_id = $(this).attr('id').split("characters");

		//Due to IE issues (not properly populating list), 
		//need to remove the select and re-add it 
		$('#stateselect' + descID).remove();
		$('#description_set' + descID).append(stateSelect);
		
 		getStates($('#characters' + state_id[1]).val(), state_id[1]);
	});
	
	var charSel = $("#characters"+descID);
	if (jQuery.isFunction(charSel.selectmenu)) {
		charSel.selectmenu();
		charSel.selectmenu('refresh');
		charSel.selectmenu("refresh", true);
	}

	
	userSelect['characters' + descID] = "";
	userSelect['states' + descID] = "";
	userSelect['statevalue' + descID] = "";
	
}

function removeDescriptionField() {
	
	$('#description_set' + description_id).remove();
	
}

function checkDescriptionButtons() {

	if (description_id >= 2) {
		$('#description_remove').attr('style', 'display:block;');
	}
	else {
		$('#description_remove').attr('style', 'display:none;');
	}
		
	if (description_id <= 7) {
		$('#description_add').attr('style', 'display:block;');	
	}
	else {
		$('#description_add').attr('style', 'display:none;');	
	}
	
}


function getStates(character, descID, stateValue, descriptionValue) {
	
	$('#state_value' + descID).remove();
	$('#states' + descID)
    	.find('option')
    	.remove()
    	.end();

	$.post(stateURL,
		   { character: character },  
		 	function(data) {
				if (data['states'] != null) {  
					$.each (data['states'], function(key, value) {
						$('#states' + descID)
								.append($('<option>', { value : key })
								.text(value));	
						if (value.toLowerCase() == 'millimeters') {
							key =  key + "inches";
							$('#states' + descID)
								.append($('<option>', { value : key })
								.text('Inches'));
						}
					});
				}

				$('#states' + descID).html($("#states" + descID + " option").sort(function (a, b) {
    				return a.text == b.text ? 0 : a.text < b.text ? -1 : 1
				}));
				
				$('#states' + descID).val($("#target option:first").val());
				
				if (stateValue != null) {	
					$("#states" + descID).val(stateValue);
				}
				
				if (data['isnumeric'] == true) {
						if (descriptionValue == null) {
							descriptionValue = '';
						}
					$('#description_set' + descID).append('<div id="state_value' + descID + '">Enter a value for this state: <input type="text" id="statevalue' + descID + '" name="statevalue' + descID + '" value="' + descriptionValue + '"/></div>');
					var statevalueSel =  $("#statevalue"+descID);
					if (jQuery.isFunction(statevalueSel.textinput)) {
						statevalueSel.textinput();
					}
				}
				
					
				var stateSel = $("#states"+descID);
				if (jQuery.isFunction(stateSel.selectmenu)) {
				    stateSel.selectmenu();
				   	stateSel.selectmenu('refresh');
				    stateSel.selectmenu("refresh", true);
				
			    }
			});	
}

function getCharacters(descID, character_type) {

	$.each(characters, function(charID, charValues) {
		if (charID == character_type) {
			$.each(charValues, function(key,value) {					
     		$('#characters' + descID)
        		.append($('<option>', { value : key })
          		.text(value)); 
  			});	
		}
	});
	
	$('#characters' + descID).append($('#characters' + descID + ' option').remove().sort(function(a, b) {
	    var at = $(a).text(), bt = $(b).text();
	    return (at > bt)?1:((at < bt)?-1:0);
	}));
	
	$('#characters' + descID).val($("#target option:first").val());


	
}

function noSelectionErrors() {
	return true;
}

function getPostData() {

	var address;
	var postData = {};
	postData['observed_location'] = $('#observed_location').val();

	switch($('#observed_location').val()) 
	{
		case 'address':
			postData['address'] = $('#address').val();
			break;
		case 'current':
			if (locationShared) {
				postData['address'] = $('#latitude').val() + ', ' + $('#longitude').val();
			}
			else {
				postData['observed_location'] = 'ip';
			}
		case 'map':
			postData['address'] = $('#latitude').val() + ', ' + $('#longitude').val();
			break;
	}
		
	for (x = 1; $('#characters'+x).val() != undefined; x++) { 
		postData['characters'+x]  = $('#characters'+x).val();
	}
	
	for (y = 1; $('#states'+y).val() != undefined; y++) { 
		postData['states'+y]  = $('#states'+y).val();
		if ($('#statevalue'+y).val() != undefined) {
			postData['statevalue'+y] = $('#statevalue'+y).val();
		}
	}
	
	postData['type'] = $('#character_type_id').val();
	
	if ($('#observed_day').val() == 1) {
		postData['observed_day'] = 1;
		postData['day'] = $('#day').val();
		postData['month'] = $('#month').val();
	}
	if ($('#habitat_id').val() > 0) {
		postData['habitat_id'] = $('#habitat_id').val();
	}
	
	postData['page'] = page;
	return postData;
}

function addObservations(data) {
	
	if (page ==  1 && $('#observed_location').val() != 'no') {
		$('#search_location_map_canvas').height(300);
		var map = createMap('#search_location_map_canvas', null, null);
		//createMap_setMapBounds('#search_location_map_canvas');
		locationSelector_addAllMarkers('#search_location_map_canvas', data);
		locationSelector_markerDescriptions('#search_location_map_canvas');
	}
}

function showLoadedItemsMobile(url) {
	if ($.cookie('searchresults'+url) != undefined && $.cookie('searchresults'+url).length > 0) {
		$.cookie('searchresults', $.cookie('searchresults'+url));
		showLoadedItems();
	}
	
}

function showLoadedItems() {
	$.ajaxSetup({async:false});
	if ($.cookie('searchresults') != undefined && $.cookie('searchresults').length > 0 && (window.location.hash.length > 0 || (site == "mobile" || site == "tablet"))) {
		var formdata = $.unserialize($.cookie('searchresults'));
		
		if (typeof(formdata['observed_day']) != undefined) {
			$('#observed_day').val(formdata.observed_day);
			observationDate();
			if (typeof(formdata['day']) != undefined) {
				$('#day').val(formdata.day);
			}
			
			if (typeof(formdata['month']) != undefined) {
				$('#month').val(formdata.month);
			}
		}
		
		if (typeof(formdata['observed_location']) != undefined) {
			$('#observed_day').val(formdata.observed_day);
			observationDate();
			if (typeof(formdata['day']) != undefined) {
				$('#day').val(formdata['day']);
			}
			
			if (typeof(formdata['month']) != undefined) {
				$('#month').val(formdata['month']);
			}
		}

		for (x = 1; formdata["characters"+x] != undefined; x++) {
			if (x != 1) {	
				description_id++;
				addDescriptionField(x);
				checkDescriptionButtons();
			}
	
		}
			
		for (x = 1; formdata["characters"+x] != undefined; x++) {
			$('#characters'+x).val(formdata["characters"+x]).attr('selected',true);;

		}
		
		
		for (x = 1; formdata["characters"+x] != undefined; x++) {
			getStates(formdata["characters"+x], x);
			$('#states'+x).val(formdata["states"+x]).attr('selected',true);

		}
		
		//$('#characters'+x).val(formdata["characters"+x]);
		//$('#states'+x).val(formdata["states"+x]);

		//for (x = 1; typeof(eval("characters"+x)) != undefined; x++) {
			//console.log(eval("characters"+x));
		//}

		//if (formdata)
	}
	else {
		getStates($('#characters1').val(), 1);
	}
	$.ajaxSetup({async:true});
	
}
