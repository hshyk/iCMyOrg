package Site::Form::Base::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

use namespace::autoclean;


=head1 NAME

Site::Form::Base::User - HTML FormHandler Form

=head1 DESCRIPTION

Register the user

=head1 METHODS

update_model
validate_username

=cut

has '+item_class' => ( default =>'User' );

has_field 'email' => ( type => 'Email', label => 'Email', minlength => 1, maxlength => 100, size => 40, required => 1,	unique => 1 );
has_field 'first_name' => (	type => 'Text',	label => 'First Name', 	minlength => 1,	maxlength => 50, size => 40, required => 1 );
has_field 'last_name' => (	type => 'Text',	label => 'Last Name', 	minlength => 1, 	maxlength => 70, 	size => 40, required => 1 );




__PACKAGE__->meta->make_immutable;
1;