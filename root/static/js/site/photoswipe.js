var myPhotoSwipe;


//jQuery version
function photoSwipe() {

	myPhotoSwipe = photoSwipe_startPhotoSwipe();
	
};

function photoSwipe_createModal(linkUrl, indexNumber, photoNumber) {

	myPhotoSwipe.hide();
	$("html, body").delay(100).animate({ scrollTop: 0 }, "slow");	
	
	var tableImage;
	var modalID;
	var position;
	
	if (site == "mobile") {	
		position = ["5%",""];
		tableImage = '<div id="image_map_canvas" style="width: 100%; height: 300px;"> </div>';
		var minZoom = 0;
	}
	else {
		position = ["5%","10%"];
		tableImage = '<div id="image_map_canvas" style="width: 1000px; height: 550px;"> </div>';
		var minZoom = 2;
	}

		tableImage += '<div class="ps-modal" style="left: 0px; overflow: hidden; z-index: 1000; display: table; top: 0px; width: 300px; opacity: 0.8;"><div class="ps-toolbar-close" id="closeModal"><div class="ps-toolbar-content"></div></div></div>';

	$.modal(tableImage,
			{
				opacity:90,
				zIndex: 3500,
				position: position,
				overlayClose: true,
				//autoResize: true,
				onShow: function (dialog) {
        			var modal = this; // you now have access to the SimpleModal object
					modal.setPosition();
					
					var isLevel = true;
					var zoomCounter = 0;
					do 
					{
						$.ajax({
							   	async: false,
								url:linkUrl + '/' + zoomCounter + '/' +  '0-0.jpg',
								type:'HEAD',
								error: function(){
										isLevel = false;
								},
							});	
						zoomCounter++;					
					}
					while (isLevel);
					
					zoomCounter = zoomCounter - 2;

					var imageTypeOptions = {
						getTileUrl: function(coord, zoom) {
							var normalizedCoord = getNormalizedCoord(coord, zoom);
     
							if (!normalizedCoord) {
								return null;
							}
			
							var bound = Math.pow(2, zoom);
							return linkUrl +  "/" + zoom + "/" + normalizedCoord.x + "-" + (normalizedCoord.y) + ".jpg";
						},
						tileSize: new google.maps.Size(256, 256),
						maxZoom: zoomCounter,
						minZoom: minZoom,
						radius: 1738000,
						name: $("a[photoid='" + photoNumber +"']").attr("specimenname")
					};
					
					var imageMapType = new google.maps.ImageMapType(imageTypeOptions);
					
					var myLatlng = new google.maps.LatLng(0, 0);
 					var myOptions = {
						center: myLatlng,
						zoom: minZoom,
						streetViewControl: false,
						mapTypeControlOptions: {
						  mapTypeIds: ["organism"]
						},
						backgroundColor: "#000000",
					};
				
					
					var map = new google.maps.Map(document.getElementById("image_map_canvas"), myOptions);
					map.mapTypes.set('organism', imageMapType);
					map.setMapTypeId('organism');
					
					var mapBounds;
					
					google.maps.event.addListener(map, 'bounds_changes', function() {
						bounds = map.getBounds();
					});
					
					
					google.maps.event.addListener(map, 'dragend', function() {
						  // Get some info about the current state of the map
           /* var C   = map.getCenter();
            var lng = C.lng();
            var lat = C.lat();
            var B  = map.getBounds();
            var sw = B.getSouthWest();
            var ne = B.getNorthEast();

            // Figure out if the image is outside of the artificial boundaries
            // created by our custom projection object.
            var new_lat = lat;
            var new_lng = lng;
            if (ne.lat() > 50) {
                new_lat = lat - (sw.lat() + 50);
            }
            else if (sw.lat() < -50) {
                new_lat = lat - (ne.lat() - 50);
            }
            if (ne.lng() > 50) {
                new_lng = lng - (sw.lng() + 50);
            }
            else if (sw.lng() < -50) {
                new_lng = lng - (ne.lng() - 50);
            }
            // If necessary, move the map
            if (new_lat != lat || new_lng != lng) {
                map.setCenter(new google.maps.LatLng(new_lat,new_lng));
            }*/
					});
				},
				
				

				//closeHTML: '',
				closeHTML: '',
				//closeClass: null,

			}
	);	
	
	$('#closeModal').click(function() {	
									
		myPhotoSwipe.show(indexNumber-1);
		$.modal.close();
		
		return true;

	});
		
}  

// Normalizes the coords that tiles repeat across the x axis (horizontally)
// like the standard Google map tiles.
function getNormalizedCoord(coord, zoom) {
  var y = coord.y;
  var x = coord.x;

  // tile range in one direction range is dependent on zoom level
  // 0 = 1 tile, 1 = 2 tiles, 2 = 4 tiles, 3 = 8 tiles, etc
  var tileRange = 1 << zoom;

  // don't repeat across y-axis (vertically)
  if (y < 0 || y >= tileRange) {
    return null;
  }

  // repeat across x-axis
  if (x < 0 || x >= tileRange) {
   // x = (x % tileRange + tileRange) % tileRange;
   return null;
  }

  return {
    x: x,
    y: y
  };
}

function checkBounds(map, allowedBounds) { 
	
	        // Perform the check and return if OK
        if (allowedBounds.contains(map.getCenter())) {
          return;
        }
        // It`s not OK, so find the nearest allowed point and move there
        var C = map.getCenter();
        var X = C.lng();
        var Y = C.lat();

        var AmaxX = allowedBounds.getNorthEast().lng();
        var AmaxY = allowedBounds.getNorthEast().lat();
        var AminX = allowedBounds.getSouthWest().lng();
        var AminY = allowedBounds.getSouthWest().lat();

        if (X < AminX) {X = AminX;}
        if (X > AmaxX) {X = AmaxX;}
        if (Y < AminY) {Y = AminY;}
        if (Y > AmaxY) {Y = AmaxY;}
        //alert ("Restricting "+Y+" "+X);
        map.setCenter(new google.maps.LatLng(Y,X));

}



function photoSwipe_startPhotoSwipe() {
	
	if ($("#Gallery a").length) {

		var imageCount = 0;
		return $("#Gallery a").photoSwipe({ 
			imageScaleMethod: "fitNoUpscale",
			enableMouseWheel: false , 
			enableKeyboard: false,
			allowUserZoom: false,
			captionAndToolbarAutoHideDelay: 0,
			getImageCaption: function(el){
				imageCount++;
				var image = new String(el);
				var linkUrlNoHost = image.replace(/https?:\/\/[^\/]+/i, '');
				var linkUrl = image.replace(/\/img-web.jpg/, '');
				var linkUrl = linkUrl.replace(/\/img-mobile.jpg/, '');
				var imageType = $("a[href='" + linkUrlNoHost +"'] img").attr("imagetype");
				var photoNumber = $("a[href='" + linkUrlNoHost +"']").attr("photoid");
				var infostring = '';
				if (typeof photoInfo != 'undefined' && typeof imageType != 'undefined' && typeof photoNumber !='undefined' ) {
					if(typeof photoInfo[imageType] != 'undefined' && typeof photoInfo[imageType][photoNumber] != 'undefined') {
						infostring += photoInfo[imageType][photoNumber] + '<br />';
					}
				}
				return $('<div><a data-ajax="false" data-role="button" data-inline="true" data-mini="true" href="javascript:photoSwipe_createModal(\'' + linkUrl + '\', ' + imageCount + ', ' + photoNumber + ' );" style="text-decoration: none;color: #FFF;"><img src="/static/images/jquery/photoswipe/zoom.png" /></a>' + 
						  '<a data-ajax="false" data-role="button" data-inline="true" data-mini="true" href="javascript:photoSwipe_restartPhotoSwipe();" style="text-decoration: none;color: #FFF;"><img src="/static/images/jquery/photoswipe/close.png" /></a>' +
						  '<br /><strong>' + infostring + '</strong></div>');
	        }
	     });
	}
	else {
		return null;
	}
}

function photoSwipe_restartPhotoSwipe() {
		
	if (myPhotoSwipe != null) {
		window.Code.PhotoSwipe.unsetActivateInstance(myPhotoSwipe);
		window.Code.PhotoSwipe.detatch(myPhotoSwipe); 	
		myPhotoSwipe = 'undefined';	
		$('body').removeClass('ps-active');
	}
	
	myPhotoSwipe = photoSwipe_startPhotoSwipe();
}

