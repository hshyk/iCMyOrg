var photoInfo = new Array();
var submitForm = false;

function removeHash () { 
    var scrollV, scrollH, loc = window.location;
    if ("pushState" in history)
        history.pushState("", document.title, loc.pathname + loc.search);
    else {
        // Prevent scrolling by storing the page's current scroll offset
        scrollV = document.body.scrollTop;
        scrollH = document.body.scrollLeft;

        loc.hash = "";

        // Restore the scroll offset, should be flicker free
        document.body.scrollTop = scrollV;
        document.body.scrollLeft = scrollH;
    }
}

function createOrganismList() {
	
// Bind an event to window.onhashchange that, when the hash changes, gets the
// hash and adds the class "selected" to any matching nav link.
$(window).hashchange( function(e){
	
	var hash = location.hash;
	
	if (hash.length > 0) {
		photoSwipe_restartPhotoSwipe();
		if (submitForm == false) {
			console.log("UNSERIALIZING FORM");
			$("form").unserializeForm($.cookie('searchresults'));
		}
			
		$('#wrapper').attr('style', 'height:100%;');
		createOrganismList_getOrganisms();
		
		if (submitForm == false) {
			console.log(page);
			for (var x = $.cookie('searchresultspage'); x > 1; x--) {
				page++;
				createOrganismList_getOrganisms();
			}
		}
	}
	else {
		$.cookie('searchresults',  '');
		$.cookie('searchresultspage',  '');
	}   
})

$(window).hashchange();
	
$('#list').after('<div id="wrapper"> \
	<ul data-filter="true" id="thelist"></ul> \
	<div id="scroller">  \
		<div id="pullUp" style="margin-left: -10px;">	 \
		</div> \
	</div> \
</div>');
	$("form").submit(function() {
		page = 1;
		submitForm = true;	
		removeHash();
		$('#thelist').html('');
		window.location.hash = "#searched";	
		return false;
	});	
							  
};

 function blockUI() {
	 $.blockUI({ message: '<h1>Please wait while we load your results!</h1>' });
 }
 
 function unblockUI() {
	 $.unblockUI();
	photoSwipe_restartPhotoSwipe();
 }
										 											  
function createOrganismList_getOrganisms() {
	
	$('body').addClass('loading');
	var success = true;
	$.ajaxSetup({
		beforeSend: blockUI,
		complete: unblockUI
	});
	var count = 0;

	if (noSelectionErrors()) {
	$.post(
		infoURL,
		getPostData(),  
		function(data) {
			if (data['issuccess'] == true) {
				if (typeof photoInfo['organism'] == 'undefined' ) {
					photoInfo = null;
					photoInfo = new Array();
					photoInfo['organism'] = new Array();
				}
				$('#refresh').remove();
				if (page == 1) {
					$('#thelist').html('');
				}
				if (observationlist && ((typeof data['observations'] != 'undefined') && data['observations'] != '')) {
					addObservations(data['observations']);
				}
				if (data['data'].length <= 0) {
					$('#thelist').html('<h3>There were no results found</h3>');
				}
				if ((typeof data['errormsg'] != 'undefined') && data['errormsg'].length > 0) {
					alert(data['errormsg'])
				}
				$.each (data['data'], function(key, value) {
						count++;
						var score = '';
						if (value['score'] > 0 ) {
							score = '<br /><span style="font-style: normal;">Likely Match: ' + value['score'] + '%</span>';
						}
						var image = '';
						if (value['image_id'] > 0) {
							image = '<a  photoid="' + value['image_id'] + '" href="' + value['image_path'] + '/img-' + imagetouse + '.jpg" specimenname="'+ value['common_name'] + '" data-ajax="false" style=""><img src="' + value['image_path'] + '/thumb.jpg" imagetype="organism" /></a>';
						}
						else {
							image = '<img src="' + value['image_path'] + '" />';
						}
						$('#thelist').append('<li class="btn"> \
				<div id="Gallery" style="float: left; width: 80px;"> ' + image + '</div> \
				<a href="' + value['url'] + '"><div style="height:100px; width:100%;"> \
				<div><h3 class="ui-li-heading">' + value['common_name'] + '</h3> \
				<p class="ui-li-desc"> ' + value['scientific_name'] + score + '</p></div></div> \
			</a></li>');
					photoInfo['organism'][value['image_id']] = value['common_name'];
			success =  true;
							});
				if (count == 10) {
						$('#thelist').append('<div id="refresh" style="height: 80px;"><div id="pullUp"> \
					<span class="pullUpIcon"></span><a class="btn" id="seeMore">Click here to see more matches</a> \
				</div></li>');
				}
			
					//$('.moreinfo').button();
					if (page == 1) {
     					$('html,body').animate({scrollTop: $("#list").offset().top},'fast');
					}
					
					page++;
					
					$('#seeMore').click(function() {
						submitForm = true;
						createOrganismList_getOrganisms();
					});
					
					
					
				}
				else {
					success =  false;
					alert(data['errormsg']);
					}				 
	
				}
			);
	

	}
	else {
		success = false;
	}

	$('body').removeClass('loading');
	$.ajaxSetup({
		beforeSend: null,
		complete: null
	});
	
	$.cookie('searchresults',  $("form").serialize());
	if (submitForm == true) {
		$.cookie('searchresultspage',  page);
	}
	return success;
}
