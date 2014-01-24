package Site::Schema::ResultSet::Authprovider;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

Site::Schema::ResultSet::UsersOauth

=cut

=head2 findProviderIDByName

Get the provider_id by name

=cut

sub findProviderIDByName {
	my ($self, $provider) = @_;

	return $self->find(
		{
			provider_name => $provider
		}
	)->provider_id
}


1;