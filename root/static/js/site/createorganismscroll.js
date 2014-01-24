var photoInfo = new Array();
var cachedList = new Array();
var submitForm = false;
var reloadScroll = true;
var myScroll;

function createOrganismScroll_saveForm(url) {
	$.cookie('searchresults'+url,  $("form").serialize());
}

function createOrganismScroll_getForm(url) {
	if ($.cookie('searchresults'+url) != undefined && $.cookie('searchresults'+url).length > 0) {
		$("form").unserializeForm($.cookie('searchresults'+url));
	}
}

function createOrganismScroll_saveCachedList(url) {
	if ($('#thelist').html() != '') {
		cachedList[url] = new Array();
		cachedList[url]['content'] = $('#thelist').html();
		cachedList[url]['page'] = page;
	}
	
	reloadScroll = true;
}

function createOrganismScroll_getCachedList(url) {
	if (typeof cachedList != 'undefined' &&  typeof cachedList[url] != 'undefined') {
		$('#thelist').html(cachedList[url]['content']) ;
		page = cachedList[url]['page'];
		$('#wrapper').attr('style', 'height:400px;');		
		createOrganismScroll_createScroller();
		return true;
	}
	else {
		return false;
	}
}


function blockUI() {
	 $.blockUI({ message: '<h1>Please wait while we load your results!</h1>' });
}

function unblockUI() {
	$.unblockUI();
	if (reloadScroll) {
		createOrganismScroll_createScroller();
		reloadScroll = false;
	}
	myScroll.refresh();
	photoSwipe_restartPhotoSwipe();
}

function createOrganismScroll() {
	$('#list').after('<div id="wrapper" style="width: 70%;"> \
		<ul id="thelist"></ul> \
		<div id="scroller">  \
			<div id="pullUp" style="margin-left: -10px;"> \
			</div> \
		</div> \
	</div>');
	$("form").submit(function() {
		submitForm = true;	
		
		$('#wrapper').attr('style', 'height:400px;');
		page = 1;
		createOrganismScroll_getOrganisms();
		return false;
		
});	
							  
};




function createOrganismScroll_createScroller() {
			pullUpEl = document.getElementById('pullUp');	
			pullUpOffset = pullUpEl.offsetHeight;
	
		
			myScroll = new iScroll('wrapper', {
				useTransition: true,
				hScrollbar: false,
				topOffset: pullUpOffset,
				onRefresh: function () {
					if (pullUpEl.className.match('loading')) {
					pullUpEl.className = '';
					pullUpEl.querySelector('.pullUpLabel').innerHTML = 'Pull up to load more...';
				}
				},
				onScrollMove: function () {
					if (this.y < (this.maxScrollY - 5) && !pullUpEl.className.match('flip')) {
					pullUpEl.className = 'flip';
					pullUpEl.querySelector('.pullUpLabel').innerHTML = 'Release to refresh...';
					this.maxScrollY = this.maxScrollY;
				} else if (this.y > (this.maxScrollY + 5) && pullUpEl.className.match('flip')) {
					pullUpEl.className = '';
					pullUpEl.querySelector('.pullUpLabel').innerHTML = 'Pull up to load more...';
					this.maxScrollY = pullUpOffset;
				}
				},
				onScrollEnd: function () {
					if (pullUpEl.className.match('flip')) {
					pullUpEl.className = 'loading';
					pullUpEl.querySelector('.pullUpLabel').innerHTML = 'Loading...';				
					createOrganismScroll_getOrganisms();	// Execute custom function (ajax call?)
					
					
					}
						
				}
			});
		
		setTimeout(function () { document.getElementById('wrapper').style.left = '0'; }, 800);
}
											  
												  
function createOrganismScroll_getOrganisms() {
	
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
				if (observationlist && typeof data['observations'] != 'undefined') {
					addObservations(data['observations']);
				}
				if (data['data'].length <= 0) {
					$('#thelist').html('<h3>There were no results found</h3>');
				}
				else {
					$.each (data['data'], function(key, value) {
							count++;
							var score = '';
							if (value['score'] > 0 ) {
								score = '<p class="ui-li-desc">Likely Match: ' + value['score'] + '%</p>';
							}
							var image = '';
							if (value['image_id'] > 0) {
								image = '<a class="ui-link-inherit" photoid="' + value['image_id'] + '" href="' + value['image_path'] + '/img-' + imagetouse + '.jpg" specimenname="'+ value['common_name'] + '" data-ajax="false" style=""><img src="' + value['image_path'] + '/thumb.jpg" imagetype="organism"  class="ui-li-thumb" /></a>';
							}
							else {
								image = '<a class="ui-link-inherit" data-ajax="false" onClick="javascript:void(0);" style=""><img src="' + value['image_path'] + '" class="ui-li-thumb" /></a>';
							}
							
							$('#thelist').append('<li data-corners="false" data-shadow="false" data-iconshadow="true" data-wrapperels="div" data-icon="arrow-r" data-iconpos="right" data-theme="c" class="ui-btn ui-btn-icon-right ui-li-has-arrow ui-li ui-li-has-thumb ui-btn-up-c" style="height: 100px; float: none; margin-left: -50px;"> \
													<div class="ui-btn-inner ui-li"><div class="ui-btn-text"> \
					<div id="Gallery" style="float: left; width: 80px;"> ' + image + ' </div><a href="' + value['url'] + '" class="ui-link-inherit"> \
					<div style="margin-left:-80px" class="scrolltext"><h3 class="ui-li-heading">' + value['common_name'] + '</h3> \
					<p class="ui-li-desc"> ' + value['scientific_name'] + '</p>' + score + '</div> \
				</a></div><span class="ui-icon ui-icon-arrow-r ui-icon-shadow">&nbsp;</span></div></li>');
						photoInfo['organism'][value['image_id']] = value['common_name'];
				success =  true;
								});
					if (count == 10) {
							$('#thelist').append('<div id="refresh" style="height: 80px;"><div id="pullUp"> \
						<span class="pullUpIcon"></span><span class="pullUpLabel">Pull up to refresh...</span> \
					</div></div>');
					}
				}

					//$('.moreinfo').button();
     				$('html,body').animate({scrollTop: $("#list").offset().top},'fast');
					
					page++;
					$('#wrapper').attr('style', 'height:400px; overflow: hidden; left: 0px;');	
					
				}
				else {
					success =  false;
					alert(data['errormsg']);
					}				 
	
				}
			);

	photoSwipe_restartPhotoSwipe();
	
	}
	else {
		success = false;
	}

	$.ajaxSetup({
		beforeSend: null,
		complete: null
	});
	return success;
}
