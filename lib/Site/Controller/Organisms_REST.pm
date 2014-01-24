package Site::Controller::Organisms_REST;
use Moose;
use namespace::autoclean;
use Try::Tiny;

 __PACKAGE__->config(
	'default'   => 'application/json',
    'stash_key' => 'data',
    'map'       => {
    	'application/json'	=>	[ 'View', 'JSON', ],
	}
);
 
with 'Site::Action::OrganismSearch';
BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Site::Controller::Organisms_REST - Catalyst REST Controller 

=head1 DESCRIPTION

Catalyst REST Controller 

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('/') :PathPart('organisms/request') :CaptureArgs(0) {
	my ($self, $c) = @_;	
		
}


 sub searchOrganismsByName : Chained('base') PathPart('search/name') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
}
 

sub searchOrganismsByName_POST {
	my ($self, $c) = @_;
	
	$c->stash->{issuccess} = 0;
	$c->stash->{data} = "";
	$c->req->header('Content-Type' => 'application/json');
	my $charactertype = $c->config->{Site}->{characters}->{defaultcharactertype};
	
	my @results;
	
	foreach my $organism ($c->model('DB::Organism')->searchNameLike(
		$c->request->params->{'scientific_name'}, 
  		$c->request->params->{'common_name'}, 
		$c->request->params->{'page'},
		10
	)->all) {
				
		my $item;
		
		my $cacheitem = $c->cache->get('organisms_'.$organism->organism_id.'_'.$charactertype);

		if (defined($cacheitem)) {
				$item = $cacheitem;
		}
		else {
			$item->{'scientific_name'} = $organism->scientific_name;
			$item->{'common_name'} = $organism->common_name;
			$item->{'url'} = $c->uri_for(
				$c->controller('Organisms')->action_for('viewOrganismInfo'),
				$organism->organism_url
			)."";
			$item->{'image_id'} = $organism->default_image->image_id;
			$item->{'image_path'} = $organism->default_image->filename;
			if ($c->config->{Cache}->{enabled}) {
				$c->cache->set( 'organism_'.$organism->organism_id.'_'.$c->config->{Site}->{characters}->{defaultcharactertype}, $item );
			}
		}
		
		push(@results, $item); 

	}
	
	$c->stash->{data} = \@results;	
	
	if ($c->stash->{data}) {
		$c->stash->{issuccess} = 1;
	}
	
}

## simple create action, you decide how you want to present the input UI to the user
 sub searchOrganismsByDescription : Chained('base') PathPart('search/description') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
 
 }
 
 sub searchOrganismsByDescription_POST {
	my ($self, $c) = @_;
	
	$c->stash->{issuccess} = 0;
	$c->stash->{data} = "";
	$c->stash->{observations} = "";
	$c->req->header('Content-Type' => 'application/json');
	my $charactertype = $c->model("DB::Charactertype")->find(
				$c->request->params->{'type'}
	)->character_type;
	my $search = $c->forward('description_search',[
	  		$charactertype,
	 ]);
	 
	 

	my @results;
	
	foreach my $organism ($c->model("DB::View::OrganismDescriptionSearch")->searchQuery(
		$charactertype, 
		$search->{'query'},
		$search->{'bind'},
		10,
		$c->request->params->{'page'}, 
	)->all) {
		
		my $item;
		
		my $cacheitem = $c->cache->get('organisms_'.$organism->organism_id.'_'.$charactertype);

		if (defined($cacheitem)) {
				$item = $cacheitem;
		}
		else {
			$item->{'scientific_name'} = $organism->organism->scientific_name;
			$item->{'common_name'} = $organism->organism->common_name;
			$item->{'url'} = $c->uri_for(
				$c->controller('Organisms')->action_for('viewOrganismInfo'),
				$organism->organism->organism_url
			)."";
			$item->{'image_id'} = $organism->organism->default_image($charactertype)->image_id;
			$item->{'image_path'} = $organism->organism->default_image($charactertype)->filename;
			if ($c->config->{Cache}->{enabled}) { 
				$c->cache->set('organisms_'.$organism->organism_id.'_'.$charactertype, $item);
			}
		}
		
		if (defined $organism->ordercount) {
		
			$item->{'score'} = $organism->ordercount;
			
			if ($item->{'score'} >= 100) {
				$item->{'score'} = '99';
			}
			
			if (!($item->{'score'} > 1)) {
				$item->{'score'} = '1';
			}
		}
	
			
							
		push(@results, $item); 
	}
	
	$c->stash->{data} = \@results;	


	if ($c->stash->{data}) {
		$c->stash->{issuccess} = 1;
		my @observe;
		
	if ($search->{'uselocation'}) {
		foreach my $observation ($c->model("DB::Observation")->searchPointsNearBy(
					$charactertype,
					$c->request->params->{'month'},
					$c->request->params->{'day'},
					$search->{'geo'}->getLatitude(),
					$search->{'geo'}->getLongitude(),
					10,	
			)->all) {
				my $item;
				my $cacheitem = $c->cache->get('organisms_'.$observation->organism->organism_id.'_'.$charactertype);
			
				if (!(defined $observation->images) && defined($cacheitem)) {
					$item->{'image_id'} = $cacheitem->{'image_id'};
					$item->{'filename'}	= $cacheitem->{'image_path'};
					$item->{'common_name'} = $cacheitem->{'common_name'};
				}
				else {
					my $image = $observation->first_image;	
					$item->{'image_id'}	= $image->image_id;
					$item->{'filename'}	= $image->filename;
					$item->{'common_name'} = $observation->organism->common_name;
				}
		
				$item->{'latitude'} = $observation->latitude;
				$item->{'longitude'} = $observation->longitude;
				$item->{'type'} = $observation->observation_type->observation_name;
				$item->{'date_observed'} = $observation->date_observed_display;
				$item->{'location_detail'} = $observation->location_detail;
				$item->{'source'} = $observation->source;
				$item->{'observation_id'} = $observation->observation_id;
				$item->{'url'} = $c->uri_for(
					$c->controller('Organisms')->action_for('viewObservation'),
					$observation->observation_id
				)."";
				if (defined $observation->user_organism) {
					$item->{'observed_by'} = $observation->user_organism->users->get_full_name;
				}
				
				push(@observe, $item); 
				
			}

			$c->stash->{observations} = \@observe;	
		}

	}
	if ($c->request->params->{'observed_location'} ne 'no' && !$search->{'uselocation'}) {
	 	$c->stash->{errormsg}	= 'We did not use your location because it was outside of the given area';
	}
}

## simple create action, you decide how you want to present the input UI to the user
 sub searchOrganismsByLocation : Chained('base') PathPart('search/location') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
}

 sub searchOrganismsByLocation_POST {
	my ($self, $c) = @_;
	
	$c->stash->{issuccess} = 0;
	$c->stash->{data} = "";
	$c->stash->{observations} = "";
	$c->request->params->{'observed_day'} = 1;
	$c->req->header('Content-Type' => 'application/json');
	
	my $charactertype = $c->config->{Site}->{characters}->{defaultcharactertype};
	
	my $geo = $c->forward('geo_code');
	
	if ($geo) {
		my $search = $c->forward('description_search',[
		  		$charactertype,
		 ]);
	
		my @results;
		
		foreach my $organism ($c->model("DB::View::OrganismDescriptionSearch")->searchQuery(
			$charactertype, 
			$search->{'query'},
			$search->{'bind'},
			20,
			1, 
		)->all) {
			
			my $item;
			
			my $cacheitem = $c->cache->get('organisms_'.$organism->organism_id.'_'.$charactertype);

			if (defined($cacheitem)) {
				$item = $cacheitem;
			}
			else {
				$item->{'scientific_name'} = $organism->organism->scientific_name;
				$item->{'common_name'} = $organism->organism->common_name;
				$item->{'url'} = $c->uri_for(
					$c->controller('Organisms')->action_for('viewOrganismInfo'),
					$organism->organism->organism_url
				)."";
	
				$item->{'image_id'} = $organism->organism->default_image->image_id;
				$item->{'image_path'} = $organism->organism->default_image->filename; 
				if ($c->config->{Cache}->{enabled}) {
					$c->cache->set('organisms_'.$organism->organism_id.'_'.$charactertype, $item);
				}
			}	
								
			push(@results, $item); 
		}
		
		$c->stash->{data} = \@results;
		if ($c->stash->{data}) {
			$c->stash->{issuccess} = 1;
		}
		else {
			$c->stash->errormsg	=	"There was an error getting your results";
		}
		
		my @observe;	
		foreach my $observation ($c->model("DB::Observation")->searchPointsNearBy(
			$charactertype,
			$c->request->params->{'month'},
			$c->request->params->{'day'},
			$search->{'geo'}->getLatitude(),
			$search->{'geo'}->getLongitude(),
			25,	
		)->all) {
			my $item;

			my $cacheitem = $c->cache->get('organisms_'.$observation->organism->organism_id.'_'.$charactertype);
			
			if (!(defined $observation->images) && defined($cacheitem)) {
				$item->{'image_id'} = $cacheitem->{'image_id'};
				$item->{'filename'}	= $cacheitem->{'image_path'};
				$item->{'common_name'} = $cacheitem->{'common_name'};
			}
			else {
				my $image = $observation->first_image;	
				$item->{'image_id'}	= $image->image_id;
				$item->{'filename'}	= $image->filename;
				$item->{'common_name'} = $observation->organism->common_name;
			}

			$item->{'latitude'} = $observation->latitude;
			$item->{'longitude'} = $observation->longitude;
			$item->{'type'} = $observation->observation_type->observation_name;
			$item->{'date_observed'} = $observation->date_observed_display;
			$item->{'location_detail'} = $observation->location_detail;
			$item->{'source'} = $observation->source;
			$item->{'observation_id'} = $observation->observation_id;
			$item->{'url'} = $c->uri_for(
				$c->controller('Organisms')->action_for('viewObservation'),
				$observation->observation_id
			)."";
			if (defined $observation->user_organism) {
				$item->{'observed_by'} = $observation->user_organism->users->get_full_name;
			}
					
			push(@observe, $item); 
			
		}
	
		$c->stash->{observations} = \@observe;	
		
	}
	else {
		$c->stash->{errormsg}	= "You are outside of the location area";
	}
}

## simple create action, you decide how you want to present the input UI to the user
sub searchStatesByCharacter : Chained('base') PathPart('search/states') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;

}


sub searchStatesByCharacter_POST  {
	my ($self, $c) = @_;
	
	$c->stash->{data} = "";
	
  	#makes sure the character is numeric (does an id search)
  	if ($c->request->params->{'character'} =~ /^\d+?$/) {
			
				
		#puts state id and value into an array
		foreach ($c->model('DB::State')->getStateByCharacter(
			$c->request->params->{'character'}
		)->all) {
			$c->stash->{states}->{$_->state_id} = $_->state_name;
		}
	
				
		#check whether the character is numeric
		$c->stash->{isnumeric} =  $c->model('DB::Character')->find(
			{
				character_id => $c->request->params->{'character'}
			}
		)->is_numeric;
	}
}

## simple create action, you decide how you want to present the input UI to the user
sub searchSystemsImageByTypes : Chained('base') PathPart('search/images') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;

}


sub searchSystemsImageByTypes_POST  {
	my ($self, $c) = @_;
	
	
	my @images;
	foreach my $image ($c->model("DB::Observationimage")->searchSystemImagesByImageType(
		$c->request->params->{id},
		$c->request->params->{character_type},
		$c->request->params->{image_type},
		10,
		$c->request->params->{page},		
	)->all) {
		my $item;
				
		$item->{'image_id'} = $image->image_id;
		$item->{'filename'} = $image->filename;
		$item->{'info'} = $image->create_info_string;
		
				
		push(@images, $item);
	}
	
	$c->stash->{data} = [@images];
	
  	
}

sub searchExamplesStates :Chained('base') :PathPart('examples') ActionClass('REST') Args(0) {
	my ($self, $c) = @_;
	
}

sub searchExamplesStates_POST {
	my ($self, $c) = @_;
	$c->stash->{data} = "";

	
  	my $images = $c->model('DB::ObservationimagesState')->search(
  		{
  			state_id => $c->request->params->{'state_id'},
  		},
  		{
	 		rows => 10,
	 		page => 1,
	 	}	
	);
			
		my @results;
			
		#puts state id and value into an array
		foreach ($images->all) {
			my $item;
				
			$item->{'image_path'} = $_->image->filename."";
			$item->{'image_id'} = $_->image->image_id."";
			$item->{'common_name'} = $_->image->observation->organism->common_name."";
			$item->{'scientific_name'} = $_->image->observation->organism->scientific_name."";
			$item->{'url'} = $c->uri_for(
				$c->controller('Organisms')->action_for('viewOrganismInfo'),
				$_->image->observation->organism->organism_url
			)."";
			push(@results, $item); 
 		} 

		
		$c->stash->{data} = [@results];
		$c->stash->{issuccess} = 1;

}

sub findOrganismByID  : Chained('base') PathPart('search/byid') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;

}

sub findOrganismByID_POST  {
	my ( $self, $c ) = @_;
	
	my $charactertype = $c->config->{Site}->{characters}->{defaultcharactertype};
	my $organism = $c->model('DB::Organism')->find(
		{
			organism_id	=>	$c->request->params->{'id'}
		}
	);
	
	my $item;
	my $cacheitem = $c->cache->get('organisms_'.$organism->organism_id.'_'.$charactertype);

	if (defined($cacheitem)) {
		$item = $cacheitem;
	}
	else {	
		$item->{'image_id'} = $organism->default_image->image_id;
		$item->{'image_path'} = $organism->default_image->filename;
		$item->{'common_name'} = $organism->common_name."";
		$item->{'scientific_name'} = $organism->scientific_name."";
	}
	
	$c->stash->{data} = [$item];
	$c->stash->{issuccess} = 1;
	
}

=head1 AUTHOR

Harry Shyket 

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
