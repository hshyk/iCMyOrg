package Site::Controller::Admin_REST;
use Moose;
use namespace::autoclean;

 __PACKAGE__->config(
	'default'   => 'application/json',
    'stash_key' => 'data',
    'map'       => {
		'application/json'          => [ 'View', 'JSON', ],
	}
 );

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Site::Controller::Organisms_REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

=head2 access_denied

Redirects to login page when access is denied

=cut

sub access_denied : Private {
	my ( $self, $c, $action ) = @_;
	
	#redirect to the login page
	$c->response->redirect(
		$c->uri_for('/login')
	);
}
 

=head2 base

Base method for admin REST requests

=cut
sub base :Chained('/') :PathPart('admin/request') :CaptureArgs(0) {
	my ($self, $c) = @_;	
		
}

=head2 searchOrganismStates

Search for an organism's states

=cut
sub searchOrganismStates : Chained('base') PathPart('organism/states') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
}

sub searchOrganismStates_POST {
	my ( $self, $c ) = @_;  
	  
	$c->stash->{data} = "";
	$c->stash->{issuccess} = 0;
	
	#makes sure the character is numeric (does an id search)
  	if ($c->request->params->{'organism_id'} =~ /^\d+?$/) {
			
		#get the organism states from the request by organism id
		my $organismstates = $c->model('DB::OrganismsState')->search(
			{
				organism_id	=>	$c->request->params->{'organism_id'}
			}
		);
	  	
		my $stateList;
		
		#puts state id and value into an array
		foreach ($organismstates->all) {
			$stateList->{$_->state_id} = {
				"name" => $_->state->state_name,
				"character" => $_->state->character->character_name,  
				"low_value" => $_->low_value, 
				"high_value" => $_->high_value,
				"organism_id" => $_->organism_id,
				"url"	=>	$c->uri_for($c->controller('Admin')->action_for('viewOrganismStateByID'), $_->organism_id, $_->state_id).""							
			};
		}
		
		#store the state names
		$c->stash->{states} = $stateList;
		
		#brings back the data as JSON
		$c->stash->{issuccess} = 1;
  	}
}

=head2 searchOrganismHosts

Search for an organism's hosts

=cut
sub searchOrganismHosts : Chained('base') PathPart('organism/hosts') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
}

sub searchOrganismHosts_POST {
	my ( $self, $c ) = @_;  
	  
	$c->stash->{data} = "";
	$c->stash->{issuccess} = 0;
	
	#makes sure the character is numeric (does an id search)
  	if ($c->request->params->{'organism_id'} =~ /^\d+?$/) {
			
		#get the organism states from the request by organism id
		my $organismhost = $c->model('DB::OrganismsHost')->search(
			{
				organism_id	=>	$c->request->params->{'organism_id'}
			}
		);
	  	
		my $hostList;
		
		#puts host id and value into an array
		foreach ($organismhost->all) {
			$hostList->{$_->host_id} = {
				"host_id"	=>	$_->host_id,
				"scientific_name" => $_->host->scientific_name,
				"common_name"  => $_->host->common_name,
				"url"  => $c->uri_for($c->controller('Admin')->action_for('viewOrganismHostByID'), $_->organism_id, $_->host_id)."",
				"organism_id" => $_->organism_id,
			};
		}
		
		#store the host names
		$c->stash->{hosts} = $hostList;
		
		#brings back the data as JSON
		$c->stash->{issuccess} = 1;
  	}
}

=head2 searchOrganismObservations

Search for an organism's observations

=cut
sub searchOrganismObservations : Chained('base') PathPart('observations') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
    
    
}

sub searchOrganismObservations_POST {
	my ( $self, $c ) = @_;
	
		  
	$c->stash->{data} = "";
	$c->stash->{issuccess} = 0;
	
	#makes sure the character is numeric (does an id search)
  	if ($c->request->params->{'organism_id'} =~ /^\d+?$/) {
			
		#get the observation from the request by organism id
		my $observations = $c->model('DB::Observation')->searchAllNonSystemObservationsByOrganism($c->request->params->{'organism_id'});
			
		my $observationList;
		
		#puts observation id and value into an array
		foreach ($observations->all) {
			$observationList->{$_->observation_id} = {
				"type"	=>	$_->observation_type->observation_name,
				"date" => $_->date_observed_display,
				"latitude" => $_->latitude,  
				"longitude" => $_->longitude, 
				"location_detail" => $_->location_detail,
				"organism_id" => $_->organism_id,
				"provider"	=>	defined $_->user_organism ? $_->user_organism->user->provider->provider_name : '',
				"user"	=> defined $_->user_organism ? $_->user_organism->user->username : '',
				"user_url"	=> defined $_->user_organism ? $c->uri_for($c->controller('Admin')->action_for('viewUserByID'), $_->user_organism->user_id)."" : '',		
				"url"	=>	$c->uri_for($c->controller('Admin')->action_for('viewObservationByID'), [$_->observation_id]).""							
			};

		}
		
		#store the observations
		$c->stash->{observations} = $observationList;
		
		#brings back the data as JSON
		$c->stash->{issuccess} = 1;
  	}
}



=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
