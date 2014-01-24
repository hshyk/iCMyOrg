package Site::Controller::Authentication;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use feature qw(switch);

use Site::Form::Authentication::LoginSite;
use Site::Form::Authentication::Register;
use Site::Form::Authentication::ForgotPassword;
use Site::Form::Authentication::ForgotUsername;
use Site::Form::Authentication::ResetPassword;

with 'Site::Action::FormProcess';
with 'Site::Action::AuthUser';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::Authentication - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller - Handles registration and authentication

=head1 METHODS

=cut


=head2 base

Base method

=cut

sub base :Chained('/') :PathPart('') :CaptureArgs(0) {
	my ($self, $c) = @_;
		
}

=head2 access_denied

What to do when access is denied

=cut
sub access_denied : Private {
    my ( $self, $c, $action ) = @_;

	$c->response->redirect(
		$c->uri_for($c->controller('Pages')->action_for('index'))
	);

}

=head2 login
 
Shows the login page for users and links to the other login methods

=cut
sub login :Chained('base') :PathPart('login') :Args(0) {
	my ($self, $c) = @_;
	
	# Process the form
	if ($c->forward('formprocess_nomodel',[
		Site::Form::Authentication::LoginSite->new(),
		'authentication/login.tt'
	])) {
		# If login validation passed then authenticate the user using the default portal
		$c->detach('authenticate_default',	[
	 		{
	 			username	=>	$c->request->params->{username},
	 			password 	=>	$c->request->params->{password},
	 			provider	=>	$c->config->{Auth}->{Provider}->{Default}
	 		}
	 	]);
	}
	
	$c->stash(
		cache		=>	1,
	);

}


=head2 register

Shows the register page for different types of registration methods.

=cut
sub register :Chained('base') :PathPart('register') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		template	=>	'authentication/register.tt',
		cache		=>	1,
	);
}

=head2 registerSite

Show the registration form for the site. If the form is validated, register the user and authenticates them

=cut
sub registerSite :Chained('base') :PathPart('register/site') :Args(0) {
	my ($self, $c) = @_;

	try {
		
		# Check to see if reCAPTCHA is enabled
		my $active = [];
		
		if ($c->config->{reCAPTCHA}->{enabled}) {
			push($active, 'recaptcha');
		}

		# If the form is processed and validated register the user
		if ($c->forward('formprocess',[
			Site::Form::Authentication::Register->new(
				schema			=>	$c->model("DB")->schema,
				status			=>	$c->config->{Auth}->{Status}->{Active},
				provider		=> 	$c->config->{Auth}->{Provider}->{Default},
				role 			=>	$c->config->{Auth}->{Role}->{User},
				remote_address	=>	$c->request->address,
				active			=>	$active
			),
			# New user record
			$c->model('DB::User')->new_result(
				{}
			),
		 	"Thank you for registering", 
		 	"We are unable to register you", 
		 	'authentication/registersite.tt'
		 ])) {
					
			# Check the user authentication
	 		if (!$c->detach(
	 			'authenticate_default',
	 			[
	 				{
	 					username	=>	$c->request->params->{username},
	 					password 	=>	$c->request->params->{password},
	 					provider	=>	$c->config->{Auth}->{Provider}->{Default},
	 				}
	 			]	 			
	 		)){
				$c->stash(
					error_msg	=>	'There was a problem logging in after registration.'
				);		
			}
			else {
				$c->stash->{email} = {
	            	to      => $c->user()->email,
	            	from		=>	$c->config->{Email}->{default_from},
	            	subject	=> 'Thank you for registering!',
	            	template	=> 'thankyouregister.tt',
        		};
        		$c->forward( $c->view('Email'));
			}
	 	
	 	}
	 	else {
	 		
	 		if ($c->request->method eq 'POST') {
		 		$c->stash(
					error_msg	=>	'We are not able to complete the registration.  Please fix the errors below.'
				);
	 		}
	 		else {
				 # Cache the page
				$c->stash(
					cache	=>	1
				);
	 		}
	 	}	
	}
	catch {
		$c->stash(
			error_msg	=>	'There was an error with your registration.'
		);
 	}	 		
}

=head2 registerOAuth

Show the registration form for a user that is using OAuth. Any default form information comes from the session data

=cut
sub registerOAuth :Chained('base') :PathPart('register/oauth') :Args(0) {
	my ( $self, $c ) = @_;
	
	try {
		
		#If the form is processed and validated, register the user
		if ($c->forward('formprocess',[
			Site::Form::Authentication::Register->new(
				schema		=>	$c->model("DB")->schema,
				inactive 	=> [
					'username',
					'password',
					'password_conf',
				],
				isoauth			=>	1,
				status			=>	$c->config->{Auth}->{Status}->{Active},#USER_STATUS_ACTIVE,
				provider		=>	$c->session->{oauthinfo}->{provider},
				role			=>  $c->config->{Auth}->{Role}->{User},#ROLE_USER,
				authusername	=>  $c->session->{oauthinfo}->{username},
				authid			=>  $c->session->{oauthinfo}->{oauth_id},
				remote_address	=>	$c->request->address,
				init_object		=>	{
					email		=>	$c->session->{oauthinfo}->{email},
					first_name 	=>	$c->session->{oauthinfo}->{first_name},
					last_name	=>	$c->session->{oauthinfo}->{last_name},
				}
			),
			# New User
			$c->model('DB::User')->new_result(
				{}
			),
		 	"Thank you for registering", 
		 	"We are unable to register you", 
		 	'authentication/registersite.tt'
		 ])) {
				
			# Check the user authentication with OAuth
	 		if ($c->forward(
	 			'authenticate_oauth',[
	 				{
	 					authid	=>	$c->session->{oauthinfo}->{oauth_id},
	 					provider	=>	$c->session->{oauthinfo}->{provider}
	 				}
	 			])) {
				$c->stash->{email} = {
	            	to      => $c->user()->email,
	            	from		=>	$c->config->{Email}->{default_from},
	            	subject	=> 'Thank you for registering!',
	            	template	=> 'thankyouregister.tt',
        		};
        		$c->forward( $c->view('Email'));
			}
			else {
				$c->stash(error_msg	=>	'There was a problem logging in your user after registration');
				
			}
	 	
	 	}	
	}
	catch {
		$c->stash(
			error_msg	=>	'There was en error with your registration'
		);
	}
	
}


=head2 loginFacebook

Uses OAuth for Facebook validation

=cut
sub loginFacebook :Chained('base') :PathPart('login/facebook') :Args(0) {
	my ( $self, $c ) = @_;
	
	# Run the action for Facebook Login
	$c->forward(
		'facebook_login'
	);
	
	# Grab the oauth info value		
	my $oauthUser = $c->forward(
	 	'facebook_request'
	 );
		
	# Checks if the info was grabbed succesfully
	if ($oauthUser) {		
		# Trys to authenticate the user.  If the user cannot be authenticated, then they are sent to the registration page
		if ($c->forward(
	 		'authenticate_oauth',
	 		[
	 			{
	 				authid		=>	$oauthUser->{'id'}, 
					provider	=>	$c->config->{Auth}->{Provider}->{Facebook},
	 			}
	 		]	 			
	 	)) {
		}
		else {
			
			# Clear the OAuth info in case any of it remained
			$c->session->{oauthinfo} = undef;
	
			# Set the user values passed from Facebook
			$c->session->{oauthinfo} = {
				provider	=>	$c->config->{Auth}->{Provider}->{Facebook},
				first_name	=>	$oauthUser->{'first_name'},
				last_name	=>	$oauthUser->{'last_name'},
				email		=>	$oauthUser->{'email'},
				username	=>	$oauthUser->{'name'},
				oauth_id	=>	$oauthUser->{'id'},
			};
			
			# Redirect the user to the OAuth registration form
			$c->response->redirect(
				$c->uri_for(
					$c->controller(
						'Authentication'
					)->action_for(
						'registerOAuth'
					)
				)
			);
		}	
	}
	else {
		$c->stash(
			template	=>	'authentication/errorlogin.tt'
		);
	}

}

=head2 loginTwitter

Uses OAuth for Twitter validation

=cut
sub loginTwitter :Chained('base') :PathPart('login/twitter') :Args(0) {
	my ( $self, $c ) = @_;

	# Run the action for Twitter Login
	my $oauthUser = $c->forward(
		 'twitter_request'
	);
	
	# Checks if the info was grabbed succesfully
	if ($oauthUser) {
					
		# Trys to authenticate the user.  If the user cannot be authenticated, then they are sent to the registration page
		if ($c->forward(
	 		'authenticate_oauth',
	 		[
	 			{
	 				authid => $oauthUser->{'extra_params'}->{'user_id'}, 
					provider => $c->config->{Auth}->{Provider}->{Twitter},
	 			}
	 		]	 			
	 	)) {
		}
		else {
			
			# Clear the OAuth info in case any of it remained	
			$c->session->{oauthinfo} = undef;
					
			# Set the user values passed from Twitter
			$c->session->{oauthinfo} = {
				provider	=>	$c->config->{Auth}->{Provider}->{Twitter},
				username	=>	$oauthUser->{'extra_params'}->{'screen_name'},
				oauth_id	=>	$oauthUser->{'extra_params'}->{'user_id'},
			};
					
			# Redirect the user to the OAuth registration form
			$c->response->redirect(
				$c->uri_for(
					$c->controller(
						'Authentication'
					)->action_for(
						'registerOAuth'
					)
				)
			);
		}
		$c->stash(
			template	=>	'authentication/errorlogin.tt'
		);
	}
	else {
		# No Twitter info so send to Twitter login	
		$c->forward(
	 		'twitter_login'
		);
	}
}

=head2 forgotPassword

Form to reset a user's password

=cut
sub forgotPassword :Chained('base') :PathPart('login/forgot-password') :Args(0) {
	my ($self, $c) = @_;
	
	# If the form was submitted then go through finding the user
	if ($c->forward(
		'formprocess',[
		Site::Form::Authentication::ForgotPassword->new(
			schema	=>	$c->model("DB")->schema,
		), 
		undef,
	 	"Please check your email and follow the instructions to reset your password.", 
	 	"We are unable to process your request.", 
	 	'authentication/forgotpassword.tt',
	 ])){
		
		# Find the user by email or username
	 	my $user = $c->model('DB::User')->search(
	 		{
	 			-or => {
	 				'email'		=>	$c->request->params->{username_email},
	 				'username'	=>	$c->request->params->{username_email},
	 			}
	 		}
	 	)->first;
	 	
	 	# Make sure the user exists
	 	if (defined $user) {
	 	
		 	my $template = 0;
		 	
		 	# Get the user type from the URL so that the user can be found
			# Depending on the type of user different emails will be needed
			given ($user->provider->provider_name) {
				when ($c->config->{Auth}->{Provider}->{Facebook}) {
					 $c->stash(
					 	provider	=>	$c->config->{Auth}->{Provider}->{Facebook},
						resetlink	=>	$c->config->{Auth}->{Config}->{Facebook}->{Password_Reset_URL},
					);
					$template = 'resetpasswordoauth.tt';
				}
				when ($c->config->{Auth}->{Provider}->{Twitter}) {
					 $c->stash(
					 	provider	=>	$c->config->{Auth}->{Provider}->{Twitter},
						resetlink	=>	$c->config->{Auth}->{Config}->{Twitter}->{Password_Reset_URL},
					);
					$template = 'resetpasswordoauth.tt';
				}
				# When the user is registered with the site then they will have a password reset code generated
				when ($c->config->{Auth}->{Provider}->{Default}) {
					my $randomString = join('',Data::Random::rand_chars(size=>16, set=>'alphanumeric'));
					if ($user->update(
						{
							forgot_password	=>	$randomString
						}
					)) {
						 $c->stash(
						 	code	=>	$randomString
						 );
						$template = 'resetpassworddefault.tt'
					}
				}
			}
	 	
	 	# If there is a template then send the email with a reset link
	 	if ($template) {
	 		$c->stash->{email} = {
	            to			=>	$user->email,
	            from		=>	$c->config->{Email}->{default_from},
	            subject		=>	'Password Reset',
	            template	=>	$template,
        	};
        	$c->forward( $c->view('Email'));
			if (scalar(@{ $c->error })) {
				$c->stash(
					error_msg	=>	"There was a problem sending your password reset email."
				);
			}
			else {
				$c->stash(
					template	=>	'authentication/forgotpasswordsuccess.tt'
				)
			}
	 	}
	 }
		 else {
		 	$c->stash(
				error_msg	=>	"We could not find your username or email."
			);
		 }
	 }
	
	# Cache the page 
	$c->stash(
		cache	=>	1,
	);

}

=head2 forgotUsername

Form to send an email with the users username

=cut

sub forgotUsername :Chained('base') :PathPart('login/forgot-username') :Args(0) {
	my ($self, $c) = @_;
	
	# If the form was submitted then go through finding the user
	if ($c->forward('formprocess',[
		Site::Form::Authentication::ForgotUsername->new(
			schema	=>	$c->model("DB")->schema,
		), 
		undef,
	 	"Your username has been sent to your email.", 
	 	"We are unable to process your request.", 
	 	'authentication/forgotusername.tt',
	 ])){
 		
 		# Find the user by email or username
	 	my $user = $c->model('DB::User')->find(
	 		{
	 			'email'	=>	$c->request->params->{email}
	 		}
		);
	  	
	  	# Make sure the user exists
		if (defined $user) {
	 	
		 	my $template = 0;
		 	
			#send the info to the user based on the type of authentication they use
			given ($user->provider->provider_name) {
				when ($c->config->{Auth}->{Provider}->{Facebook}) {
					 $c->stash(
					 		provider	=>	$c->config->{Auth}->{Provider}->{Facebook},
						 	resetlink 	=>	$c->config->{Auth}->{Provider}->{Facebook}->{Username_Retrieve_URL},
					);
					$template = 'retrieveusernameoauth.tt';
				}
				when ( $c->config->{Auth}->{Provider}->{Twitter}) {
					 $c->stash(
					 		provider	=>	$c->config->{Auth}->{Provider}->{Twitter},
						 	resetlink	=>	$c->config->{Auth}->{Provider}->{Twitter}->{Username_Retrieve_URL},
					);
					$template = 'retrieveusernameoauth.tt';
				}
				when ($c->config->{Auth}->{Provider}->{Default}) {
					$c->stash(
						 username	=>	$user->username
					);
					$template = 'retrieveusernamedefault.tt'
				}
			}
	 	
	 	# Send the email to user with their username or finding username through other providers
	 	if ($template) {
	 		$c->stash->{email} = {
	            to			=>	$user->email,
	            from		=>	$c->config->{Email}->{default_from},
	            subject		=>	'Username Retrieval',
	            template	=>	$template,
        	};
        	$c->forward( $c->view('Email'));
			if (scalar(@{ $c->error })) {
				$c->stash(
					error_msg	=>	"There was a problem sending your username retrieval email."
				);
			}
			else {
				$c->stash(
					template	=>	'authentication/forgotusernamesuccess.tt'
				)
			}
	 	}
	 }
	 else {
	 	$c->stash(
			error_msg	=>	"We could not find your username."
		);
	 }
	}
	
	# Cache the page 
	$c->stash(
		cache	=>	1,
	);
}

=head2 resetPassword

The page to reset the user's password

=cut
sub resetPassword :Chained('base') :PathPart('login/reset-password') :Args(1) {
	my ($self, $c, $code) = @_;

	try {
		
		# Find the user with the code
		my $user = $c->model('DB::User')->find(
			{
				forgot_password	=>	$code
			}
		);
		
		# If no user found send to 404 page
		if (!defined $user) {
			$c->detach(
				'Root',
				'default'
			);
			exit();
		}

		# Show the reset form
		$c->forward('formprocess_redirect',[
			Site::Form::Authentication::ResetPassword->new(
				schema	=>	$c->model("DB")->schema,
			),
			$user,
		 	"Your password has been reset succesfully", 
		 	"We are unable to update your password", 
		 	'authentication/resetpassword.tt',
		 	$c->controller(
		 		'Authentication'
		 	)->action_for(
		 		'login'
		 	)
		 ]);
	}
	catch {
		$c->stash(
			error_msg	=>	'There was en error with your password reset'
		);
 	}	 		
}




=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
