package Site::Form::Authentication::ForgotPassword;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;


=head1 NAME

 Site::Form::Authentication::ForgotPassword - HTML FormHandler Form

=head1 DESCRIPTION

FormHandler Form - Password reset form either from email or username

=head1 METHODS

=cut

has '+item_class' => ( 
	default	=>	'User' 
);

has_field 'username_email' => (
	type		=>	'Text',
	label		=>	'Please enter your username or email', 
	minlength	=>	6, 
	maxlength	=>	100, 
	required	=>	1,  
	size		=>	40
);

has_field 'submit' => ( 
	type	=>	'Submit', 
	value	=>	'Submit' 
);

=head2 validate_username_email()
 
Validate either the username or email

=cut      
sub validate_username_email {
	my ($self) = shift;
	
	# Check to make sure either the username or email exists
	return 1 unless $self->schema->resultset('User')->search(
	 	{
	 		-or => {
	 			'email'	=>	$self->field('username_email')->value,
	 			'username'	=>	$self->field('username_email')->value,
	 		}
	 	}
	 )->count < 1;
	 
	 $self->field('username_email')->add_error(
		'We could not find your username or email'
	);
}

__PACKAGE__->meta->make_immutable;
1;