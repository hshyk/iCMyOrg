function setFacebookLike(div_id, fb_url) {
	if (usesocial) {
		$(div_id).html('<fb:like href="' + fb_url + '" send="false" width="100%" show_faces="false"></fb:like>');
		if (typeof(FB) != 'undefined' && FB != null ) {
			FB.XFBML.parse();
		}
	}
}

function setFacebookShare(div_id, fb_url) {
	if (usesocial) {
		$(div_id).html('<fb:share-button type="button_count" href="' + fb_url + '"> </fb:share-button>');
		if (typeof(FB) != 'undefined' && FB != null ) {
			FB.XFBML.parse();
		}
	}
}

function setTwitterTweetButton(div_id, twitter_url, twitter_text) {
	if (usesocial) {
		$(div_id).html('<a href="https://twitter.com/share" class="twitter-share-button" data-url="' + twitter_url + '" data-text="' + twitter_text + '">Tweet</a>');
	}
	
}