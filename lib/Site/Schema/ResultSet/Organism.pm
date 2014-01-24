package Site::Schema::ResultSet::Organism;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Date::Calc qw(
	Day_of_Year
);

=head1 NAME

Site::Schema::ResultSet::Organism

=cut

sub searchAllOrgansimsAlpha {
	my ($self) = @_;
	
	return $self->search(
		undef,
		{
			order_by => 
			{ 
				-asc => [qw/common_name/] 
			},
		}
	);
}


sub findOrganismInfo{
	my ($self, $name) = @_;
	
	$name =~ s/ /-/g;

	return $self->find(
		{
			"LOWER(replace(me.scientific_name, ' ', '_'))" => {
				'=' => lc($name) 
			},
		},
		{
			prefetch => [
				{
					'organisms_hosts' => {
						'host' => 'hostimages'
					}
				},
			],
		}	
	);
}


sub searchNameLike {
	my ($self, $scientific, $common, $page, $rows ) = @_;

	return $self->search(
		{ 
			'LOWER(me.scientific_name)' => { 
				'like' => "%".lc($scientific)."%" 
			},
			'LOWER(me.common_name)' => { 
				'like' => "%".lc($common)."%" 
			},
		 },	
		 {

			prefetch =>	{
				'organisms_defaultimages'	=> [
					'image',
					'character_type'
				]
			},
		 	rows => $rows || 10,
		 	page => $page || 1,
		 	order_by => { -asc => [qw/me.common_name/] },
		 }						
	);
	
}



sub searchState {
	my ($self, $state_id) = @_;

	return $self->search(
		{
			'organisms_states.state_id' => $state_id,
		},
		{
			select 		=> [
			 	'me.organism_id',
			 	 { 
				 	count => 'me.organism_id', 
				 	-as => 'statecount' 
				 },
		    ],
		    as => [
		    	'organism_id',
		    	'statecount'
		    ],
      		group_by => 'me.organism_id',
			join	=> {
				'organisms_states'
			},
		}
	);
}


sub searchStateRange {
	my ($self, $state_id, $state_value) = @_;
	
	return $self->search(
		{
			'organisms_states.state_id' => $state_id,
			'organisms_states.low_value'  => { 
				'<=', 
				$state_value 
			},
			'organisms_states.high_value'  => { 
				'>=', 
				$state_value 
			},
		},
		{
			select => [
			      'me.organism_id',
		    ],
		    as => [
		    	'organism_id'
		    ],
			'+select'	=> [
				 { 
				 	count => 'me.organism_id', 
				 	-as => 'statecount' 
				 },
			],
      		'+as'     => [
      			'organism_id'
      		],
      		group_by => 'me.organism_id',
			join	=> {
				'organisms_states'
			}
		}
	);
}

sub searchObservationTimes {
	my ($self, $month, $day) = @_;
	
	my $date =  Day_of_Year( 2012, $month, $day );

	return $self->search(
		{
			'character.character_name' => 'Flight Times',
			'organisms_states.low_value'  => { 
				'<=', 
				$date 
			},
			'organisms_states.high_value'  => { 
				'>=', 
				$date 
			},
		},
		{
			select 		=> [
			 	'me.organism_id',
			 	{ 
				 	sum => '1', 
				 	-as => 'flightcount' 
				 },
			 
		    ],
		    as => [
		    	'organism_id',
		    	'flightcount'
		    ],
      		group_by => 'me.organism_id',
			join	=> {
				'organisms_states' => {
					'state' => 'character'
				}
			},
		}
	);
}

sub searchRarityScore {
	my ($self, $name, $scores) = @_;

	my $case = '';
	
	foreach my $key ( keys %{$scores} ) {
     	$case .= "WHEN	lower(state.state_name) = '".$key ."' THEN ".$scores->{$key}." ";
	}
	
	$case =~ s/\\//g;	

	return $self->search(
		{
			'character.character_name' => $name
		},
		{
			select 		=> [
			 	'me.organism_id',
			 	{ 
				 	'' => "CASE ".$case."
						ELSE
							0
						END", 
				 	-as => 'rarityscore' 
				 },
			 
		    ],
		    as => [
		    	'organism_id',
		    	'rarityscore'
		    ],
      		group_by => [
      			'me.organism_id',
      			'state.state_name'
      		],
			join	=> {
				'organisms_states' => {
					'state' => 'character'
				}
			},
		}
	);
}

sub parseAsQuery {
	my ($self, $query ) = @_;
	
	return @{$$query};
}

sub generateQuery {
	my ($self, $query, $table ) = @_;
	
	my $as_query = $query;
	my ($sql, @bind) = @{$$as_query};

	return { 
			"query" => " LEFT JOIN ($sql) $table ON organisms.organism_id = $table.organism_id  ",
			"bind" => [@bind]
	};
	
}


1;