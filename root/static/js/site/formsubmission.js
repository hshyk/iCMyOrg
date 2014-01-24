function formSubmission_disableForm() {
	$('form').submit(function(){
	    // On submit disable its submit button
	    $('input[type=submit]', this).attr('disabled', 'disabled');
	});
}