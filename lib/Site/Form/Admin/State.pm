package Site::Form::Admin::State;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::State - HTML FormHandler Form

=head1 DESCRIPTION

Add states to organisms

=head1 METHODS

options_character_id


=cut

has '+item_class' => ( default =>'State' );
has_field 'state_name' => (type => 'Text',label => 'State', minlength => 1, maxlength => 40, required => 1);
has_field 'character_id'  => (type => 'Select', label => 'Character', required => 1 );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

=head2 options_character_id

Sets the list of characters for the dropdown

=cut

sub options_character_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the characters and sort them by their name
	my @rows = $self->schema->resultset('Character')->search( 
																{}, 
																{order_by => ['character_name']}
															)->all;
	
	#return a map for use in the dropdown menu
	return [ map { $_->character_id, $_->character_name } @rows ];

}


__PACKAGE__->meta->make_immutable;
1;