package Site::Schema::ResultSet::Observationimage;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';



sub searchSystemImagesByImageType {
	my ($self, $organism_id, $charactertype, $type, $rows, $page) = @_;
	
	return $self->search(
		{
			'observation.organism_id'			=>	$organism_id,
			'observation_type.observation_name'	=>	$self->result_source->schema->systemobservation,
			'image_type.image_type_name'		=> 	$type,
			'character_type.character_type'		=>	$charactertype,			
		},
		{
			prefetch	=> [
				{	
					'observation' => 'observation_type'
				},
				'character_type',
				'image_type',
				'description',
				'gender' 
			],
			rows	=> $rows || undef,
			page	=> $page || undef
		}
	);
}

sub searchSearchSystemImages {
	my ($self, $organism_id, $charactertype, $rows, $page) = @_;
	
	return $self->search(
		{
			'observation.organism_id'			=>	$organism_id,
			'observation_type.observation_name'	=>	$self->result_source->schema->systemobservation,
			'character_type.character_type'		=>	$charactertype,			
		},
		{
			prefetch	=> [
				{	
					'observation' => 'observation_type'
				},
				'character_type',
				'image_type',
				'description',
				'gender' 
			],
			rows	=> $rows || undef,
			page	=> $page || undef
		}
	);
}

1;