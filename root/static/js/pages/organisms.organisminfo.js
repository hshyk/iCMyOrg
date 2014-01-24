var scrollCount = 1;
var loadedElements = new Array();
var page = 1;

function organismInfo() {
	
	
	$.each (photoRequest, function(charactertype, imagetypes) {
		$.each (imagetypes, function(imagetype, images) {
			if (images.info.length > 0) {
				$("#Gallery").append('<p><strong>' + images['charactertype'] + '- ' + images['imagetype'] +  '</strong></p><div id="'+ charactertype +'-'+ imagetype +'"></div><p>&nbsp;</p>');
				organisminfo_addImagesToPage(charactertype,imagetype, images.info, organism);
				if (images['current'] < images['total']) {
					$('#'+ charactertype +'-'+ imagetype +'').append('<div><a class="seemore btn" charactertype ="' + charactertype + '" imagetype="' + imagetype + '" data-role="button" data-mini="true" data-inline="true" data-theme="b" id="seeMore" rel="external">See More</a></div>');
					if (site == "mobile" || site == "tablet") {
						$('#seeMoreObservations').button();
					}
				}
			}
		});
		
	});
	
	if (usehost) {
		$.each (photoHostRequest, function(key, images) {
				if (images.info.length > 0) {
					$("#Gallery").append('<p><strong>' + images['charactertype'] + '- ' + images['imagetype'] +  '</strong></p><div id="'+ host + '-' +key +'"></div><p>&nbsp;</p>');
					organisminfo_addImagesToPage(host,key, images.info, host);
				}			
		});
	}
	
	photoSwipe_restartPhotoSwipe();
	
	
	$(".seemore").click(function() {
		var request = photoRequest[$(this).attr('charactertype')][$(this).attr('imagetype')];
		//$('#'+ $(this).attr('charactertype') +'-'+ $(this).attr('imagetype') +' a.seemore').remove();
		if (request['current'] <  request['total']) {
			request['current']++;
			organisminfo_getImages($(this).attr('charactertype'), $(this).attr('imagetype'),request['charactertype'], request['imagetype'], request['current'] );
			
		}
		
		if (request['current'] < request['total']) {
			//$(this).parent().append($(this).html());
			//$('#' + $(this).attr('charactertype') + '-' + $(this).attr('imagetype')).append('<br />');
			$('#' + $(this).attr('charactertype') + '-' + $(this).attr('imagetype')).append($(this));
		}
		else {
			$(this).remove();
		} 
		
	})
	
	
	$('#nav').remove();
	//$('#wrapper').attr('style', 'width: 280px; margin-bottom: 120px;'); 
}


function organisminfo_addImagesToPage(charactertype, imagetype, images, speciestype) {
	
	var imagecount = 0;
	if (images != undefined) {
		
		$.each (images, function(key,image) {
			$('#'+ charactertype +'-'+ imagetype).append('<a data-ajax="false" photoid="' + image['image_id']  + '" href="' + image['filename'] + '/img-' + imagetouse + '.jpg"  specimenname="' + charactertype + ' - ' + imagetype + '" style="margin-right: 5px;"><img src="' + image['filename'] + '/thumb.jpg" imagetype="organism" /></a>');
			imagecount++;
			if (imagecount == 5) {
				$('#'+ charactertype +'-'+ imagetype).append('<br />');
				imagecount = 0;
			}
		});
		//$("body").attr('class', '');
		$('body').removeClass('ps-building');
		
	}

}

function organisminfo_getImages(divc, divi, charactertype, imagetype, page) {
	
	$.ajaxSetup({async: false});

	$.post(
		imageURL,
		{
			id: organismId, 
			page: page,
			character_type:	charactertype,
			image_type:	imagetype
		},  
		function(data) {		
			$.each(data, function(key, images) {
				$.each (images, function(key,image) {
					photoInfo['organism'][image['image_id']] = image['info'];
				});
				organisminfo_addImagesToPage(divc,divi, images, organism);					
				
			});

			
		}
      )
	
	 $.ajaxSetup({async: true});
	 
	 
	 photoSwipe_restartPhotoSwipe();

}
