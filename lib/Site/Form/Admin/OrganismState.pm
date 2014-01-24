package Site::Form::Admin::OrganismState;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::OrganismState - HTML Formhandler Class

=head1 DESCRIPTION

Add a state to a organism

=head1 METHODS

=cut

has '+item_class' => ( default =>'OrganismsState' );
has_field 'organism_id' => (type => 'Select',label => 'Organism', required => 1);
has_field 'state_id'  => (type => 'Select', label => 'State', required => 1 );
has_field 'low_value'  => (type => 'Text', label => 'Low Value', numeric => 1 );
has_field 'high_value'  => (type => 'Text', label => 'High Value' );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );
has '+dependency' => ( default => sub { [
     ['organism_id', 'state_id'],] }
  );


=head2 options_organism_id

Set the options of the organism dropdown

=cut

sub options_organism_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the organisms and sort them by their name
	my @rows = $self->schema->resultset('Organism')->search( 
																{}, 
																{order_by => ['scientific_name']}
															)->all;
	
	#return a map for use in the dropdown menu
	return [ map { $_->organism_id, $_->scientific_name } @rows ];

}

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
															{order_by => { -asc => [qw/character.character_name me.state_name/] }, 
															 join => ['character']}
														 )->all;
	
	#return a map for use in the dropdown menu														   
	return [ map { $_->state_id, $_->character->character_name." -- ".$_->state_name} @rows ];

}

=head2 validate

Extra validation to see if the organism state already exists

=cut
sub validate {
	 my ($self) = shift; 
	
	#check to make sure the organism id and state id are passed
	if (defined($self->item->{_column_data})) {
		
		return unless (
		 					!($self->item->{_column_data}->{organism_id} > 0) && 
		 					!($self->item->{_column_data}->{state_id} > 0)
		 				);
	}
	
	#check to see if the organism state is already added 
	my $organism = $self->schema->resultset('OrganismsState')->search( 
	 																		{organism_id => $self->field('organism_id')->value,
	 																	  		state_id => $self->field('state_id')->value}
	 																	  )->count;

	 return unless $organism > 0;
	
	 $self->field('organism_id')->add_error(
	 											'This Organism State has already been added'
	 										 );
	 
}

__PACKAGE__->meta->make_immutable;
1;