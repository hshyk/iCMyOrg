package Site::Form::Admin::Character;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
 
=head1 NAME

Site::Form::Admin::Character - HTML Formhandler Class

=head1 DESCRIPTION

Add a character

=head1 METHODS

=cut

has '+item_class' => ( default =>'Character' );
has_field 'character_type_id' => (type => 'Select',label => 'Character Type', required => 1);
has_field 'character_name' => (type => 'Text',label => 'Character Name', minlength => 1, maxlength => 60, required => 1, size => 60);
has_field 'is_numeric'  => (type => 'Checkbox', label => 'Is Numeric' );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );


sub options_character_type_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the characters and sort them by their name
	my @rows = $self->schema->resultset('Charactertype')->search( 
		{
			character_type => {
       			'NOT IN' => $self->schema->systemcharactertype
   			},
		}, 
		{
			order_by => ['character_type']
		}
	)->all;
	
	#return a map for use in the dropdown menu
	return [ map { $_->character_type_id, $_->character_type } @rows ];

}


__PACKAGE__->meta->make_immutable;
1;