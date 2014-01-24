package Site::Form::Authentication::ResetPassword;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

use Data::Random;

=head1 NAME

Site::Form::Authentication::ResetPassword - HTML FormHandler Form

=head1 DESCRIPTION

Form to reset the user's password

=head1 METHODS

=cut

has '+item_class'	=>	(	
	default	=>	'User' 
);

has_field 'password'	=>	(
	type		=>	'Password',
	label		=>	'Password',
	minlength	=>	6, 
	maxlength	=>	40, 
	required	=>	0,  
	size		=>	40
);

has_field 'passwordconf'	=>	(
	type		=>	'PasswordConf',
	label		=>	'Confirm Password', 
	minlength	=>	0, 
	maxlength	=>	100, 
	size		=>	40, 
	unique		=>	0
);

has_field 'submit'	=>	( 
	type	=>	'Submit', 
	value	=>	'Submit' 
);


__PACKAGE__->meta->make_immutable;
1;