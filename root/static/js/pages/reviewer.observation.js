function setUpObservation() {
	formSubmission_disableForm();
	
	getImageByID();
	$('#organism_id').change(function() {
		getImageByID();
	});

}

	
function getImageByID() {
	$.ajaxSetup({async:false});
	$.post(imageIDURL,
		{ id: $('#organism_id').val() },  
		function(data) {
			$('#thumb').remove();
			$('#organism_id').after('<img id="thumb" src="'+data['data'][0]['image_path']+'/thumb.jpg" />');
		}
	);	
}
