package Site::Schema::ResultSet::Observationtype;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';




=head1 NAME

Site::Schema::ResultSet::Observation

=cut



sub searchDisplay {
	my ($self, $latitude, $longitude) = @_;
	
	return $self->search(
		{
			   'observation_name' =>	{  -not_in => $self->result_source->schema->systemobservation},
		}
	)
}





1;