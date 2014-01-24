function loadExamplesPage() {
	
	setDescriptionField();
	$('#character_type_id').change(function() {
		setDescriptionField()
	});
	
	$('#character_id').change(function() {
		getStates($('#character_id').val());
	});
}



function setDescriptionField() {

	getCharacters($('#character_type_id').val());
	
	getStates($('#character_id').val());
	

	$('#characters').change(function() {

		//Due to IE issues (not properly populating list), 
		//need to remove the select and re-add it 
		$('#stateselect').remove();
		
 		getStates($('#characters'));
	});
	
	var charSel = $("#character_id");
	if (jQuery.isFunction(charSel.selectmenu)) {
		charSel.selectmenu();
		charSel.selectmenu('refresh');
		charSel.selectmenu("refresh", true);
	}

}

function getStates(character) {
	
	$('#state_id')
    	.find('option')
    	.remove()
    	.end();

	$.post(stateURL,
		   { character: character },  
		 	function(data) {
				if (data['states'] != null) {  
					$.each (data['states'], function(key, value) {
						$('#state_id')
								.append($('<option>', { value : key })
								.text(value));	
					});
				}
				
				$('#state_id').html($("#state_id option").sort(function (a, b) {
    				return a.text == b.text ? 0 : a.text < b.text ? -1 : 1
				}))
				

				
				
					
				var stateSel = $("#state_id");
				if (jQuery.isFunction(stateSel.selectmenu)) {
				    stateSel.selectmenu();
				   	stateSel.selectmenu('refresh');
				    stateSel.selectmenu("refresh", true);
				
			    }
			});	
}

function getCharacters(character_type) {
	
	$('#character_id')
    	.find('option')
    	.remove()
    	.end();
	$.each(characters, function(charID, charValues) {
		if (charID == character_type) {
			$.each(charValues, function(key,value) {					
     		$('#character_id')
        		.append($('<option>', { value : key })
          		.text(value)); 
  			});	
		}
	});
	
}

function noSelectionErrors() {
	return true;
}

