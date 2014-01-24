package Site::Controller::Js;
use Moose;
use JavaScript::Minifier::XS qw(minify);

=head1 NAME

Site::Controller::Js - Catalyst Controller

=head1 DESCRIPTION

Just a class to combine the JS files into 1 file

=head1 METHODS

=cut


BEGIN {extends 'Catalyst::Controller::Combine'; }

__PACKAGE__->config(
        # the directory to look for files
        # defaults to 'static/<<action_namespace>>'
        dir => 'static/js',

        # the (optional) file extension in the URL
        # defaults to action_namespace
        extension => 'js',
        
        # optional dependencies
        depend => {         
            'desktop'      => [ 
            	qw(
            		jquery/jquery
            		jquery/klass
            		jquery/jquery.blockui
            		jquery/jquery.geolocation
            		jquery/jquery.ui.map 
            		jquery/jquery.ui.map.services 
            		jquery/jquery.photoswipe 
            		jquery/jquery.simplemodal 
            		jquery/jquery.tablesorter 
            		jquery/jquery.hashchange
            		jquery/jquery.cookie
            		jquery/jquery.serializeform
            		jquery/jquery.unserialize
					jquery/jquery.prettyphoto 
					site/socialnetworking
					site/photoswipe 
					site/createmap 
					site/createorganismlist 
					site/locationselector
					site/formsubmission 
					site/tablesorter
            	) 
            ],
             'tablet'      => [ 
            	qw(
            		jquery/jquery 
            		jquery/klass 
            		google/bookmark_bubble
            		site/bookmark_bubble
            		jquery/jquery.geolocation
            		jquery/jquery.mobile
            		jquery/jquery.blockui
					jquery/jquery.ui.map 
					jquery/jquery.ui.map.services 
					jquery/jquery.photoswipe
					jquery/jquery.simplemodal
					jquery/jquery.cookie
            		jquery/jquery.serializeform 
            		jquery/jquery.unserialize
					scroll/iscroll
					site/mobile
					site/socialnetworking 
					site/photoswipe
					site/createmap
					site/createorganismscroll
					site/locationselector
					site/formsubmission
            	) 
            ],   
             'mobile'      => [ 
            	qw(
            		jquery/jquery
            		jquery/klass 
            		google/bookmark_bubble
            		site/bookmark_bubble
            		jquery/jquery.geolocation
            		jquery/jquery.mobile
            		jquery/jquery.blockui
					jquery/jquery.ui.map 
					jquery/jquery.ui.map.services 
					jquery/jquery.photoswipe
					jquery/jquery.simplemodal 
					jquery/jquery.cookie
            		jquery/jquery.serializeform
            		jquery/jquery.unserialize
					scroll/iscroll
					site/mobile
					site/socialnetworking 
					site/photoswipe
					site/createmap
					site/createorganismscroll
					site/locationselector
					site/formsubmission
            	) 
            ],  
            'kiosk'      => [ 
            	qw(
            		jquery/jquery 
            		jquery/klass
            		jquery/jquery.blockui
            		jquery/jquery.geolocation
            		jquery/jquery.ui.map 
            		jquery/jquery.ui.map.services 
            		jquery/jquery.photoswipe 
            		jquery/jquery.simplemodal 
            		jquery/jquery.hashchange
            		jquery/jquery.cookie
            		jquery/jquery.serializeform
            		jquery/jquery.unserialize
					site/photoswipe 
					site/createmap 
					site/createorganismlist 
					site/locationselector 
            	) 
            ],
            'html5' => [
            	qw(
            		html5/html5shiv
            	)
            ],
            'ckeditor'	=>	[
            	qw(
            		site/ckeditor
            		ckeditor/ckeditor
            	)
            ],
            'page.'.lc(Site->config->{Site}->{organisms}).'.searchbydescription' => [
            	qw(
            		pages/organisms.searchbydescription
            	)
            ],
            'page.'.lc(Site->config->{Site}->{organisms}).'.searchbylocation' => [
            	qw(
            		pages/organisms.searchbylocation
            	)
            ],
            'page.'.lc(Site->config->{Site}->{organisms}).'.organisminfo' => [
            	qw(
            		pages/organisms.organisminfo
            	)
            ],
            'page.'.lc(Site->config->{Site}->{organisms}).'.viewstatesimages' => [
            	qw(
            		pages/organisms.viewstatesimages
            	)
            ],
            'page.user.viewobservationslist' => [
            	qw(
            		pages/user.viewobservationslist
            	)
            ],
            'page.user.observation' => [
            	qw(
            		pages/user.observation
            	)
            ],
             'page.reviewer.observation' => [
            	qw(
            		pages/reviewer.observation
            	)
            ],
             'page.admin.view'.lc(Site->config->{Site}->{organisms}).'states' => [
            	qw(
            		pages/admin.vieworganismsstates
            	)
            ],
             'page.admin.view'.lc(Site->config->{Site}->{organisms}).'hosts' => [
            	qw(
            		pages/admin.vieworganismshosts
            	)
            ],
            'page.admin.viewobservations' => [
            	qw(
            		pages/admin.viewobservations
            	)
            ],
            'picup'	=>	[
            	qw(
            		picup/picup2	
            	)
            ]                
        },

        # should a HTTP expire header be set? This usually means, 
        # you have to change your filenames, if there a was change!
        expire => 1,

        # time offset (in seconds), in which the file will expire
        #expire_in => 60 * 60 * 24, # 1 day
        expire_in => 60 * 60 * 24, # 1 day

        # mimetype of response if wanted
        # will be guessed from extension if possible and not given
        # falls back to 'text/plain' if not guessable
        mimetype => 'application/javascript',
        
        # name of the minifying routine (defaults to 'minify')
        # will be used if present in the package
		minifier => 'minify',
);


=head1 AUTHOR

Harry Shyket

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
