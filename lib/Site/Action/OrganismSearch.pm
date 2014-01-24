package Site::Action::OrganismSearch;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;
use List::Flatten;
use Try::Tiny;

=head1 NAME

Site::Controller::Action::OrganismSearch

=head1 DESCRIPTION

Action - Organism Search

=head1 METHODS

=cut

=head2 check_specific_character_use
 
Check to see whether the specific character should be used from the config.

=cut 

sub check_specific_character_use	:Private {
	my ($self, $c, $charactername, $charactertype) = @_;

	if ($c->config->{Site}->{characters}->{specific}->{$charactername}->{enabled}) {
    	foreach my $key (keys $c->config->{Site}->{characters}->{specific}->{$charactername}->{types}) {
			if (lc($key) eq 'all' || lc($key) eq lc($charactertype)) {
				return 1;
			}
		}
	}
	else{
		return 0;
	}
	return 0;
	
}

=head2 geo_code
 
Method used to figure out a user's location

=cut 
sub geo_code	:Private {
	my ($self, $c) = @_;
	
	my $geo;
	my $lookup;
	# The user's location should be gathered from the IP address
	if ($c->request->params->{'observed_location'} eq 'ip') {
	 	$geo = $c->model('Geo::IP');
	 	$lookup = $c->request->address;
	 	$c->stash->{location_used}	= "IP";
	}
	# The user's location should be sent with an address (either coordinates or a string of text)
	else {
		$geo = $c->model('Geo::Coder');
		$lookup = $c->request->params->{'address'};
		$c->stash->{location_used}	= "Coder";
	}
	
	try {		
		# Get the location
		$geo->geocodeLocation($lookup);
		
		# This checks whether the search needs to be restricted to a given area
		if ($c->config->{Site}->{characters}->{search}->{in_area}->{check}) {
			if ($geo->checkInArea(
				$c->config->{Site}->{characters}->{search}->{in_area}->{type},
				$c->config->{Site}->{characters}->{search}->{in_area}->{area})
			) {
					return $geo
				}
				else {
					return 0;
				}
			}
		
		return $geo;
	}
	catch {
		return 0;
	}
	
}

=head2 description_search
 
Return results using a description.  It creates a dynamic query based on the parameters passed into it.

=cut 
sub description_search	:Private {
	my ($self, $c, $charactertype) = @_;
  	
  	my $select = "";
	my $query = "";
	my $qobj;
	my @bind;
	my $geo;
	my $points = 0;
	my $uselocation = 0;
	  	
	#loop through each character passed in
	for (my $x = 1; defined $c->request->params->{'characters'.$x}; $x++) {
		
		# Checks whether a numeric value is passed through
		if (defined $c->request->params->{'statevalue'.$x}) {
			
			if (!($c->request->params->{'statevalue'.$x} > 0)) {
				$c->request->params->{'statevalue'.$x} = 0;
			}
			
			# If a value needs to be converted from inches to centimeters
			if ($c->request->params->{'states'.$x} =~ m/inches/) {
				$c->request->params->{'states'.$x} =~ s/inches//g;
				$c->request->params->{'statevalue'.$x} = $c->model('DB::State')->convert_inches_to_cm(
					$c->request->params->{'statevalue'.$x}
				);
			}
			
			# Generate a query for a range search
			$qobj = $c->model("DB::Organism")->generateQuery(
				$c->model("DB::Organism")->searchStateRange(
					$c->request->params->{'states'.$x},
					$c->request->params->{'statevalue'.$x}
				)->as_query,
				'states'.$x,
			);
			
			$query .= $qobj->{'query'};
			@bind = (@bind, $qobj->{'bind'});
		}
		else {	
			# Do a regular search to see if the character exists		
			$qobj = $c->model("DB::Organism")->generateQuery(
				$c->model("DB::Organism")->searchState(
					$c->request->params->{'states'.$x},
				)->as_query,
				'states'.$x,
			);

			$query .= $qobj->{'query'};
			@bind = (@bind, $qobj->{'bind'});
		}
		
		$select .= " + (coalesce(states".$x.".statecount,0) * ".$c->config->{Site}->{characters}->{search}->{percent}->{states}.") ";
	}
	
	# Check to see if habitat is a specific character that needs to have a different weight
	if ($c->forward('check_specific_character_use', [
		'habitat',
		$charactertype
	]) && $c->request->params->{'habitat_id'} gt 0) {
		
		$qobj = $c->model("DB::Organism")->generateQuery(
			$c->model("DB::Organism")->searchState(
				$c->request->params->{'habitat_id'},
			)->as_query,
			'habitat',
		);
		$query .= $qobj->{'query'};
		@bind = (@bind, $qobj->{'bind'});
			
		$select .= " + (coalesce(habitat.statecount,0) * ".$c->config->{Site}->{characters}->{search}->{percent}->{habitat}.") ";
		
	}
	
	# Check to see if the time range is a specific character that needs to have a different weight	
	if ($c->forward('check_specific_character_use', [
		'day_of_year',
		$charactertype
	]) && $c->request->params->{'observed_day'} eq "1" && $c->request->params->{'day'} gt 0 && $c->request->params->{'month'} gt 0 ) {
				
		$qobj = $c->model("DB::Organism")->generateQuery(
			$c->model("DB::Organism")->searchObservationTimes(
				$c->request->params->{'month'},
				$c->request->params->{'day'}
			)->as_query,
			'searchrange',
		);
			
		$query .= $qobj->{'query'};
		@bind = (@bind, $qobj->{'bind'});
			
		$select .= " + (coalesce(searchrange.flightcount, 0) * ".$c->config->{Site}->{characters}->{search}->{percent}->{day_range}.") ";
			
	}
		
	# Check to see whether a location is provided
	if ($c->request->params->{'observed_location'} ne 'no' ) { 
			
		$uselocation = 1;
		# Geocode a location	
		$geo = $c->forward('geo_code');
				
		if ($geo) {
			
			
			$qobj = $c->model("DB::Organism")->generateQuery(
				$c->model("DB::Observation")->searchObservationLocation(
					$c->request->params->{'month'},
					$c->request->params->{'day'},
					$geo->getLatitude(),
					$geo->getLongitude()
				)->as_query,
				'searchlocation',
			);
			$query .= $qobj->{'query'};
			@bind = (@bind, $qobj->{'bind'});
			
			$select .= " + (coalesce((round((searchlocation.locationcount * searchlocation.numberofpoints/5544::decimal)) * 10),0) * ".$c->config->{Site}->{characters}->{search}->{percent}->{observation_points}.") ";
			
			$qobj = $c->model("DB::Organism")->generateQuery(
				$c->model("DB::Observation")->searchOrganismObservations(
					$c->request->params->{'month'},
					$c->request->params->{'day'},
					$geo->getLatitude(),
						$geo->getLongitude()
					)->as_query,
					'searchobservations',
			);
			$query .= $qobj->{'query'};
			@bind = (@bind, $qobj->{'bind'});
				
			$select .= " + (coalesce((searchobservations.observationcount)/10,0) * ".$c->config->{Site}->{characters}->{search}->{percent}->{observation_location}.") ";		
		}
		else {
			$uselocation = 0;
			$c->stash->{location_error}	= 'We could not use the address provided.  It is either invalid or outside of '.$c->config->{Site}->{characters}->{search}->{in_area}->{fullname};
		}
	}
	
	# Check to see if the rarity is a specific character that needs to have a different weight		
	if ($c->forward('check_specific_character_use', [
		'rarity',
		$charactertype
	])) {
		$qobj = $c->model("DB::Organism")->generateQuery(
			$c->model("DB::Organism")->searchRarityScore(
				$c->config->{Site}->{characters}->{specific}->{rarity}->{character_name},
				$c->config->{Site}->{characters}->{specific}->{rarity}->{order}
			)->as_query,
			'searchrarirty',
		);

		$query .= $qobj->{'query'};
		@bind = (@bind, $qobj->{'bind'});
				
		$select .= " + (coalesce(searchrarirty.rarityscore,0) * ".$c->config->{Site}->{characters}->{search}->{percent}->{rarity}.") ";
	}

	$query = "SELECT organisms.organism_id, (0 ".$select.") AS ordercount FROM organisms organisms".$query;

	@bind = flat @bind;
	
	return {'query' =>$query, 'uselocation'	=> $uselocation, 'geo'	=> $geo, 'bind' => \@bind}

}

1;