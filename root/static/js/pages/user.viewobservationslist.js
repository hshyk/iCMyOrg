var pageUserObservations = 1;
var countUserObservations = 0;
function viewUserObservationList() {
	viewUserObservationList_getObservations();
}

function viewUserObservationList_getObservations() {
	if (site == "mobile" || site == "tablet") {
		$.mobile.showPageLoadingMsg();
	}
	else {
		$('body').addClass('loading');
	}
	
	$.ajaxSetup({async:false});
	$.post(observationsURL,
		{ page: pageUserObservations },  
		function(data) {
			if (data['observations'] != null) {  
				$.each (data['observations'], function(key, value) {
					var bgcolor;
					if (value['status'] == status_unpublished) {
						bgcolor = '#f29595'
					}
					else if (value['status'] == status_review) {
						bgcolor = '#edf969';
					}
					else {
						bgcolor = 'none';
					}
					$('#observationlist').append($('<li data-corners="false" data-shadow="false" data-iconshadow="true" data-wrapperels="div" data-icon="arrow-r" data-iconpos="right" data-theme="c" class="btn ui-btn ui-btn-icon-right ui-li-has-arrow ui-li ui-li-has-thumb ui-btn-up-c" style="height: 100px; float: none;"> \
												<div class="ui-btn-inner ui-li" style=" background-color:' + bgcolor + ';"><div class="ui-btn-text"> \
				<div id="Gallery" style="float: left; width: 80px;"><a class="ui-link-inherit" photoid="' + value['image_id'] + '" href="' + value['image_path'] + '/img-' + imagetouse + '.jpg" data-ajax="false" style=""><img src="' + value['image_path'] + '/thumb.jpg" imagetype="butterfly"  class="ui-li-thumb" /></a></div><a href="' + value['url'] + '" class="ui-link-inherit"> \
				<div id="buttonlist"><h3 class="ui-li-heading">' + value['location_detail'] + '</h3> \
				<p class="ui-li-desc"> ' + value['common_name'] + '</p>' + value['date_observed'] + '</div> \
			</a></div><span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></div></li>	'));	
					countUserObservations++;
				});
				if (countUserObservations == 10)
				{
					$('#thelist').after('<div class="morebutton"><a data-role="button" data-theme="b" data-icon="arrow-d" class="btn" id="seeMoreObservations" href="#">Click here to see more</a></div>');
					if (site == "mobile" || site == "tablet") {
						$('#seeMoreObservations').button();
						//$('#seeMoreObservations').button('refresh');
						//$('#seeMoreObservations').button('refresh', true);
					}
					$('#seeMoreObservations').click(function() {
						viewUserObservationList_getObservations();										
					});
				}
			}
		}
	);	
	pageUserObservations++;
	photoSwipe_restartPhotoSwipe();
	if (site == "mobile" || site == "tablet") {
		$.mobile.hidePageLoadingMsg();
	}
	else {
		$('body').removeClass('loading');
	}
	
	
}

