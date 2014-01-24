package Site::Form::Admin::User;

use HTML::FormHandler::Moose;
extends 'Site::Form::Base::User';
use namespace::autoclean;
use String::Random;


=head1 NAME

Site::Form::Authentication::Register - HTML FormHandler Form

=head1 DESCRIPTION

Register the user

=head1 METHODS

before process
before 'update_model'
validate_username

=cut

has_field 'username' => (
	type => 'Text',
	label => 'Username', 
	minlength => 6, 
	maxlength => 40, 
	required => 1,  
	size => 40,   
	apply => [
         { 
         	check   => qr/^[a-zA-Z0-9]+$/,
            message => 'You may only enter letters and numbers'
     	}
     ]
);

has_field 'roles'  => (type => 'Multiple', label => 'Roles', required => 1,  );

has_field 'status_id'  => (type => 'Select', label => 'Status', required => 1 );
has_field 'submit' => ( 
	type => 'Submit', 
	value => 'Submit' 
);

=head2 options_state_id

Set the options of the state dropdown

=cut

sub options_roles {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#grab all of the state values and grab the character value of it
	#sort the states by their name
	my @rows = $self->schema->resultset('Role')->search()->all;
	
	#return a map for use in the dropdown menu														   
	return [ map { $_->role_id, $_->role} @rows ];

}

sub options_status_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#grab all of the state values and grab the character value of it
	#sort the states by their name
	my @rows = $self->schema->resultset('Status')->search()->all;
	
	#return a map for use in the dropdown menu														   
	return [ map { $_->status_id, $_->status_name} @rows ];

}

sub validate_username {
	my ($self) = shift;
	
	return unless $self->field('username')->value ne $self->item->username;
	#exists if there are no users with that username
	return unless $self->schema->resultset('User')->search(
		{
			username => $self->field('username')->value,
			'provider.provider_name' => $self->item->provider->provider_name,
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