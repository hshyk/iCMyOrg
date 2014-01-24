package Site::Controller::Organisms;
use Moose;
use namespace::autoclean;
use feature qw(switch);
use Try::Tiny;

use Site::Form::Organisms::SearchOrganismsByName;
use Site::Form::Organisms::SearchOrganismsByDescription;
use Site::Form::Organisms::SearchOrganismsByLocation;
use Site::Form::Organisms::SearchImagesStates;


with 'Site::Action::OrganismSearch';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::Organisms - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller - Organism search

=head1 METHODS

=cut

=head2 base

The base method for all of the organism pages
All others methods are chained of this base

=cut
sub base :Chained('/') :PathPart('organisms') :CaptureArgs(0) {
	my ($self, $c) = @_;	
		
}


=head2 index

The index page

=cut
sub index :Path :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template	=>	'organisms/index.tt',
		cache		=>	1
	);

}

=head2 searchOrganismsByName

Find organisms by scientific or common name

=cut
sub searchOrganismsByName :Chained('base') :PathPart('search/name') :Args(0) :Sitemap {
	my ($self, $c) = @_;
	
	$c->stash(
		template	=>	'organisms/searchorganismsbyname.tt', 
		form		=>	Site::Form::Organisms::SearchOrganismsByName->new(),
		cache		=>	1
	);
}


=head2 searchOrganismsByLocation

Find organisms based on location

=cut
sub searchOrganismsByLocation :Chained('base') :PathPart('search/location') :Args(0) :Sitemap {
	my ($self, $c) = @_;
	
	my $active = [];
	
	# Check to see if a date search is enabled
	if ($c->forward('check_specific_character_use', [
		'day_of_year',
		$c->config->{Site}->{characters}->{defaultcharactertype}
	])) {
		push ($active, 'day');
		push ($active, 'month');
	}	
	
	$c->stash(
		template	=> 'organisms/searchorganismsbylocation.tt', 
		form		=> Site::Form::Organisms::SearchOrganismsByLocation->new(
			active	=>	$active
		),
		cache		=>	1
	);
		
}



=head2 searchOrganismsByDescription

Find organisms based on parameters passed in the description

=cut
sub searchOrganismsByDescription :Chained('base') :PathPart('search/description') :Args(0) :Sitemap {
	my ($self, $c) = @_;

	my $active = [];
	 
	# Check to see if habitat and date should be used 
	$c->stash->{usehabitat} = $c->forward('check_specific_character_use', [
		'habitat',
		$c->config->{Site}->{characters}->{defaultcharactertype}
	]);
	$c->stash->{usedate} = $c->forward('check_specific_character_use', [
		'day_of_year',
		$c->config->{Site}->{characters}->{defaultcharactertype}
	]);

	$c->stash(
		template		=>	'organisms/searchorganismsbydescription.tt',  
		form			=>	Site::Form::Organisms::SearchOrganismsByDescription->new(
			schema	=>	$c->model('DB')->schema,
		),
		# Pass the characters to the form  
		characteristics	=>	[
			$c->model('DB::Character')->searchAllCharactersOrderByName()
		],
		cache			=>	1
	);
	
}

=head2 viewExampleStates

View images of states

=cut
sub viewExampleState :Chained('base') :PathPart('examples') :Args(0) :Sitemap {
	my ($self, $c) = @_;
	
  	$c->stash(
  		form		=>	Site::Form::Organisms::SearchImagesStates->new(
			schema	=>	$c->model('DB')->schema
		),
		template	=>	'organisms/examples.tt',
		characteristics	=> [
			$c->model('DB::Character')->search(	
				{
					is_numeric	=>	0
				}, 
				{
					order_by	=> [qw/character_type_id character_name/]
				}
			)
		],
		cache		=>	1
 	);
}

=head2 viewOrganismInfo

View all of the organism's information

=cut
sub viewOrganismInfo :Chained('base') :PathPart('name')  :Args(1) :Sitemap(*) {
	my ($self, $c, $organism_name) = @_;
	
	#get the organism based on the name passed in the URL
	my $organism = $c->model('DB::Organism')->findOrganismInfo(
		$organism_name
	);
	
	my $imagetype = $c->model("DB::Observationimagetype")->search();
	
	# This grabs the system images for an organism
	foreach my $charactertype (keys $c->config->{Site}->{organisminfo}->{charactertypes}){
		foreach my $type (keys $c->config->{Site}->{organisminfo}->{imagetypes}) {
			$c->stash->{images}->{$charactertype}->{$type}->{images} = [ $c->model("DB::Observationimage")->searchSystemImagesByImageType(
				$organism->organism_id,
				$charactertype,
				$type,
				10,
				1
			)];
			$c->stash->{images}->{$charactertype}->{$type}->{numberofimages} =  $c->model("DB::Observationimage")->searchSystemImagesByImageType(
				$organism->organism_id,
				$charactertype,
				$type,
			)->count;
			
		}
	}
	
	# Used for setting default month and day for date search
	(my $second, my $minute, my $hour,my $day, my $month, my $yearOffset, my $dayOfWeek, my $dayOfYear, my $daylightSavings) = localtime();
  	
  	$c->stash(
  		template		=>	'organisms/organisminfo.tt',
  		organism		=>	$organism,
  		observations	=> [
  			$organism->observations->searchActiveOrganismPointsAroundDate(
				$month+1,
				$day,
				25
			)
		],
		users_organisms			=>	[
			$c->model('DB::UsersOrganism')->searchOrganismWithActiveUserObservations($organism->organism_id)
		],
		cache			=>	1
	);	
}

sub viewOrganismInfo_sitemap {
	my ( $self, $c, $sitemap ) = @_;
       
	foreach my $organism ($c->model('DB::Organism')->search()) {
		$sitemap->add($c->uri_for($c->controller('Organisms')->action_for('viewOrganismInfo'), $organism->organism_url));
    }

}


=head2 latestOrganismSightings

Find the latest sightings

=cut
sub latestOrganismSightings :Chained('base') :PathPart('latest') :Args(0) :Sitemap {
	my ($self, $c) = @_;
	
	# Show the homepage
	$c->stash(
		template		=>	'organisms/latestorganismsightings.tt',
		observations	=>	[
			$c->model('DB::Observation')->searchLatestSightings()
		],
		cache			=>	1
	);	
}

=head2 viewObservation

View details about the observation

=cut
sub viewObservation :Chained('base') :PathPart('observation') :Args(1) {
	my ($self, $c, $observation_id) = @_;
	
	my $observation = $c->model('DB::Observation')->findValidObservationByID(
  			$observation_id
  	);
  	
  	if (defined $observation) {
	  	$c->stash(
			template	=>	'organisms/observationinfo.tt',
	  		observation	=>	$observation,
	  		cache		=>	1
	  	);
  	}
  	else {
  		$c->detach(
			'Root',
			'default'
		);
		exit();
  	}
}

=head2 viewUserLifeList

View a user's lifelist

=cut
sub viewUserLifeList :Chained('base') :PathPart('lifelist') :Args(2) {
	my ($self, $c, $provider, $authid) = @_;
  	
	
	my $user = $c->model('DB::User')->findUserByAuthIDandProvider($provider, $authid);
	

	$c->stash(
		userorganisms	=>	[
			$c->model('DB::UsersOrganism')->searchLifeListOrganismsWithPublishedObservations($user->user_id)
		],
		userinfo	=>	$user,
		template	=>	'organisms/userlifelist.tt',
		cache		=>	1
	);	
	

}

=head2 viewUserOrganismInfo

View a user's notes, observations and photos about an organism

=cut
sub viewUserOrganismInfo :Chained('base') :PathPart('user') :Args(3) {
	my ($self, $c, $organism_name, $provider, $authid) = @_;
		
	my $userorganism = $c->model('DB::UsersOrganism')->findUserOrganismWithPublishedObservations(
		$c->model('DB::User')->findUserByAuthIDandProvider(
			$provider, 
			$authid
		)->user_id,
		$c->model('DB::Organism')->findOrganismInfo(
			$organism_name
		)->organism_id
	);
	
	if (defined $userorganism && $userorganism->observations->searchPublished()->count() > 0) {
		$c->stash(
			template		=>	'organisms/userorganisminfo.tt',
	  		userorganism	=>	$userorganism,
	  		observations	=>	[
	  			$userorganism->observations->searchPublished()
	  		],
	  		cache			=>	1
	 	);
  	}
  	else {
  		$c->detach(
			'Root',
			'default'
		);
		exit();
  	}

}




=head1 AUTHOR

Harry Shyket

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

