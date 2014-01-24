package Site::Schema::ResultSet::UsersOrganism;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';


sub findUserOrganismWithPublishedObservations {
	my ($self,  $user_id, $organism_id) = @_;
	return $self->find(
		{
			user_id => $user_id, 
			organism_id	=> $organism_id,			
		},
	)
}

sub searchLifeListOrganismsWithPublishedObservations {
	my ($self,  $user_id) = @_;
	
	return $self->search(
		{
			'users.user_id'				=>	$user_id,
			'observestatus.status_name'	=>	$self->result_source->schema->observationstatus->{published},
		},
		{
			prefetch	=> {
				'organism' => {
					'organisms_defaultimages'	=> [
						'image',
						'character_type'
					]
				},
				
			},
			join	=>	{
				'observations' => 'observestatus',
				'users'
			},
			order_by	=>	[
				'organism.common_name'
			]
		}
	)
}

sub  searchLifeListOrganismsWithAllObservations {
	my ($self,  $user_id) = @_;
	
	return $self->search(
		{
			'me.user_id'	=>	$user_id
		},
		{
			prefetch	=> {
				'organism' => {
					'organisms_defaultimages'	=> [
						'image',
						'character_type'
					]
				},
				
			},
			join	=>	{
				'observations' => 'observestatus',
				'users'
			},
			order_by	=>	[
				'organism.common_name'
			]
		}
	)
}

sub searchOrganismWithActiveUserObservations {
	my ($self,  $organism_id) = @_;
	
	return $self->search(
		{
			'me.organism_id'			=>	$organism_id,
			'observestatus.status_name'	=>	$self->result_source->schema->observationstatus->{published},
		},
		{
			prefetch	=>	{
				'users'	=> 'provider'
			},
			join		=>	{
				'observations' => 'observestatus',
			},
			order_by	=>	[
				'users.username'
			],
			+select	=>	'DISTINCT me.user_id',
			+as		=>	'duser_id'
		}
	
	);
		
}



1;