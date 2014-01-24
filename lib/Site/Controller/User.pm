package Site::Controller::User;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use Site::Form::User::UpdateUserInfo;
use Site::Form::User::UpdateUserPassword;
use Site::Form::User::UserOrganismObservation;
use Site::Form::User::UserOrganismObservationChecklist;
use Site::Form::User::UserImageObservation;
use Site::Form::User::UserNotesObservation;
use Site::Form::User::DeleteObject;

with 'Site::Action::FormProcess';
with 'Site::Action::OrganismSearch';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 begin

Begin the controller

=cut

sub begin :Private {
	my ($self, $c) = @_;
}

=head2 access_denied

What to do when access is denied

=cut
sub access_denied : Private {
    my ( $self, $c, $action ) = @_;

	if (defined $c->request->cookie('hasloggedin') && !defined ($c->flash->{status_msg})) {
		$c->flash->{status_msg} = "Your session has timed out, please login again.";
	}
	
	$c->session->{login_redirect} = $c->request->uri;
	$c->response->redirect(
		$c->uri_for($c->controller('Authentication')->action_for('login'))
	);

}

=head2 base

The base method

=cut

sub base :Chained('/') :PathPart('user') :CaptureArgs(0) {
	my ($self, $c) = @_;
	
	#$c->flash->{status_msg} = "";
	$c->flash->{error_msg} = "";
	$c->stash(
		cache => 0
	);
	$c->stash->{clearpages} = [];
}

=head2 index

The index page

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( 
		template => 'user/index.tt'
    );
}

=head2 logout()

Log out the user

=cut
sub logout :Chained('/') :PathPart('logout') :Args(0) {
	my ($self, $c) = @_;
	
	$c->response->cookies->{'hasloggedin'} =
	{ 
		value	=>	'0',
   		expires => '+1s'
	};
	
	# Clear the user's state
	$c->logout;
	
	$c->log->debug($c->request->cookie('hasloggedin'));

	# Send the user to the starting point
	$c->response->redirect(
		$c->uri_for(
			'/'
		)
	);
}

=head2 updateInfo

Update your user info

=cut

sub updateInfo :Chained('base') :PathPart('account/info') :Args(0) {
	my ($self, $c) = @_;
		
	#get the user info
	my $info = $c->model('DB::User')->find(
		{
			user_id => $c->user()->user_id
		}
	);
	
	$c->forward('formprocess_redirect',[
		Site::Form::User::UpdateUserInfo->new(
			init_object => {
				email => $info->email,
				first_name => $info->first_name,
				last_name => $info->last_name
			},
			schema			=>	$c->model("DB")->schema,
		),
		$info,
		"Your information has been updated", 
		"Could not update your information", 
		'user/updateinfo.tt',
		$c->controller('User')->action_for(
			'index'
		)
	]);
}

=head2 updatePassword

Update the user password

=cut

sub updatePassword :Chained('base') :PathPart('account/password') :Args(0) {
	my ($self, $c) = @_;
	
	my $user = $c->model('DB::User')->find(
		{
			user_id => $c->user()->user_id,
		},
		{
			join => 'provider'
		}
	);
	
	if ($user->provider->provider_name ne $c->config->{Auth}->{Provider}->{Default}) {
		$c->response->redirect(
			$c->uri_for(
				$c->controller('User')->action_for(
					'index'
				)
			)
		)
	}
		
	$c->forward('formprocess_redirect',[
		Site::Form::User::UpdateUserPassword->new(
			schema		=>	$c->model('DB')->schema,
		),
		$user,
		"Your password has been updated", 
		"Could not update your password", 
		'user/updatepassword.tt',
		$c->controller('User')->action_for(
			'index'
		)
	]);
}



=head2 observation

The base method for observations

=cut
sub observation:	Chained('base')	:PathPart('observation')	:CaptureArgs(0) { 
	my ($self, $c) = @_;
	
	$c->stash(
		city		=>	'',
		geosuccess	=>	0,
		latitude	=>	'',
		longitude	=>	''
	);	
	
	if ($c->request->method eq 'POST') {
				
		my $geo = 0;
		if ($c->request->params->{'address'} ne '') {
			$geo = $c->forward("geo_code");
			if ($geo) {
				$c->stash(
					latitude	=>	$geo->getLatitude(),
					longitude	=>	$geo->getLongitude(),	
					city		=>	$geo->getCity(),
					geosuccess	=>	1
				);
			}
		}
		elsif ($c->request->params->{'latitude'} ne '' && $c->request->params->{'longitude'} ne '') {
			$c->request->params->{'address'} = $c->request->params->{'latitude'}.', '.$c->request->params->{'longitude'};
			$geo = $c->forward("geo_code");
			if ($geo) {
				$c->stash(
					latitude	=>	$c->request->params->{'latitude'},
					longitude	=>	$c->request->params->{'longitude'},
					city		=>	$geo->getCity(),
					geosuccess	=>	1
				);
			}
			$c->request->params->{'address'} = '';
		}
	}
	
	
	
}
=head2 addObservation

Add an observation

=cut

sub addObservation :Chained('observation') :PathPart('add') :Args(0) {
	my ($self, $c) = @_;
	
	my $organism_id = undef;
	my $organism = $c->request->params->{lc($c->config->{Site}->{organisms_singular})};
	if (defined $organism) {
		$organism_id =  $c->model('DB::Organism')->findOrganismInfo(
			$organism
		)->organism_id;
	}
	
	if ($c->request->method eq 'POST') {
		my $organism_selected = $c->model('DB::Organism')->find(
			{
				organism_id	=>	$c->request->params->{'organism_id'}
			}
		);
		
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('latestOrganismSightings')));
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewOrganismInfo'), $organism_selected->organism_url));
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewUserOrganismInfo'),$c->user()->provider_name_lower,$c->user()->authid,$organism_selected->organism_url));
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewUserLifeList'),$c->user()->provider_name_lower,$c->user()->authid));
	}

	$c->forward('formprocess_redirect',[
		Site::Form::User::UserOrganismObservation->new(
			schema			=>	$c->model("DB")->schema,
			geo				=>	$c->stash->{geosuccess},
			user_id			=>	$c->user()->user_id,
			lat				=>	$c->stash->{latitude},
			long			=>	$c->stash->{longitude},
			city			=>	$c->stash->{city},
			init_object		=>	{
				organism_id		=>	$organism_id,
			}
		),
		$c->model('DB::Observation')->new_result(
			{}
		),
		"Observation has been added", 
		"Could not add observation", 
		'user/addobservation.tt',
		$c->controller('User')->action_for(
			'viewLatestAddedObservation'
		)
	]);
}

=head2 addObservation

Add an observation

=cut

sub addObservationChecklist :Chained('observation') :PathPart('add/checklist') :Args(0) {
	my ($self, $c) = @_;

	$c->forward('formprocess_redirect',[
		Site::Form::User::UserOrganismObservationChecklist->new(
			schema			=>	$c->model("DB")->schema,
			geo				=>	$c->stash->{geosuccess},
			user_id			=>	$c->user()->user_id,
			lat				=>	$c->stash->{latitude},
			long			=>	$c->stash->{longitude},
			city			=>	$c->stash->{city},
			inactive		=>	['organism_id', 'number_seen', 'submit', 'review_comments'],
		),
		$c->model('DB::Observation')->new_result(
			{}
		),
		"Observations has been added", 
		"Could not add observations", 
		'user/addobservationchecklist.tt'
	]);
}

sub viewLatestAddedObservation :Chained('base') :PathPart('observation/latest') {
	my ($self, $c) = @_;
	
	$c->response->redirect(
		$c->uri_for(
			$c->controller('User')->action_for('observationInfo'),
			$c->model('DB::Observation')->searchLatestUserObservation(
				$c->user()->user_id
			)->observation_id
		)
	);
}

=head2 editObservation

Edit a tagged location

=cut
sub editObservation :Chained('observation') :PathPart('edit') :Args(1) {
    my ($self, $c, $observation_id) = @_;
	
	try {
		#get the user observation information
		my $observation = $c->model('DB::Observation')->find(
			$observation_id,
		);
		
		if (!defined $observation || $observation->user_organism->user_id ne $c->user()->user_id) {
			$c->detach(
				'Root',
				'default'
			);
			exit();
		}
		
		if ($c->request->method eq 'POST') {
			my $organism_selected = $c->model('DB::Organism')->findOrganismInfo(
				$c->request->params->{'organism_id'}
			);
			
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('latestOrganismSightings')));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewOrganismInfo'), $observation->organism->organism_url));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewUserOrganismInfo'),$c->user()->provider_name_lower,$c->user()->authid,$observation->organism->organism_url));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewUserLifeList'),$c->user()->provider_name_lower,$c->user()->authid));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$observation->observation_id));
		}
		
		#remove the leading 0 to match the select options
		my $month = $observation->date_observed_month;
		my $day = $observation->date_observed_day;
		$month  =~ s/^0*//;
		$day =~ s/^0*//;
		
		
		$c->forward('formprocess_redirect',[
			Site::Form::User::UserOrganismObservation->new(
				schema			=>	$c->model("DB")->schema,
				geo				=>	$c->stash->{geosuccess},
				user_id			=>	$c->user()->user_id,
				lat				=>	$c->stash->{latitude},
				long			=>	$c->stash->{longitude},
				city			=>	$c->stash->{city},
				init_object => {
					organism_id			=>	$observation->organism_id,
					observed_location	=> 'address',
					address				=>	$observation->latitude.', '.$observation->longitude,,
					latitude			=>	$observation->latitude,
					longitude			=>	$observation->longitude,
					day					=>	$day,
					month 				=>	$month,
					year 				=>	$observation->date_observed_year,
					location_detail		=>	$observation->location_detail,
					status_id			=>	$observation->status_id,
					number_seen			=>	$observation->number_seen
				}
			),
			$observation,
			"Observation has been updated", 
			"Could not update your observation", 
			'user/editobservation.tt',
			$c->controller('User')->action_for(
				'observationInfo'
			),
			($observation->observation_id),
		]);
	}
	catch {
    	$c->detach(
			'Root',
			'default'
		);
		exit();
    }	
}

=head2 deleteObservation

Delete a user observation

=cut
sub deleteObservation :Chained('observation') :PathPart('delete') :Args(1) {
    my ($self, $c, $observation_id) = @_;
    
    try {
	    #get the user observation information
		my $observation = $c->model('DB::Observation')->find(
			$observation_id,
		);
		
		if (!defined $observation || $observation->user_organism->user_id ne $c->user()->user_id) {
			$c->detach(
				'Root',
				'default'
			);
			exit();
		}
			
		if ($c->request->method eq 'POST') {
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('latestOrganismSightings')));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewOrganismInfo'), $observation->organism->organism_url));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewUserOrganismInfo'),$c->user()->provider_name_lower,$c->user()->authid,$observation->organism->organism_url));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewUserLifeList'),$c->user()->provider_name_lower,$c->user()->authid));
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$observation->observation_id));
		}
		
		my $userorganism = $observation->user_organism;
		
		my @images;
		
		foreach my $image($observation->observationimages) {
			my $path = Site->path_to(
				'root',
				 $image->filename
			)->stringify;
			push(@images,$path);
			push(@images,$path.'-original.jpg');
		}
		if ($c->forward('formprocess',[
			Site::Form::User::DeleteObject->new(
				schema => $c->model('DB')->schema,
			),
			$observation, 
			"Observation deleted", 
			"Could not delete image", 
			'user/deleteobservation.tt',
		])) {
			
			$c->model("Image::Tiler")->deleteImages(
				@images
			);
			
			if ($userorganism->observations->count() < 1) {
				$userorganism->delete();
			}
			
			$c->response->redirect(
				$c->uri_for(
					$c->controller('User')->action_for(
						'viewObservationsList'
					)
				)
			)
		} 
    }
	catch {
    	$c->detach(
			'Root',
			'default'
		);
		exit();
    }		
}



=head2 observationInfo

Shows the observation information for a user created observation

=cut
sub observationInfo :Chained('base') :PathPart('observation/view') :Args(1) {
    my ($self, $c, $observation_id) = @_;
    
    try {
	    
	    #get the user observation information
		my $observation = $c->model('DB::Observation')->find(
			$observation_id
		);

		if (!defined $observation->user_organism || $observation->user_organism->user_id ne $c->user()->user_id) {
			$c->detach(
				'Root',
				'default'
			);
			exit();
		}
			
		$c->stash( 
			template => 'user/viewobservation.tt',
		 	observation => $observation,
	  		user => $c->user(),
		);			   
    }
    catch {
    	$c->detach(
			'Root',
			'default'
		);
		exit();
    }
}


=head2 viewObservationMap

View your observations on a map

=cut
sub viewObservationMap :Chained('base') :PathPart('observations/map') :Args(0) {
    my ($self, $c) = @_;
	
	$c->stash(
		observations	=>	[
			$c->model('DB::Observation')->searchAllUserObservations(
				$c->user()->user_id
			)
		],
		template		=>	'user/viewobservationsmap.tt',
	);	
}

=head2 viewObservationsList

View your observations in a list

=cut
sub viewObservationsList :Chained('base') :PathPart('observations/list') :Args(0) {
    my ($self, $c) = @_;
	
	$c->stash(
		template	=>	'user/viewobservationslist.tt',
	);	
}

=head2 viewLifeList

View your lifelist

=cut
sub viewLifeList :Chained('base') :PathPart('lifelist') :Args(0) {
    my ($self, $c) = @_;
	
	$c->stash(
		template	=>	'user/viewlifelist.tt',
		usercount	=>	$c->model('DB::UsersOrganism')->search(
			{
				user_id	=>	$c->user()->user_id
			}
		)->count,
		totalcount	=>	$c->model('DB::Organism')->search()->count,
		organisms	=> [$c->model('DB::UsersOrganism')->searchLifeListOrganismsWithAllObservations(
			$c->user()->user_id
		)],
		
	);	
}


=head2 organismInfo

Shows the user the information for the organism they tagged

=cut
sub viewOrganismInfo :Chained('base') :PathPart('lifelist/name') :Args(1) {
    my ($self, $c, $organism_name) = @_;
    
   try {
		my $userorganism = $c->model('DB::UsersOrganism')->find(
			{
				user_id => $c->user()->user_id, 
				organism_id => $c->model('DB::Organism')->findOrganismInfo($organism_name)->organism_id
			},
			{
				prefetch	=>	[
					'organism'
				],
			}	
		);
		$c->stash( 
			template => 'user/organism.tt',
		 	userorganism => $userorganism,
		 	observations => [$userorganism->observations->search(
				{},
				{
					order_by => { 
						-desc => [qw/date_observed/] 
					},
				}
			)]
		);			   
    }
	catch {
		$c->detach(
			'Root',
			'default'
		);
		exit();
    }
}

=head2 observationDetail

Show details abotu the observation

=cut
sub observationDetail:	Chained('base')	:PathPart('observation')	:CaptureArgs(1) { 
	my ($self, $c, $observation_id) = @_;
	
	my $observation = $c->model('DB::Observation')->find(
		{
			observation_id => $observation_id
		}
	);
		
	if (!defined $observation->user_organism || $observation->user_organism->user_id ne $c->user()->user_id) {
		$c->detach(
			'Root',
			'default'
		);
		exit();
	}
	
	$c->stash(	
		#organism_url => $observation->user_organism->organism->organism_url,
		observation => $observation
	);	
}

=head2 addImageToObservations

Add photos to observations

=cut
sub addImageToObservations :Chained('observationDetail') :PathPart('image/add') :Args(0) {
	my ($self, $c) = @_;

	if (
		(
			$c->model("Device::Type")->isiPhone() || 
			$c->model("Device::Type")->isiPad() ||
			$c->model("Device::Type")->isiPod()
		)
		&&
		$c->model("Device::Browser")->safari() && 
		($c->model("Device::Browser")->public_version() < 6)
	) {
		$c->detach('addImageToObservationsPicup');
		exit;
	}

	if ($c->request->method eq 'POST') {
		$c->request->params->{image} = $c->request->upload(
			'image'
		);
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));

	}

	$c->forward('formprocess_redirect',[
		Site::Form::User::UserImageObservation->new(
			schema => $c->model('DB')->schema,
			observation_id	=>	$c->stash->{observation}->observation_id,
			imageprocessor	=>	$c->model("Image::Tiler"),
			imageupload	=>	$c->request->params->{image} || 0,
			imagepath	=>	 Site->path_to(
				'root',
		   		'static', 
		   		'images',
		   		lc($c->config->{Site}->{organisms_singular}), 
		   		'user',
		   		lc($c->user()->provider->provider_name),
		   		$c->user()->authid,
		   		$c->stash->{observation}->organism->organism_url
   			)->stringify,
   			filenamepath	=>	'/static/images/'.lc($c->config->{Site}->{organisms_singular}).'/user/'.lc($c->user()->provider->provider_name).'/'.$c->user()->authid.'/'.$c->stash->{observation}->organism->organism_url,
			init_object => {
				photographer => $c->user()->get_full_name(),
				copyright => $c->user()->get_full_name()
			}
		),
		$c->model('DB::ObservationImage')->new_result(
			{}
		), 
		"Photo Added", 
		"Could not add photo", 
		'user/addimageobservation.tt',
		$c->controller('User')->action_for('observationInfo'),
		($c->stash->{observation}->observation_id)
	]); 
	
}

=head2 addImageToObservationsPicup

Add images using the Picup App (for iOS 5 and lower)

=cut
sub addImageToObservationsPicup :Chained('observationDetail') :PathPart('image/add/picup') :Args(0) {
	my ($self, $c) = @_;
	
	my $pass = new String::Random;
	my $passkey =  $pass->randpattern("sssssssssssss");

	$c->session->{'picup_passkey'} = $passkey;
	
	if ($c->request->method eq 'POST') {
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));
	}
	
	$c->stash(
		passkey			=>	$passkey,
		template		=>	'user/addimagepicup.tt',
		observation_id	=>  $c->stash->{observation}->observation_id
	);	
	
}

=head2 observationImage

View observation image details

=cut
sub observationImage :	Chained('observationDetail')	:PathPart('image')	:CaptureArgs(1) { 
	my ($self, $c, $image_id) = @_;
	
	# Get the observation image by the observation and image id
	my $image = $c->model('DB::Observationimage')->find(
		{
			image_id => $image_id,
			observation_id	=>	$c->stash->{observation}->observation_id
		}
	);	
	
	if (!defined $image->observation->user_organism || $image->observation->user_organism->user_id ne $c->user()->user_id) {
		$c->response->redirect(
			$c->uri_for('/')
		);
	}
	else {
		$c->stash(
			image => $image
		);
	}
}

=head2 editImageObservation

Edit images from observation

=cut
sub editImageObservation :Chained('observationImage') :PathPart('edit') :Args(0) {
	my ($self, $c) = @_;
	
	if ($c->request->method eq 'POST') {
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));
	}
	
	$c->forward('formprocess_redirect',[
		Site::Form::User::UserImageObservation->new(
			schema => $c->model('DB')->schema,
			observation_id	=>	$c->stash->{observation}->observation_id,
			init_object => {
				image_type_id => $c->stash->{image}->image_type_id,
				character_type_id  => $c->stash->{image}->character_type_id,
				gender_id  =>  $c->stash->{image}->gender_id,
				description_id  => $c->stash->{image}->description_id,
				image_comments  => $c->stash->{image}->image_comments,
				photographer  => $c->stash->{image}->photographer,
				copyright	=>	$c->stash->{image}->copyright
			},
			inactive	=>	[
				'image'
			]
		),
		$c->stash->{image}, 
		"Image Updated", 
		"Could not update image", 
		'user/editimageobservation.tt',
		$c->controller('User')->action_for(
				'observationInfo'
			),
		($c->stash->{image}->observation->observation_id)
	]); 		
}

=head2 deleteImageObservation

Delete images from an observation

=cut
sub deleteImageObservation :Chained('observationImage') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;
    
    if ($c->request->method eq 'POST') {
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));
	}

	if ($c->forward('formprocess',[
		Site::Form::User::DeleteObject->new(
			schema => $c->model('DB')->schema,
		),
		$c->stash->{image}, 
		"Image deleted", 
		"Could not delete image", 
		'user/deleteimageobservation.tt',
		$c->controller('User')->action_for(
			'observationInfo'
		),
		
	])) {
		my $path = Site->path_to(
			'root',
			$c->stash->{image}->filename
		)->stringify;
		
		
		$c->model("Image::Tiler")->deleteImages(
			($path, $path.'-original.jpg')
		);
		$c->response->redirect(
			$c->uri_for(
				$c->controller('User')->action_for(
					'observationInfo'
				),
				($c->stash->{image}->observation->observation_id)
			)
		)
	} 		
}


=head2 addNoteToObservations

Add  a note to observation

=cut

sub addNoteToObservations :Chained('observationDetail') :PathPart('note/add') :Args(0) {
	my ($self, $c) = @_;
	
	try {
		
		if ($c->request->method eq 'POST') {
			push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));
		}
	   	
	   	$c->forward('formprocess_redirect',[
			Site::Form::User::UserNotesObservation->new(
				schema => $c->model('DB')->schema,
				observation_id	=>	 $c->stash->{observation}->observation_id,
			),
			$c->model('DB::Observationnote')->new_result(
				{}
			),
			"Note added", 
			"Could not add note", 
			'user/addnotesobservation.tt',
			$c->controller('User')->action_for(
				'observationInfo'
			),
			( $c->stash->{observation}->observation_id)
		]); 	
	   		   	
	}
	catch {
    	$c->detach(
			'Root',
			'default'
		);
		exit();
    }
	
}

=head2 viewobservationNote

View a note

=cut
sub observationNotes :	Chained('observationDetail')	:PathPart('note')	:CaptureArgs(1) { 
	my ($self, $c, $note_id) = @_;
	
	# Get the observation not by the observation id and note id
	my $note = $c->model('DB::Observationnote')->find(
		{
			note_id => $note_id,
			observation_id	=>	$c->stash->{observation}->observation_id
		}
	);	
	
	# Check that the note belongs to the user
	if (!defined $note->observation->user_organism || $note->observation->user_organism->user_id ne $c->user()->user_id) {
			$c->detach(
			'Root',
			'default'
		);
		exit();
	}
	else {
		$c->stash(
			note => $note
		);
	}
}

=head2 editNoteObservations

Edit a note

=cut
sub editNoteObservations :Chained('observationNotes') :PathPart('edit') :Args(0) {
	my ($self, $c) = @_;
	
	if ($c->request->method eq 'POST') {
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));
	}
	
	$c->forward('formprocess_redirect',[
		Site::Form::User::UserNotesObservation->new(
			schema => $c->model('DB')->schema,
			observation_id	=>	$c->stash->{observation}->observation_id,
			init_object => {
				notes	=>	$c->stash->{note}->notes
			},
		),
		$c->stash->{note}, 
		"Note Updated", 
		"Could not update note", 
		'user/editnoteobservation.tt',
		$c->controller('User')->action_for(
				'observationInfo'
			),
		($c->stash->{note}->observation->observation_id)
	]); 		
}

=head2 deleteNoteObservations

Delete a note

=cut
sub deleteNoteObservations :Chained('observationNotes') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;
	
	if ($c->request->method eq 'POST') {
		push($c->stash->{clearpages}, '*'.$c->uri_for($c->controller('Organisms')->action_for('viewObservation'),$c->stash->{observation}->observation_id));
	}
	
	$c->forward('formprocess_redirect',[
		Site::Form::User::DeleteObject->new(
			schema => $c->model('DB')->schema,
		),
		$c->stash->{note}, 
		"Note deleted", 
		"Could not delete note", 
		'user/deletenoteobservation.tt',
		$c->controller('User')->action_for(
			'observationInfo'
		),
		($c->stash->{note}->observation->observation_id)
	]); 		
}

=head2 closePicupWindow

Close the browser window used to upload to the Picup App

=cut
sub closePicupWindow :Chained('base') :PathPart('picup/return') :Args(0) {
	my ($self, $c) = @_;
	
	my $image = $c->model('DB::Observationimage')->find(
		{
			'user_organism.user_id' => $c->user()->user_id	
		},
		{
			prefetch => 
				{
					'observation' => 
						{
							'user_organism'
						}
				},
				order_by => 
					{ 
						-desc => 'me.image_id' 
					},
		}
	);
	
	$c->response->redirect(
		$c->uri_for(
			$c->controller('User')->action_for(
				'editImageObservation'
			),
			[
				$image->observation->observation_id,
				$image->image_id
			]
    		
    	)
    );

}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
