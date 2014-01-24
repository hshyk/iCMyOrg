package Site::Action::AuthUser;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use feature qw(switch);


=head1 NAME

Site::Controller::Action::AuthUser - Action

=head1 DESCRIPTION

Action - Common authentication methods

=head1 METHODS

=cut 

=head2 authenticate_default
 
Authenticate the user against the site

=cut    
sub authenticate_default :Private {
	my ($self, $c, $info) = @_;
	
	# Check if the user is authenticated with the site
	if ($c->authenticate(
		{ 
			username	=>	$info->{username}, 
			password	=>	$info->{password},
			provider_id	=>	$c->model("DB::Authprovider")->findProviderIDByName($info->{provider})
		}
	)) {
		# Set cookie to tell that the user has logged in
		$c->response->cookies->{hasloggedin} = 
		{ 
			value	=>	'1', 
			expires	=>	'+1d'
		};
	
		$c->detach('login_redirect');
	}
	else {
		$c->stash(error_msg	=>	"This username or password is incorrect");
		return 0;
	}
}

=head2 authenticate_oauth
 
Authenticate the user against a 3rd party OAuth authentication

=cut  
sub authenticate_oauth :Private {
	my ($self, $c, $info) = @_;

	# Check if the user is authenticated with OAuth against the site
	if ($c->authenticate(
		{
			authid		=>	$info->{authid}, 
			provider_id	=>	$c->model("DB::Authprovider")->findProviderIDByName(
				$info->{provider}
			)
		 }, 
		'oauth' 
	)) {
		
		# Set cookie to tell that the user has logged in
		$c->response->cookies->{hasloggedin} = 
		{ 
			value	=>	'1',  
			expires	=>	'+1d'
		};
		
		# Remove the registration data needed for the form from session
		$c->session->{oauthinfo} = undef;
		
		# Check the login redirection
		$c->detach('login_redirect');
	}
	else {
		return 0;
	}
}

=head2 login_redirect
 
Set where the user goes after login

=cut  
sub login_redirect	:Private	{
	my ($self, $c) = @_;
	
	my $redirect;
	# If the user is active continue, otherwise send them back to the login page saying they are banned
	if ($c->user()->check_status($c->config->{Auth}->{Status}->{Active})) {
		
		# If the user was at a previous page that kicked them over to the login, send them back	
		if (defined $c->session->{login_redirect}) {
			$redirect = $c->session->{login_redirect};
			$c->session->{login_redirect} = undef;
		}
		else {
			# Default user front page
			$redirect = $c->uri_for(
				$c->controller(
					'User'
				)->action_for(
					'index'
				)
			)
		}
		
	}
	else {
		# Clear the user's state
		$c->logout;
		$c->flash(status_msg	=>	'This user has been banned');
		# Set the redirect back to the login page
		$redirect = $c->uri_for(
			$c->controller(
				'Authentication'
			)->action_for(
				'login'
			)
		);
	}
	
	# Redirect the user where they need to go
	$c->response->redirect($redirect);
}

=head2 facebook_login
 
Redirect to the Facebook login page

=cut  
sub facebook_login	:Private {
	my ($self, $c) = @_;
	
	# If the code has not been sent that means the user has not been authenticated with Facebook
	if (defined($c->request->params->{code}) eq '') {
		$c->session->{facebook_state} = join('',Data::Random::rand_chars(size=>16, set=>'alphanumeric'));
		
		# Redirect to Facebook OAuth login
		$c->response->redirect(
			$c->model('OAuth::Facebook')->redirect_url(
				$c->uri_for($c->controller('Authentication')->action_for('loginFacebook')),
				$c->session->{facebook_state},
				$c->model("Device::Type")->isMobile()
			)
		);
		return;
	}
}

=head2 facebook_login
 
Get the user info from Facebook

=cut  
sub facebook_request :Private {
	my ($self, $c) = @_;
	
	# If the returning state parameter matches what was sent to Facebook (stored in session), then grab the user info from Facebook
	if ($c->session->{facebook_state} eq $c->request->params->{state}) {
		return $c->model('OAuth::Facebook')->request(
			$c->request->params->{code}, 
			$c->uri_for($c->controller('Authentication')->action_for('loginFacebook')),
		);
	}
	
	return 0;
}

=head2 twitter_login
 
Redirect to the Twitter login page

=cut  
sub twitter_login :Private {
	my ($self, $c) = @_;
	
	# get the request token from twitter
	my $data = $c->model("OAuth::Twitter")->request_token(
		$c->uri_for($c->controller('Authentication')->action_for('loginTwitter'))
	);
	
	# save the token data in session because the user is being redirected to the twitter site
	$c->session->{'twitter_request_token'} = $data->token;
	$c->session->{'twitter_request_token_secret'} = $data->token_secret;
			
	#redirect to the twitter site
	$c->response->redirect(
		$c->model('OAuth::Twitter')->redirect_url(
			$data->token
		)
	);
}

=head2 facebook_login
 
Get the user info from Twitter

=cut  
sub twitter_request :Private {
	my ($self, $c) = @_;
	
	# check to see if the request token and token secret are set
	if ($c->session->{'twitter_request_token'} && $c->session->{'twitter_request_token_secret'}){
		# send the request tokens to twitter
		my $oauthUser = $c->model("OAuth::Twitter")->request_user(
			$c->session->{'twitter_request_token'},
			$c->session->{'twitter_request_token_secret'},
			$c->request->params->{oauth_verifier},
		);
	
		# remove the request token from the session in case we need to request the user again
		$c->session->{'twitter_request_token'} = undef;
		$c->session->{'twitter_request_token_secret'} = undef;
		
		return $oauthUser;
	}	
	
	return 0;
}

1;