function setUpObservation() {
	formSubmission_disableForm();
	
	getImageByID();
	$('#organism_id').change(function() {
		getImageByID();
	});
	
	$('#review_comments').parent().attr('style','display:none');
	observationReviewComments();
	
	$('#status_id').change(function() {
		observationReviewComments();
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

function observationReviewComments() {
	if ($('#status_id').val() == $('select[name="status_id"] > option:contains("' + reviewName + '")').val()) {
		$('#review_comments').parent().attr('style','display:block');
	}
}