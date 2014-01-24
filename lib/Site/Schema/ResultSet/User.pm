package Site::Schema::ResultSet::User;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub searchActiveUsers {
	my ($self) = @_;
	
	return $self->search(
		{
			'status.status_name'	=>	$self->result_source->schema->roles->{user_active}
		},
		{
			join	=>	[
				'status'
			]
		}
	)
}

sub findUserByAuthIDandProvider {
	my ($self,  $provider_name, $authid) = @_;
	
	return $self->find(
		{
			'authid'							=>	$authid,
			'LOWER(provider.provider_name)'	=>	lc($provider_name)
		},
		{
			join	=>	[
				'provider'
			]
		}
	);
	
}




1;