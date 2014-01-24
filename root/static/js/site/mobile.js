$( document ).live( 'pageshow',function(event){
 	photoSwipe_restartPhotoSwipe();
	
	$('hr').each(function() {
		$(this).before('<div class="hr_divider center">' +
			'<div class="hr_left">&nbsp;</div>' +
			'<div class="hr_right">&nbsp;</div>' +
			'</div>').remove();
	});
	$('.backbutton').click(function() {
		goBack();								
	});
});

function goBack() {
	 if (typeof previous != 'undefined' && previous != '') {
		var back = $.mobile.back();
	 	if (typeof back == 'undefined') {
	 		$.mobile.changePage(previous);
	 	}
	 }
	 else {
	 	history.back();
	 } 
}


