package Site::Form::Authentication::LoginSite;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
use namespace::autoclean;

=head1 NAME

Site::Form::Authentication::LoginSite - HTML FormHandler Form

=head1 DESCRIPTION

Login the user

=head1 METHODS

=cut

has '+item_class'	=> ( 
	default	=>	'User' 
);

has_field 'username'	=> ( 
	type		=>	'Text', 
	label		=>	'Username', 
	required	=>	1, 
	size		=>	40 
);

has_field 'password'	=> (
	 type		=>	'Password', 
	 label		=>	'Password', 
	 required	=>	1,  
	 size		=>	40 
);

has_field 'submit'	=> ( 
	type	=>	'Submit', 
	value	=>	'Login' 
);

=head2 validate

Validation returns true as user authentication is done in the controller

=cut
sub validate {
	
	return 1;	
	
}

__PACKAGE__->meta->make_immutable;
1;