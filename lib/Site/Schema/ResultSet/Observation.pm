package Site::Schema::ResultSet::Observation;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Try::Tiny;
use Date::Calc qw(
	Day_of_Year
);



=head1 NAME

Site::Schema::ResultSet::Observation

=cut



sub createPoint {
	my ($self, $latitude, $longitude) = @_;
	
	return 'POINT('.$longitude.' '.$latitude.')';
}

sub createDayOfYearRange {
	my ($self, $month, $day) = @_;
	
	my $start;
	my $end;
	try {
		my $date =$self->createDayOfYear($month, $day);
		$start = $date+30;
		$end = $date-30;
	}
	catch {
		$start = 366;
		$end = 0;
	};
		
	return $start,$end;
}

sub createDayOfYear {
	my ($self, $month, $day) = @_;
	
	return Day_of_Year( 2012, $month, $day );
}

sub searchLatestSightings {
	my ($self) = @_;
	
	return $self->search(
		{	
			'me.user_organism_id' => 
				{ 
					'!=', 
					undef 
			
				},
			'observestatus.status_name' => $self->result_source->schema->observationstatus->{published},
			'status.status_name' => $self->result_source->schema->roles->{user_active}
		},
		{
			join => {
				'user_organism' => {
						'users' => 'status',		
				},
				'observestatus'
			},
			prefetch => [
				{
					'user_organism' => 
					{
						'users' => 'provider'		
					},
				},
				'observation_type',
				'observationimages',
				'organism'
			],
			order_by => 
				{ 
					-desc => [qw/date_observed/] 
				},
      		rows => 10,
		}
	);
}



sub searchActiveOrganismPointsAroundDate {
	my ($self, $month, $day, $rows) = @_;
	
	return $self->search(
		{
			'observation_type.observation_name' =>  
	  			{
	        		-not_in => $self->result_source->schema->systemobservation,
	    		},
	    	'observestatus.status_name' => $self->result_source->schema->observationstatus->{published},    	
			-or => [
	    		'me.user_organism_id' => undef,
	    		'status.status_name' => $self->result_source->schema->roles->{user_active}
			]
		},
		{
			join	=> [
				'images',
				'organism',
				{
					'user_organism' => {
						'users'	=> 'status'
					} 
				},
				'user_organism',
				'observation_type',
				'observestatus'
			],
			prefetch	=> [
				'images',
				'organism',
				'observation_type'
			],
			'+select' => [
				 '(@ (to_char(me.date_observed, \'DDD\')::integer) - '.$self->createDayOfYear($month, $day).') AS daysaway'				
			],
	      	'+as'     => [
	      		'daysaway'
	      	
	      	],
	      	order_by => \'daysaway ASC NULLS LAST',  
	      	rows => $rows,
		}
	);
}

sub searchActiveOrganismPoints {
	my ($self, $month, $day, $rows) = @_;
	
	return $self->search(
		{
			'observation_type.observation_name' =>  
	  			{
	        		-not_in => $self->result_source->schema->systemobservation,
	    		},
	    	'observestatus.status_name' => $self->result_source->schema->observationstatus->{published},    	
			-or => [
	    		'me.user_organism_id' => undef,
	    		'status.status_name' => $self->result_source->schema->roles->{user_active}
			]
		},
		{
			join	=> [
				'images',
				'organism',
				{
					'user_organism' => {
						'users'	=> 'status'
					} 
				},
				'user_organism',
				'observation_type',
				'observestatus'
			],
			prefetch	=> [
				'images',
				'organism',
				'observation_type'
			],
		}
	);
}

sub searchPointsNearBy {
	my ($self, $charactertype, $month, $day, $latitude, $longitude, $rows ) = @_;
	
	my ($start, $end)  = $self->createDayOfYearRange($month, $day);
	
	return $self->search(
		{
			-and => [ \[ 'ST_Distance(
						ST_transform(
							ST_PointFromText(
								?,
								4269
							),
							32661
						),
						geom
					) < 16093', [ plain_value => $self->createPoint($latitude, $longitude), ] ],
					'observestatus.status_name' => $self->result_source->schema->observationstatus->{published},
					'observation_type.observation_name' => { 
							'!=' => $self->result_source->schema->systemobservation,
					},
				-or	=> [
					'status.status_name'	=> undef,
					'status.status_name'	=> $self->result_source->schema->roles->{user_active}
					],
				]
		},
		{
			'select' => [
				'DISTINCT ON (coordinates) me.observation_id',
				'me.observation_id',
				{
					''	=> 'me.latitude::text ||  me.longitude::text',
					-as	=>	'coordinates'
				},
				{
					''	=> \[ '(to_char(me.date_observed, \'DDD\')::integer <= ?)::integer + (to_char(me.date_observed, \'DDD\')::integer <= ?)::integer', [ plain_value => $start  ], [ plain_value =>  $end  ] ],
					-as	=>	'daterange'
				},
				'me.organism_id',
				'user_organism_id',
				'observation_type_id',
				'latitude',
				'longitude',
				'date_observed',
				'location_detail',
				'source',
			],
			'as'	=> [
				'observe_id',
				'observation_id',
				'coordinates',
				'daterange',
				'organism_id',
				'user_organism_id',
				'observation_type_id',
				'latitude',
				'longitude',
				'date_observed',
				'location_detail',
				'source',
			],
			join	=> [
				'images',
				#{'organism' => 'character_image'},
				{
					'user_organism' => {
						'users'	=> 'status'
					} 
				},
				'observestatus'
				
				
			],
			prefetch	=>	[
				'images',
				'observation_type',
				'organism'
			],
      		order_by => [
	      		"coordinates",
	      		"daterange",
			],
      		rows	=> $rows || 10
		}
	);

}


sub searchOrganismObservations {
	my ($self, $month, $day, $latitude, $longitude ) = @_;
	
	my ($start, $end)  = $self->createDayOfYearRange($month, $day);
	
	return $self->search(
		{
			-and => [
				'me.organism_id' => {
						'!=' => undef
				},
				'me.latitude' => {
						'!=' => undef
				},
				'me.longitude' => {
						'!=' => undef
				},
				'ST_Distance(
					ST_transform(
						ST_PointFromText(
							?,
							4269
						),
						32661
					),
					geom
				)' =>  {'<' => 16093},
				'observation_type.observation_name' => { 
					'!=' => $self->result_source->schema->systemobservation
				},
				'to_char(me.date_observed, \'DDD\')::integer' => { 
					'<=' => $start 
				},
				'to_char(me.date_observed, \'DDD\')::integer' => { 
					'>=' => $end 
				},
			]
		},
		{
			select 	=> [
			 	'me.organism_id',
			 	{
			 		count => '*', 
				 	-as => 'observationcount' 
			 	},
		    ],
		    as => [
		    	'organism_id',
		    	'observationcount'
		    ],
      		group_by => 'me.organism_id',
      		bind => [
      			$self->createPoint($latitude, $longitude)
      		],
      		join => [ 
      			'observation_type'
      		]
		}
	);
}

sub searchObservationLocation {
	my ($self, $month, $day, $latitude, $longitude) = @_;

	return $self->searchPolygonObservation($month, $day, $latitude, $longitude)->as_subselect_rs->search_related(
		'organism',
		{
			'me.isinpolygon' => 1
		},
		{
			select 	=> [
			 	{
			 		'' => 'me.polygonarea', 
				 	-as => 'locationcount' 
			 	},
			 	'me.organism_id',
			 	'me.numberofpoints'
			 ],
			as => [
		    	'locationcount',
		    	'organism_id',
		    	'numberofpoints'
		    ],
		}
	);

}



sub searchPolygonObservation {
	my ($self, $month, $day, $latitude, $longitude) = @_;
	
	return $self->searchPolygonTable($month, $day)->as_subselect_rs->search(
		{},
		{
			select 	=> [
			 	'me.numberofpoints',
			 	'me.organism_id',
			 	 {
				 	'' => "ST_Area(
							st_GeomFromText(
								me.polygonobserve,
								4269
							)
						)::integer",	
				 	-as => 'polygonarea'
				 },
				  {
				 	'' => "ST_Contains(
							st_GeomFromText(
								polygonobserve,
								4269
							),
							st_PointFromText(
								?,
								4269
							)	
						)::integer",	
				 	-as => 'isinpolygon'
				 },
				 
			 	
		    ],
		    as => [
		    	'numberofpoints',
		    	'organism_id',
		    	'polygonobserve',
		    	'isinpolygon'
		    ],
		    bind => [
		    	$self->createPoint($latitude, $longitude)
		    ],
		}
	)
}

sub searchPolygonTable {
	my ($self, $month, $day) = @_;
	
	return $self->searchNumberOfPoints($month, $day)->as_subselect_rs->search(
		{},
		{
			select 	=> [
			 	'me.numberofpoints',
			 	'me.organism_id',
			 	 {
				 	replace => "'POLYGON((' || regexp_replace(me.polygontext, '[{}(\")]','','g') || ',' || regexp_replace(regexp_matches(me.polygontext,'". $self->result_source->schema->locationregex."')::text,'[{}(\\\\\")]','','g') || '))',E'\\\\',''",	
				 	-as => 'polygonobserve'
				 },
			 	
		    ],
		    as => [
		    	'numberofpoints',
		    	'organism_id',
		    	'polygonobserve'
		    ],
		}
	);
}

sub searchNumberOfPoints {
	my ($self, $month, $day) = @_;

	return $self->search(
		{
			'observation_type.observation_name' => { '!=' => $self->result_source->schema->systemobservation },
			'me.latitude' => {
					'!=' => undef
			},
			'me.longitude' => {
					'!=' => undef
			},
			'me.organism_id' => { -in =>  $self->searchObservationsForPolygon($month, $day)->get_column('organism_id')->as_query  },
		},
		{
			select 	=> [
			 	'me.organism_id',
			 	 { 
				 	count => '*', 
				 	-as => 'numberofpoints' 
				 },
				 {
				 	'' => 'array_agg((me.longitude || \' \'::text) || me.latitude)::text',	
				 	-as => 'polygontext'
				 },
		    ],
		    as => [
		    	'organism_id',
		    	'numberofpoints',
		    	'polygontext'
		    ],
      		group_by => 'me.organism_id',
      		join	=> [
      			'observation_type'
      		]
		}
	);

}

sub searchObservationsForPolygon {
	my ($self, $month, $day) = @_;
	
	my ($start, $end)  = $self->createDayOfYearRange($month, $day);

	return $self->search(
		{
			-and => [
				'me.organism_id' => {
					'!=' => undef
				},
				'to_char(me.date_observed, \'DDD\')::integer' => { '<=' => $start },
				'to_char(me.date_observed, \'DDD\')::integer' => { '>=' => $end },
			]  
		},
		{
			select 	=> [
			 	'me.organism_id',
		    ],
		    as => [
		    	'organism_id',
		    ],
      		group_by => 'me.organism_id',
      		having => { 
      			'COUNT(*)' => { 
      				'>', 5 
      			} 
      		},
		}
	);
}

sub searchSystemObservationImagesSpecific {
	my ($self, $type, $rows, $page) = @_;
	
	return $self->find(
		{ 
			'observation_type.observation_name' =>  'System',
			
		},
		{
			prefetch => [
				'observation_type',	
			],
		}
	)->observationimages->search(
		{
			'character_type.character_type' => $type, 
		},
		{
			prefetch => [
				'character_type',
				'image_type'
			],
			rows => $rows || 10,
        	page => $page || 1,
		}
	);
}

sub searchAllUserObservations {
	my ($self, $user_id, $rows, $page) = @_;
	
	return $self->search(
		{
			'user_organism.user_id' => $user_id
		},
		{
			prefetch	=> 	[
				'user_organism',
				'observationimages',
				'observation_type',
				{	
					'organism'	=> {
						'organisms_defaultimages' => 'character_type'
					}
				},
			],
			order_by	=>	{
				-desc	=>	'me.date_observed'	
			},
			rows		=>	$rows || undef,
			page		=>	$page || undef
		}
	)
}

sub findValidObservationByID {
	my ($self, $observation_id) = @_;

	return $self->search( 
		{
			
			'observation_type.observation_name' =>  
  				{
        			-not_in => $self->result_source->schema->systemobservation,
    			},
    		'me.observation_id' =>  $observation_id,
    		'status.status_name' => $self->result_source->schema->observationstatus->{published},
   		},
		{
			prefetch => [
				'observation_type',
				'status'
			],
			
		}
	)->first;
}

sub searchLatestUserObservation {
	my ($self, $user_id) = @_;
	
	return $self->search(
		{
			'user_organism.user_id' => $user_id
		},
		{
			prefetch => 'user_organism',
			order_by => 
				{ 
					-desc => 'me.observation_id'
				},		
		}
	)->first;
}

sub searchPublished {
	my ($self) = @_;
	
	return $self->search(
		{ 
			'observestatus.status_name' => $self->result_source->schema->observationstatus->{published},
		},
		{
			prefetch => [
				'observationimages',
				'observestatus'
			]
		}
	);
}

sub findSystemObservation {
	my ($self,$organism_id) = @_;
	
	return $self->find(
		{ 
			'me.organism_id'	=>	$organism_id,
			'observation_type.observation_name' =>  $self->result_source->schema->systemobservation,,
		},
		{
			join => [
				'observation_type',
			],
		}
	);
}

sub searchPreviouslyAddedObservations {
	my ($self,$user_id) = @_;
	
	return $self->search(
		{ 
			'user_organism.user_id'	=>	$user_id,
		},
		{
			join => [
				'user_organism',
			],
			order_by => 
				{ 
					-desc => [qw/me.date_observed/] 
				},
		}
	);
}

sub searchPendingForReviewObservations {
	my ($self) = @_;
	
	return $self->search(
		{
			'observestatus.status_name'	=>	$self->result_source->schema->observationstatus->{review}
		},
		{
			order_by	=>	'me.date_added',
			join		=>	'observestatus',
		}
	);
	
}

sub searchAllNonSystemObservationsByOrganism {
	my ($self, $organism_id) = @_;
	
	return $self->search(
			{
				organism_id	=>	$organism_id,
				'observation_type.observation_name' => { '!=' => $self->result_source->schema->systemobservation }
				
			},
			{
				join	=>	['observation_type']
			}
	);	
}




1;