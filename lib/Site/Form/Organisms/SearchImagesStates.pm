package Site::Form::Organisms::SearchImagesStates;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Organisms::SearchImagesStates - HTML FormHandler Form

=head1 DESCRIPTION

The form for searching for organisms' states

=head1 METHODS

=cut

has '+item_class' => ( default =>'ObservationimagesState' );
has_field 'character_type_id' => (type => 'Select',label => 'Life Stage',required => 0);
has_field 'character_id' => (type => 'Select',label => 'Characterstics',required => 0);
has_field 'state_id' => (type => 'Select',label => 'State',required => 0);
has_field 'submit' => ( type => 'Submit', value => 'Find Images' );


sub options_character_type_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the characters (except for the All type) and sort them by their name
	my @rows = $self->schema->resultset('Charactertype')->searchDisplay();
	
	#return a map for use in the dropdown menu
	return [ map { $_->character_type_id, $_->character_type } @rows ];

}
__PACKAGE__->meta->make_immutable;
1;