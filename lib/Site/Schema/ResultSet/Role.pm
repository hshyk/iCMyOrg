package Site::Schema::ResultSet::Role;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

Site::Schema::ResultSet::Role

=cut

=head2 findRoleIDByName

Get the Role ID by Name

=cut

sub findRoleIDByName {
	my ($self, $role) = @_;
	
	return $self->find(
		{
			role => $role
		}
	)->role_id;
}


1;