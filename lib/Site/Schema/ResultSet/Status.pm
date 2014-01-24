package Site::Schema::ResultSet::Status;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

Site::Schema::ResultSet::UsersOauth

=cut

=head2 by_name

Find status_id by name

=cut

sub findStatusIDByName {
	my ($self, $status) = @_;
	
	return $self->find(
		{
			status_name => $status
		}
	)->status_id;
}


1;