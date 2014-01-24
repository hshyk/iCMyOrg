package Site::Schema::ResultSet::Character;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

Site::Schema::ResultSet::Character

=cut

=head2 findProviderIDByName



=cut


sub searchAllCharactersOrderByName {
	my ($self) = @_;
	
	return $self->search(	
		{}, 
		{
			order_by => [qw/
				character_type_id 
				character_name
			/]
		}
	);
}


1;