package Site::Form::Admin::ImageState;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::ImageState - HTML Formhandler Class

=head1 DESCRIPTION

Add a state to a an image for examples

=head1 METHODS

options_state_id

=cut

has '+item_class' => ( default =>'ObservationimagesState' );
has_field 'image_id' => (type => 'Hidden',required => 1);
has_field 'state_id'  => (type => 'Select', label => 'State', required => 1 );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );




=head2 options_state_id

Set the options of the state dropdown

=cut

sub options_state_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#grab all of the state values and grab the character value of it
	#sort the states by their name
	my @rows = $self->schema->resultset('State')->search(
		{}, 
		{
			order_by => { 
				-asc => [qw/character.character_name me.state_name/] 
			}, 
			join => [
				'character']
		}
	)->all;
	
	#return a map for use in the dropdown menu														   
	return [ map { $_->state_id, $_->character->character_name." -- ".$_->state_name} @rows ];

}

__PACKAGE__->meta->make_immutable;
1;