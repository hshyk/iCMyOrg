package Site::Controller::User_REST;
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

What to do when access is denied

=cut
sub access_denied : Private {
    my ( $self, $c, $action ) = @_;
	
	my @allallowedpaths = ('user/request/picup/sendimage');
	
	if(grep $_ eq $c->request->path, @allallowedpaths){
		$c->forcibly_allow_access;
	}
	else {
		$c->flash->{status_msg} = "Your session has timed out, please login";
		$c->response->redirect(
			$c->uri_for($c->controller('Login')->action_for('login'))
		);
	}
}
 

sub base :Chained('/') :PathPart('user/request') :CaptureArgs(0) {
	my ($self, $c) = @_;	
		
}

## View the User's Observations
sub searchUserObservations : Chained('base') PathPart('search/observations') ActionClass('REST') Args(0) {
    my ( $self, $c ) = @_;
}

sub searchUserObservations_POST {
	  my ( $self, $c ) = @_;
	  
	  
	$c->stash->{data} = "";
	$c->stash->{issuccess} = 0;
	
	my $observations = $c->model('DB::Observation')->searchAllUserObservations(
		$c->user()->user_id,
		10,	
		$c->request->params->{'page'}
	);		
	
	my @results;
			
			foreach my $observation($observations->all) {
				my $item;
				
				my $detail  = substr($observation->location_detail, 0, 40);
				
				if (length($observation->location_detail) > 40) {
					$detail .= "...";
				}

				$item->{'latitude'} = $observation->latitude;
				$item->{'longitude'} = $observation->longitude;
				$item->{'type'} = $observation->observation_type->observation_name;
				$item->{'date_observed'} = $observation->date_observed_display;
				$item->{'location_detail'} = $detail;
				$item->{'image_id'} = $observation->first_image->image_id;
				$item->{'image_path'} = $observation->first_image->filename;
				$item->{'source'} = $observation->source;
				$item->{'common_name'} = $observation->organism->common_name;
				$item->{'observation_id'} = $observation->observation_id;
				$item->{'status'} = $observation->observestatus->status_name;
				$item->{'url'} = $c->uri_for(
					$c->controller('User')->action_for('observationInfo'),
					$observation->observation_id
				)."";
				
				push(@results, $item); 
		 	} 
		 	
			$c->stash->{observations} = [@results];
			$c->stash->{issuccess} = 1;
}

sub uploadPicupImage :Chained('base') :PathPart('picup/sendimage') ActionClass('REST') Args(0) {
	  my ( $self, $c ) = @_;
}

sub uploadPicupImage_POST {
	my ($self, $c) = @_;

  	 my $picup = $c->model('DB::Picup')->find(
  	 	{
  	 		passkey => $c->request->params->{'key'}
  	 	}
  	 );
  	 
 	 
  	 my $imageprocess = $c->model('Image::Tiler');
  	 

  	 if ($picup && $imageprocess->validateFileType($c->request->upload('file')->tempname, 0)) {
	  	
	  	my $user = $picup->observation->user_organism->users;
	  	 
		my $imageDirectory = Site->path_to(
			'root',
		   	'static', 
		   	'images',
		   	lc($c->config->{Site}->{organisms_singular}), 
		   	'user',
		   	$user->provider->provider_name,
		   	$user->authid,
		   	$picup->observation->user_organism->organism->organism_url
	   	)->stringify;	   			
			   					    
		my $organismUrl = '/static/images/'.lc($c->config->{Site}->{organisms_singular}).'/user/'.$user->provider->provider_name.'/'.$user->authid.'/'.$picup->observation->user_organism->organism->organism_url;

		my @allimages;
		$imageprocess->checkFileExists($imageDirectory, $c->request->upload('file')->tempname);
		push (@allimages, $imageprocess->saveImageThumbnailTile($imageDirectory, $c->request->upload('file')->tempname));
			
		foreach my $randfile (@allimages) {
		  		$c->model('DB::Observationimage')->create(
		  			{
		  				observation_id => $picup->observation->observation_id, 
		  				image_type_id => $c->model('DB::Observationimagetype')->find(
		  					{
		  						image_type_name => $c->config->{Site}->{images}->{defaultimagetype}		
		  					}
		  				)->image_type_id,
		  				filename => $organismUrl.'/'.$randfile,
		  				photographer => $picup->observation->user_organism->users->get_full_name()
		  			}
		  		);
			}
		}
}

sub confirmPicupImage :Chained('base') :PathPart('picup/confirmimage') ActionClass('REST') Args(0) {
	my ($self, $c) = @_;

}

sub confirmPicupImage_POST {
	my ($self, $c) = @_;
  	
  	$c->stash->{issuccess} = 0;
	if( defined $c->session->{'picup_passkey'} && $c->model('DB::Picup')->update_or_create(
			{
				observation_id => $c->request->params->{'observation'},
				passkey => $c->session->{'picup_passkey'},
				ip_address => $c->request->address
			}
		)
	) {
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
