package Site::Form::Authentication::Register;
use HTML::FormHandler::Moose;
extends 'Site::Form::Base::User';
use namespace::autoclean;
use String::Random;


=head1 NAME

Site::Form::Authentication::Register - HTML FormHandler Form

=head1 DESCRIPTION

Register the user

=head1 METHODS

=cut

has_field 'username'	=>	(
	type		=>	'Text',
	label		=>	'Username', 
	minlength	=>	6, 
	maxlength	=>	40, 
	required	=>	1,  
	size		=>	40,   
	apply		=>	[
		{ 
			check	=>	qr/^[a-zA-Z0-9]+$/,
            message	=>	'You may only enter letters and numbers'
     	}
     ]
);
has_field 'password'	=>	(
	type		=>	'Password', 
	label		=>	'Password', 
	minlength	=>	6, 
	maxlength	=>	40, 
	required	=>	1, 
	size		=>	40 
);
has_field 'password_conf'	=>	(
	type		=>	'PasswordConf', 
	label		=>	'Confirm your Password', 
	minlength	=>	6, 
	maxlength	=>	40, 
	required	=>	1,  
	size		=>	40 
);

has_field 'recaptcha'	=>	(
	type				=>	'reCAPTCHA',
    label				=>	'Verify Code', 
    public_key			=>	Site->config->{reCAPTCHA}->{public_key},
    private_key			=>	Site->config->{reCAPTCHA}->{private_key},
    recaptcha_message	=>	"You did not enter the code properly",
    required			=>	1,
    inactive			=>	1
); 

has_field 'submit'	=>	( 
	type	=>	'Submit', 
	value	=>	'Submit' 
);

has 'status' => (
	isa	=> 'Str',
	is	=> 'rw'
);

has 'provider' => (
	isa	=> 'Str',
	is	=> 'rw'
);

has 'role' => (
	isa	=> 'Str',
	is	=> 'rw'
);

has 'remote_address' => (
	isa	=>	'Str',
	is	=>	'rw'
);

has 'authid' => (
	isa	=>	'Str',
	is	=>	'rw'
);

has 'authusername'	=>	(
	isa	=>	'Str',
	is	=>	'rw'
);

has 'isoauth' => (
	isa				=>	'Int',
	is				=>	'rw',
	default			=> 0
);

=head2 before process

Set the IP Address of the user in the environment. This is needed for the reCaptcha Module

=cut
before process => sub {
    my ($self) = @_;
	$ENV{REMOTE_ADDR} = $self->remote_address;
};
  
=head2 before 'update_model'

Set the status, provider, username, authid and a random password (if OAuth)

=cut 
before 'update_model' => sub {
	my $self = shift;
	
	# Set the status
	$self->item->status_id(
		$self->schema->resultset("Status")->findStatusIDByName(
			$self->status
		)
	);
	
	# Set the authentication provider
	$self->item->provider_id(
		$self->schema->resultset("Authprovider")->findProviderIDByName(
			$self->provider
		)
	);
	
	# If the user is registering with a 3rd party site then create a random password	
	if ($self->isoauth) {
		my $pass = new String::Random;
		$self->item->username(
			$self->authusername
		);
		$self->item->password(
			$pass->randpattern("sssssssssssss")
		);
		$self->item->authid(
			$self->authid
		);
		
	}
	else {
		$self->item->authid(
			$self->field('username')->value
		);
	}

};

=head2 around 'update_model'

Create the user's role

=cut 
around 'update_model' => sub {
	my $orig = shift;
    my $self = shift;
    my $item = $self->item;
	
	# Do in a transaction so that all users must have roles
	$self->schema->txn_do( sub {
		$self->$orig(@_);
	
		$item->create_related(
			'users_roles',
			{
				role_id => $self->schema->resultset("Role")->findRoleIDByName(
					$self->role
				)
			},
		);     
	});
};

=head2 validate_username

Make sure the username does not exist

=cut 
sub validate_username {
	my ($self) = shift;

	# Exists if there are no users with that username (registered with the site)
	return unless $self->schema->resultset('User')->search(
		{
			username => $self->field('username')->value,
			'provider.provider_name' => $self->provider,
		},
		{
			join => 'provider'
		}	
	)->count > 0;
	
	$self->field('username')->add_error(
		'This username is already in use'
	);
}



__PACKAGE__->meta->make_immutable;
1;