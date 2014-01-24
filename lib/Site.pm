package Site;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
	-Debug
    ConfigLoader
    Static::Simple
    
    CustomErrorMessage
    
    Authentication
	Authorization::Roles
	Authorization::ACL
	
	Scheduler
	
	Sitemap
	
	Cache
	PageCache
	
	Session 
	Session::Store::DBI
    Session::State::Cookie
    
    Compress::Gzip
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in site.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Site',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback	=>	1,
    enable_catalyst_header						=> 1, # Send X-Catalyst header
);

__PACKAGE__->config(
	'Auth' 	=> {
		'Provider'	=> {
			'Default'	=>	'Site',
			'Facebook'	=>	'Facebook',
			'Twitter'	=>	'Twitter'
		},
		'Config'	=>	{
			'Facebook'	=> {
				'Redirect_URL'			=>	'https://www.facebook.com/dialog/oauth?client_id=',
				'Access_Token_URL'		=>	'https://graph.facebook.com/oauth/access_token',
				'Graph_URL'				=>	'https://graph.facebook.com/me?',
				'Password_Reset_URL'	=>	'https://www.facebook.com/login/identify?ctx=recover',
				'Username_Retrieve_URL'	=>	'https://www.facebook.com/login/identify?ctx=recover&mode=yourname',
			},
			'Twitter'	=>	{
				'OAuth_Token_URL'		=>	'http://api.twitter.com/oauth/authenticate?oauth_token=',
				'Request_Token_URL'		=>	'https://api.twitter.com/oauth/request_token',
				'Access_Token_URL'		=>	'https://api.twitter.com/oauth/access_token',
				'Password_Reset_URL'	=>	'https://twitter.com/account/resend_password',
				'Username_Retrieve_URL'	=>	'https://support.twitter.com/articles/14608-i-m-having-trouble-with-my-username#'
			}
		},
		'Role'		=>	{
			'User'	=>	'User',
			'Admin'	=>	'Admin'
		},
		'Status'	=>	{
			'Active'	=>	'Active',
			'Inactive'	=>	'Inactive'
		}
	},
	'Observations'	=> {
		'UserObservation'	=>	'User',
		'Status'			=> {
			'Published'		=>	'Published',
			'Unpublished'	=>	'Unpublished',
			'Review'		=>	'Send For Review'	
		}
	}
);

__PACKAGE__->config('Plugin::Authentication' => 
	{
		default => {
			'password_type' =>	'self_check',
			'user_model'	=>	'DB::User',
			'class'			=>	'SimpleDB',
			'store'			=> {
				'class'			=>	'DBIx::Class',
				'role_relation'	=>	'roles',
				'role_field'	=>	'role'
			}
		},
		oauth	=> {
			'password_type' =>	'none',
			'user_model'	=>	'DB::User',
			'class'			=>	'SimpleDB',
			'store'			=> {
				'class'			=>	'DBIx::Class',
				'role_relation'	=>	'roles',
				'role_field'	=>	'role'
			}
		}
	}
);

__PACKAGE__->config('Plugin::Session' => {
	expires	=> 3600,
	dbi_dbh   => 'DB', # which means Site::Model::DB
	dbi_table => 'sessions',
    dbi_id_field => 'id',
	dbi_data_field => 'session_data',
    dbi_expires_field => 'expires',
});

# The JSON view config options (mostly used with AJAX)
__PACKAGE__->config->{'View::JSON'} = {
	allow_callback  => 1,    # defaults to 0
	callback_param  => 'cb', # defaults to 'callback'
	#vaues that can be sent via JSON data
	expose_stash => [ qw(
		isajax 
		isnumeric 
		issuccess 
		errormsg
		data 
		states 
		hosts 
		observations 
		images
	)],
}; 

__PACKAGE__->config(
    'Model::DB' => {
      	locationregex		=>	's|^.*?{(.*?),.*$||',
      	roles				=>	{
      		user_active	=>	'Active'
      	},
      	systemobservation	=>	'System',
      	userobservation		=>	'User',
      	systemcharactertype	=>	'All',
      	observationstatus	=>	{
			published	=>	'Published',
      		unpublished	=>	'Unpublished',
      		review		=>	'Send For Review',
      	}	
    }
);

 __PACKAGE__->config(
 	'Site::Controller::Organisms_REST' => {
        'default'   => 'application/json',
        'stash_key' => 'data',
        'map'       => {
            'application/json'	=> [ 'View', 'JSON' ]
        }
 	}
);



# The default view type 
__PACKAGE__->config(default_view => 'HTMLDesktop');

# Error age
__PACKAGE__->config->{'custom-error-message'}->{'uri-for-not-found'} = '/not-found';
__PACKAGE__->config->{'custom-error-message'}->{'error-template'}    = 'pages/404.tt';
__PACKAGE__->config->{'custom-error-message'}->{'content-type'}      = 'text/html; charset=utf-8';
__PACKAGE__->config->{'custom-error-message'}->{'view-name'}         = 'HTMLDesktop';
__PACKAGE__->config->{'custom-error-message'}->{'response-status'}   = 404;

# The folder for temporary uploads
__PACKAGE__->config( uploadtmp => Site->path_to('root','imagetmp')->stringify);

# The type of cache to use
__PACKAGE__->config->{'Plugin::Cache'}{backend} = {
	class => "Cache::FileCache",
    cache_root => Site->path_to('root','cache')->stringify
};

# Cahce configuration
__PACKAGE__->config(
	'Plugin::PageCache' => {
		expires				=> 300,
        set_http_headers 	=> 1,
        debug 				=> 1,
        auto_remove_stale  	=> 1,
        disable_index		=> 0,
        cache_hook			=> 'cache_hook_method',
        #cache_dispatch_hook => 'cache_dispatch_hook_method',
        #cache_finalize_hook => 'cache_finalize_hook_method',

        # key generation for page cache    
        key_maker 			=> sub {
			my $c = shift;
            my $key;
            my $layout;
            my $user;
            
            my $path = $c->req->path;
            my $config = lc($c->config->{Site}->{organisms});
            $path =~ s/organisms/$config/;
            $c->log->debug($c->req->action);
            if ((grep $_ eq $c->action->namespace, (qw/css js/)) 
            	|| (index($c->req->action, '.xml') != -1)
            	|| (index($c->req->action, '.txt') != -1)) {
				 return $c->req->base.$c->req->path;		
			}
			# check the config to see if IP addresses are set for Kiosk view
			if (
				(grep $_ eq $c->request->address, split(/,/,$c->config->{Layout}->{kiosk}->{ip})) &&
				($c->config->{Layout}->{kiosk}->{enabled} eq 1)
				) {
				$layout = "kiosk";
			}
			else {
				# check the user's session to see if the layout has been set
	            if (defined $c->session->{layout}) {
	               $layout = $c->session->{layout};
	            }
	            # get the device type and set the layout type for the key
				else {
					# get the user's browser
            		my $device = $c->model("Device::Type");
					if ($device->isTablet()) {
	               		$layout = "tablet";
	               	}
	               	elsif($device->isMobile()) {
	               		$layout = "mobile";
	               	}
	               	else {
	               		$layout = "desktop"
	               	}
				}
			}
              
            # if the user exists add user to key
            # this is used to differentiate logged in vs non logged in users  
            if ($c->user_exists) {
            	$user = 'user';
            }
            else {
            	$user = 'anonymous';
            }
                  
            $c->log->debug($c->req->path);
            # return the key
            return $user.'/'.$layout.'/'.$c->req->base.$path;
		},
		
	}
);
  
sub cache_hook_method {
        my ( $c ) = @_;
        
        use feature qw(switch);
        given ((caller(1))[3]){
        	when('Catalyst::Plugin::PageCache::dispatch') {
        		cache_dispatch_hook_method($c);	
        	}
        	when('Catalyst::Plugin::PageCache::finalize') {
        		cache_finalize_hook_method($c);	
        	}
        }
}

sub cache_dispatch_hook_method {
	my $c = shift;
	
	$c->log->debug("cache_dispatch_hook_method");
	
	my $isadmin = 0;
	
	if ($c->user_exists) {
		if (defined $c->session->{'cache_isadmin'}) {
			$isadmin = $c->session->{'cache_isadmin'};
		}
		else {
			$c->session->{'cache_isadmin'} = $c->check_any_user_role("Admin", "Reviewer");
			$isadmin = $c->check_any_user_role("Admin", "Reviewer");
		}	
	}	
    if ( 
    	Site->config->{Cache}->{enabled} &&
    	!defined $c->response->redirect() && 
    	(!$isadmin || grep $_ eq $c->action->namespace, (qw/css js/)) &&
		index($c->req->uri, '?') == -1 &&
		!defined $c->flash->{status_msg} &&
		!defined $c->flash->{error_msg}
    ) {
    	$c->log->debug("SERVING CACHE");
    	return 1; # Cache
	}
	else {
		$c->log->debug("NOT SERVING CACHE");
		 return 0; # Don't cache
	}
   
}

sub cache_finalize_hook_method {
	my $c = shift;
	
	$c->log->debug("cache_finalize_hook_method");
	
	my $isadmin = 0;
	
	if ($c->user_exists) {
		if (defined $c->session->{'cache_isadmin'}) {
			$isadmin = $c->session->{'cache_isadmin'};
		}
		else {
			$c->session->{'cache_isadmin'} = $c->check_any_user_role("Admin", "Reviewer");
			$isadmin = $c->check_any_user_role("Admin", "Reviewer");
		}	
	}	
	
    if ( 
    	Site->config->{Cache}->{enabled} &&
    	!defined $c->response->redirect() &&
    	(
    		(
 				defined $c->stash->{cache} && 
 				$c->stash->{cache} == 1 && 
 				!$isadmin
 			) ||
			(
				grep $_ eq $c->action->namespace, (qw/css js/)
			)
    	) &&
		index($c->req->uri, '?') == -1 &&
		!defined $c->flash->{status_msg}
    ) {
    	$c->log->debug("CACHING");
    	return 1; # Cache
	}
	else {
		$c->log->debug("NOT CACHING");
		 return 0; # Don't cache
	}
}

# Start the application
__PACKAGE__->setup();

Site->schedule(
	at       => '* * * * *',
	event    => '/cron/remove_sessions',
);

sub prepare_path {
	 my $c = shift;

	$c->maybe::next::method( @_ ) ;
	
	# Get the path
	my $path = $c->request->path;
	
	# Check to make sure it is a not an static (mostly images), javascript or css file
	if ( (index($path, 'static') == -1) && (index($path, '.js')  == -1) && (index($path, '.css')  == -1)) {
		my $organisms = lc(Site->config->{Site}->{organisms});
		my $organisms_singular = lc(Site->config->{Site}->{organisms_singular});
		# Replace organisms with the config file value
		$path =~ s/$organisms/organisms/i;
		$path =~ s/$organisms_singular/organism/i;
		# Change the path
		$c->request->path( $path ) ;
	}
}

sub uri_for {
	my $self = shift;
	my $uri = $self->maybe::next::method(@_);
	if ( (index($uri, 'static') == -1) && (index($uri, '.js')  == -1) && (index($uri, '.css')  == -1)) {
		my $replace = lc(Site->config->{Site}->{organisms});
		my $replace_singular = lc(Site->config->{Site}->{organisms_singular});
		$uri =~ s/organisms/$replace/i;
		$uri =~ s/organism/$replace_singular/i;
	}
	$uri;
} 


# Deny access to the User section for anyone without an User role
__PACKAGE__->deny_access_unless_any(
	"/user", [qw/User/]     
);

__PACKAGE__->deny_access_unless_any(
	"/user_rest", [qw/User/]     
);


__PACKAGE__->acl_add_rule(
	"/authentication/registerOAuth",
	sub {
		my ( $c, $action ) = @_;

		use Catalyst::Plugin::Authorization::ACL::Engine qw($ALLOWED $DENIED);
		if ( defined $c->session->{oauthinfo} ) {
			die $ALLOWED;
        } 
        else {
        	die $DENIED;
        }
	}
); 

__PACKAGE__->allow_access(
	"/user_rest/uploadPicupImage",
);

# Deny access to the admin section for anyone without an Admin role
__PACKAGE__->deny_access_unless_any(
	"/admin", [qw/Admin/]     
);

__PACKAGE__->deny_access_unless_any(
	"/admin_rest", [qw/Admin/]     
);

# Deny access to the admin section for anyone without an Admin role
__PACKAGE__->deny_access_unless_any(
	"/review", [qw/Admin Reviewer/]     
);

__PACKAGE__->acl_add_rule(
	"/authentication",
	sub {
		my ( $c, $action ) = @_;
		
		use Catalyst::Plugin::Authorization::ACL::Engine qw($ALLOWED $DENIED);
		if ( $c->user() ) {
			die $DENIED;
        } 
        else {
        	die $ALLOWED;
        }
	}
); 

__PACKAGE__->acl_add_rule(
	"/authentication/login_redirect",
	sub {
		my ( $c, $action ) = @_;
		
		use Catalyst::Plugin::Authorization::ACL::Engine qw($ALLOWED $DENIED);
		if ( $c->user() ) {
			die $ALLOWED;
        } 
        else {
        	die $DENIED;
        }
	}
); 


=cut
 
=cut
sub dump_these {
    my $c = shift;
    my @variables = $c->SUPER::dump_these();
    return grep { $_->[0] ne 'Config' } @variables;
} 


=head1 NAME

Site - Catalyst based application

=head1 SYNOPSIS

    script/site_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Site::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
