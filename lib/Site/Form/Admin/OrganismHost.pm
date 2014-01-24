package Site::Form::Admin::OrganismHost;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::OrganismHost - HTML Formhandler Class

=head1 DESCRIPTION

Add a host to an organism

=head1 METHODS

=cut

has '+item_class' => ( default =>'OrganismsHost' );
has_field 'organism_id' => (type => 'Select',label => 'Organism', required => 1);
has_field 'host_id'  => (type => 'Select', label => 'Host', required => 1 );
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
	
	#find all the organism and sort them by their name
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

sub options_host_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#grab all of the state values and grab the character value of it
	#sort the states by their name
	my @rows = $self->schema->resultset('Host')->search(
		{}, 
		{
			order_by => { -asc => [qw/scientific_name/] }
		}, 
	)->all;
	
	#return a map for use in the dropdown menu														   
	return [ map { $_->host_id, $_->scientific_name." -- ".$_->common_name} @rows ];

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
		 					!($self->item->{_column_data}->{host_id} > 0)
		 				);
	}
	
	#check to see if the organism state is already added 
	my $organism = $self->schema->resultset('OrganismsHost')->search( 
		{
			organism_id => $self->field('organism_id')->value,
	 		host_id => $self->field('host_id')->value
		}
	 )->count;

	 return unless $organism > 0;
	
	 $self->field('organism_id')->add_error(
		'This Organism\'s Host has already been added'
	 );
	 
}

__PACKAGE__->meta->make_immutable;
1;