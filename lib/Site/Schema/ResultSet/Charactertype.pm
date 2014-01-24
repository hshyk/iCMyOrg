package Site::Schema::ResultSet::Charactertype;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

Site::Schema::ResultSet::Charactertype

=cut

=head2 search_display

Return all character type without the All type

=cut

sub searchDisplay {
	my ($self) = @_;

	return $self->search( 
		{
			-not => [ character_type => $self->result_source->schema->systemcharactertype]
		}, 
		{
			order_by => ['character_type']
		}
	);
	
}


1;