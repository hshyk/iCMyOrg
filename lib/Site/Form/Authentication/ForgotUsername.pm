package Site::Form::Authentication::ForgotUsername;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Authentication::ForgotUsername - HTML FormHandler Form

=head1 DESCRIPTION

FormHandler Form - Username retrieval form by email

=head1 METHODS

=cut

has '+item_class'	=>	( 
	default	=>	'User' 
);

has_field 'email'	=> (
	type		=>	'Text',
	label		=>	'Please enter your email', 
	minlength	=>	6, 
	maxlength	=>	100, 
	required	=>	1,  
	size		=>	40, 
	unique		=>	0
);

has_field 'submit'	=>	( 
	type	=>	'Submit', 
	value	=>	'Submit' 
);

=head2 validate_email()
 
Check to make sure the email exists

=cut     
sub validate_email {
	my ($self) = shift;
	
	# Check if the email exists
	return 1 unless $self->schema->resultset('User')->search(
	 	{
	 		'email'	=>	$self->field('email')->value,
	 	}
	 )->count < 1;
	 
	 $self->field('email')->add_error(
		'We could not find your email'
	);
}

=head2 update_model()
 
Nothing to update in the database

=cut     
sub update_model	{
	my ($self) = shift;
	
	return 1;
}

__PACKAGE__->meta->make_immutable;
1;