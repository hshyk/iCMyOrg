package Site::Controller::Css;
use Moose;
use CSS::Minifier::XS qw(minify);

=head1 NAME

Site::Controller::Css - Catalyst Controller

=head1 DESCRIPTION

Just a class to combine the CSS files into 1 file

=cut

BEGIN {extends 'Catalyst::Controller::Combine'; }

__PACKAGE__->config(
        # the directory to look for files
        # defaults to 'static/<<action_namespace>>'
        dir => 'static/css',

        # the (optional) file extension in the URL
        # defaults to action_namespace
        extension => 'css',
        
                # optional dependencies
        depend => {         
            'desktop'      => [ 
            	qw(
            		bootstrap/bootstrap
					jquery/photoswipe
					jquery/jquery.tablesorter 
					jquery/jquery.prettyphoto
					site/desktop
            	) 
            ],
            'tablet'      => [ 
            	qw(
            		jquery/jquery.mobile
            		jquery/jquery.mobile.tablet
					scroll/iscroll
					jquery/photoswipe
					site/tablet
             	) 
            ],
           'mobile'      => [ 
            	qw(
            		jquery/jquery.mobile
            		jquery/jquery.simplemodal
					scroll/iscroll
					jquery/photoswipe
					site/mobile
            	) 
            ],
            'kiosk'      => [ 
            	qw(
            		bootstrap/bootstrap
					jquery/photoswipe
					site/kiosk
            	) 
            ],
            'iscroll.vertical' => [ 
            	qw(
            		scroll/iscroll.vertical
            	)
            ]
        },

        # should a HTTP expire header be set? This usually means, 
        # you have to change your filenames, if there a was change!
        expire => 1,

        # time offset (in seconds), in which the file will expire
        expire_in => 60 * 60 * 24, # 3 years

        # mimetype of response if wanted
        # will be guessed from extension if possible and not given
        # falls back to 'text/plain' if not guessable
        mimetype => 'text/css',
        
        
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
