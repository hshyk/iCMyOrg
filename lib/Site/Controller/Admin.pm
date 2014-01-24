package Site::Controller::Admin;
use Moose;
use namespace::autoclean;
use Try::Tiny;

use Site::Form::Admin::Organism;
use Site::Form::Admin::ImageSystem;
use Site::Form::Admin::DefaultImage;
use Site::Form::Admin::Host;
use Site::Form::Admin::ImageHost;
use Site::Form::Admin::OrganismHost;
use Site::Form::Admin::Charactertype;
use Site::Form::Admin::Character;
use Site::Form::Admin::State;
use Site::Form::Admin::OrganismState;
use Site::Form::Admin::OrganismObservation;
use Site::Form::Admin::ImageObservation;
use Site::Form::Admin::ImageState;
use Site::Form::Admin::User;
use Site::Form::Admin::DeleteObject;

with 'Site::Action::FormProcess';
with 'Site::Action::OrganismSearch';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub begin :Private {
	my ($self, $c) = @_;
}

=head2 access_denied

Redirects to login page when access is denied

=cut
sub access_denied : Private {
	my ( $self, $c, $action ) = @_;
	
	#redirect to the login page
	if (defined $c->request->cookie('hasloggedin') && !defined ($c->flash->{status_msg})) {
		$c->flash->{status_msg} = "Your session has timed out, please login again.";
	}
	
	$c->session->{login_redirect} = $c->request->uri;
	$c->response->redirect(
		$c->uri_for($c->controller('Authentication')->action_for('login'))
	);
}

=head2 base

The base method for administration.
All others methods are chained of this base

=cut
sub base :Chained('/') :PathPart('admin') :CaptureArgs(0) {
	my ($self, $c) = @_;
	
	$c->flash->{error_msg} = "";
	$c->stash(
		cache => 0
	);
	$c->stash->{clearpages} = [];
		
}

=head2 index

The index page for administration

=cut
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	
	# If either of above don't work out, send to the login page
	$c->stash(
		template => 'admin/index.tt'
	);
}

=head2 addOrganism

Add an organism

=cut
sub addOrganism :Chained('base') :PathPart('add/organism') :Args(0) {
	my ($self, $c) = @_;
	
	$c->forward('formprocess_redirect',[
		Site::Form::Admin::Organism->new(
			schema				=>	$c->model("DB")->schema,
			inactive			=>	[
				'organisms_defaultimages'
			],
		),
		$c->model('DB::Organism')->new_result(
			{}
		),
		$c->config->{Site}->{organisms_singular}." Added", 
		"Could not add ".$c->config->{Site}->{organisms_singular}, 
		'admin/addorganism.tt',
		$c->controller('Admin')->action_for('addOrganism'),
	]);
	
}

=head2 viewOrganisms

View all organisms

=cut
sub viewOrganisms :Chained('base') :PathPart('view/organisms') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		organisms => [
			$c->model('DB::Organism')->search(
				{},
				{
					order_by => 'scientific_name'
				}
			)->all
		], 
		template => 'admin/viewallorganisms.tt'
	);
}

=head2 viewOrganism

View individual organism information

=cut
sub viewOrganismByID :Chained('base') :PathPart('view/organism') :Args(1) {
	my ($self, $c, $organism_id) = @_;
	
	#get all of the organisms
	my $organism = $c->model('DB::Organism')->find(
		$organism_id
	);
	
	$c->clear_cached_page( '*'.$c->uri_for($c->controller('Organisms')->action_for('viewOrganismInfo'), $organism->organism_url));
	
	$c->stash(
		organism => $organism,
		charactertypes	=>	[$c->model("DB::Charactertype")->searchDisplay()]
	);
	
	
	$c->forward('formprocess',[
		Site::Form::Admin::Organism->new(
			schema		=>	$c->model("DB")->schema,
			init_object	=>	{
				family_name 	=>	$organism->family_name,
				scientific_name =>	$organism->scientific_name,
				common_name 	=>	$organism->common_name,
				description		=>	$organism->description,
			}
		),
		$organism,
		"Organism Updated", 
		"Could not update organism", 
		'admin/vieworganismbyid.tt'
	]);	
}

=head2 addSystemImageToOrganism

Add system images to an organism's page

=cut
sub addSystemImageToOrganism :Chained('base') :PathPart('add/organism/image') :Args(0) {
	my ($self, $c) = @_;
	
	my $imagepath = '';
	my $filenamepath = '';
	
	#the request params for image must be set otherwise FormHandler will complain that the file is not found
	if ($c->request->method eq 'POST') {
				
		#the image is put into the parameters so that the form can process it straight from the parameters
		$c->request->params->{image} = $c->request->upload(
			'image'
		);
		
		my $organism_url = $c->model("DB::Organism")->find(
		   	{
		   		'organism_id'	=>	$c->request->params->{organism_id}
		   	}
		)->organism_url;
		
		$imagepath =  Site->path_to(
				'root',
		   		'static', 
		   		'images',
		   		lc($c->config->{Site}->{organisms_singular}),
		   		$organism_url
		)->stringify;
		
		$filenamepath = '/static/images/'.lc($c->config->{Site}->{organisms_singular}).'/'.$organism_url;
		   		
	} 
	
	$c->forward('formprocess',[
		Site::Form::Admin::ImageSystem->new(
			schema			=>	$c->model("DB")->schema,
			imageprocessor	=>	$c->model("Image::Tiler"),
			imageupload		=>	$c->request->params->{image} || 0,
			imagepath		=>	$imagepath,
   			filenamepath	=>	$filenamepath,
		),
		$c->model('DB::Observationimage')->new_result(
			{}
		), 
		"Image Added", 
		"Could not add image", 
		'admin/addsystemimage.tt'
	]);	
}

=head2 editOrganismDefaultImage

Edit the default image for an organism's character type.  This is used for info pages and searches

=cut
sub editOrganismDefaultImage :Chained('base') :PathPart('edit/organism/default/image') :Args(2) {
	my ($self, $c, $organism_id, $character_type_id) = @_;
	
	# Find the def
	my $defaultimage = $c->model("DB::OrganismsDefaultimage")->find(
		{
			organism_id			=>	$organism_id,
			character_type_id	=>	$character_type_id,		
		}
	);
	$c->forward('formprocess',[
		Site::Form::Admin::DefaultImage->new(
			schema		=>	$c->model("DB")->schema,
			organism_id			=>	$organism_id,
			character_type_id	=>	$character_type_id,
			init_object			=>	{
				image_id	=>	defined $defaultimage ?  $defaultimage->image_id : undef,
			}										
		),
		$defaultimage, 
		"Default Image Updated", 
		"Could not update default image", 
		'admin/editdefaultimage.tt'
	]);	
}

=head2 viewImageOrganisms

View all organisms' images

=cut
sub viewImageOrganisms :Chained('base') :PathPart('view/organism/images') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		organisms => [
			$c->model('DB::Organism')->search(
				{},
				{
					order_by => 'scientific_name'
				}
			)->all
		], 
		template => 'admin/viewimagesorganisms.tt'
	);
}

=head2 viewImagesOrganismByID

View individual organism's information

=cut
sub viewImagesOrganismByID :Chained('base') :PathPart('view/organism/image') :Args(1) {
	my ($self, $c, $organism_id) = @_;
	
	my $organism = $c->model('DB::Organism')->find(
		$organism_id
	);
	
	$c->stash(
		organism => $organism,
		images => [
			$c->model('DB::Observationimage')->search(
				{ 
					'observation.organism_id' => $organism->organism_id
				},
				{
					prefetch => [
						'observation',
					],
				}
			)
		], 
		template => 'admin/viewimagesorganismbyid.tt'
	);
}

=head2 viewImagesOrganismByID

Edit an organism's image information

=cut
sub editOrganismImage :Chained('base') :PathPart('edit/organism/image') :Args(1) {
	my ($self, $c, $image_id) = @_;
	
	#get all of the organisms's image by image id
	my $image = $c->model('DB::Observationimage')->find(
		$image_id
	);
	
	$c->stash(
		image => $image
	);
	
	$c->clear_cached_page( '*'.$c->uri_for($c->controller('Organisms')->action_for('viewOrganismInfo'), $image->observation->organism->organism_url));

	
	$c->forward('formprocess',[
		Site::Form::Admin::ImageSystem->new(
			schema		=>	$c->model("DB")->schema,
			inactive	=>	[
				'image'
			],
			init_object => {
				organism_id => $image->observation->organism_id,
				image_type_id => $image->image_type_id,
				character_type_id => $image->character_type_id,
				gender_id => $image->gender_id,
				description_id => $image->description_id,
				image_comments => $image->image_comments,
				photographer => $image->photographer,	
				copyright	=>	$image->copyright															
			}
		),
		$image, 
		"Image Updated", 
		"Could not update image", 
		'admin/editsystemimage.tt'
	]);	
}

=head2 deleteOrganism

Delete an organism

=cut
sub deleteOrganism :Chained('base') :PathPart('delete/organism') :Args(1) {
	my ($self, $c, $organism_id) = @_;
	

	# Get the organism
	my $organism = $c->model('DB::Organism')->find(
		{
			organism_id => $organism_id
		}
	);
	
	$c->stash(
		organism	=> $organism
	);
	
	my @images;
	 
	# Delete all associated observations and images 	
  	if ($c->request->method eq 'POST') {
  		$c->clear_cached_page('*');
  		foreach my $observation($organism->observations) {
  			foreach my $image ($observation->observationimages) {
				my $path = Site->path_to(
					'root',
					 $image->filename
				)->stringify;
				push(@images,$path);
				push(@images,$path.'-original.jpg');
  			}
		}

  	}
 
  	
  	if ($c->forward('formprocess',[ 
		Site::Form::Admin::DeleteObject->new(
			schema	=>	$c->model("DB")->schema,
		),
		$organism,  
		"Organism deleted", 
		"Could not delete organism", 
		'admin/deleteorganism.tt'
	])) {
		$c->model("Image::Tiler")->deleteImages(
			@images
		);
		$c->response->redirect(
			$c->uri_for(
				$c->controller('Admin')->action_for(
					'/'
				)
			)
		)
	}

}


=head2 addHost

Add a host 

=cut
sub addHost :Chained('base') :PathPart('add/host') :Args(0) {
	my ($self, $c) = @_;

	
	$c->forward('formprocess',[
		Site::Form::Admin::Host->new(
			schema		=>	$c->model("DB")->schema,
		
		),
		$c->model('DB::Host')->new_result(
			{}
		), 
		"Host Added", 
		"Could not add host", 
		'admin/addhost.tt'
	]);	
	
}

=head2 addHost

View all hosts

=cut
sub viewHosts :Chained('base') :PathPart('view/hosts') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		hosts => [
			$c->model('DB::Host')->search(
				{},
				{
					order_by => 'scientific_name'
				}
			)->all
		], 
		template => 'admin/viewallhosts.tt'
	);	
}

=head2 viewHostByID

View a specific host

=cut
sub viewHostByID :Chained('base') :PathPart('view/host') :Args(1) {
	my ($self, $c, $host_id) = @_;
	
	# Get the host's information
	my $host = $c->model('DB::Host')->find($host_id);
	
	
	$c->forward('formprocess',[
		Site::Form::Admin::Host->new(
			schema		=>	$c->model("DB")->schema,
				init_object => {
				scientific_name => $host->scientific_name,
				common_name => $host->common_name,																														
			}
		
		),
		$host, 
		"Host Updated", 
		"Could not update host", 
		'admin/viewhost.tt'
	]);	
	
}

=head2 deleteHost

Delete a host

=cut
sub deleteHost :Chained('base') :PathPart('delete/host') :Args(1) {
	my ($self, $c, $host_id) = @_;
	
	# Get the host information
	my $host = $c->model('DB::Host')->find($host_id);
	
	my @images;
	  
	# Delete all host images	
  	if ($c->request->method eq 'POST') {
  		foreach my $image($host->hostimages) {
			my $path = Site->path_to(
				'root',
				 $image->filename
			)->stringify;
			push(@images,$path);
			push(@images,$path.'-original.jpg');
		}

  	}
 
  	
  	if ($c->forward('formprocess',[ 
		Site::Form::Admin::DeleteObject->new(
			schema	=>	$c->model("DB")->schema,
		),
		$host,  
		"Photo Removed from Observation", 
		"Could not delete observation photo", 
		'admin/deleteimageobservation.tt'
	])) {
		$c->model("Image::Tiler")->deleteImages(
			@images
		);
		$c->response->redirect(
			$c->uri_for(
				$c->controller('Admin')->action_for(
					'/'
				)
			)
		)
	}

}

=head2 addImageToHost

Add images to a host

=cut
sub addImageToHost :Chained('base') :PathPart('add/host/image') :Args(0) {
	my ($self, $c) = @_;
	
	my $imagepath = '';
	my $filenamepath = '';
	
	#the request params for image must be set otherwise FormHandler will complain that the file is not found
	if ($c->request->method eq 'POST') {
				
		#the image is put into the parameters so that the form can process it straight from the parameters
		$c->request->params->{image} = $c->request->upload(
			'image'
		);
		
		my $host_url = $c->model("DB::Host")->find(
		   	{
		   		'host_id'	=>	$c->request->params->{host_id}
		   	}
		)->host_url;
		
		$imagepath =  Site->path_to(
				'root',
		   		'static', 
		   		'images',
		   		lc($c->config->{Site}->{host}->{name_singular}),
		   		$host_url
		)->stringify;
		
		$filenamepath = '/static/images/'.lc($c->config->{Site}->{host}->{name_singular}).'/'.$host_url;
		   		
	} 

	$c->forward('formprocess',[
		Site::Form::Admin::ImageHost->new(
			schema		=>	$c->model("DB")->schema,
			imageprocessor	=>	$c->model("Image::Tiler"),
			imageupload		=>	$c->request->params->{image} || 0,
			imagepath		=>	$imagepath,
   			filenamepath	=>	$filenamepath
		
		),
		$c->model('DB::Hostimage')->new_result(
			{}
		), 
		"Image Added", 
		"Could not add image", 
		'admin/addhostimage.tt'
	]);
	
}

=head2 viewImageHosts

View all host images

=cut
sub viewImageHosts :Chained('base') :PathPart('view/host/images') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		hosts => [
			$c->model('DB::Host')->search(
				{},
				{
					order_by => 'scientific_name'
				}
			)->all
		], 
		template => 'admin/viewimageshost.tt'
	);
}

sub viewImagesHostsByID :Chained('base') :PathPart('view/host/image') :Args(1) {
	my ($self, $c, $host_id) = @_;
	
	$c->stash(
		host => $c->model('DB::Host')->find($host_id),
		images => [
			$c->model('DB::Hostimage')->search(
				{ 
					'host_id' => $host_id
				},
			)
		], 
		template => 'admin/viewimageshostbyid.tt'
	);
}

=head2 editHostImageByID

Edit a host's image

=cut
sub editImageHostByID :Chained('base') :PathPart('edit/host/image') :Args(1) {
	my ($self, $c, $image_id) = @_;
	
	# Get the host's image by image id
	my $image = $c->model('DB::Hostimage')->find(
		$image_id
	);
	
	$c->stash(
		image => $image
	);
		
	$c->forward('formprocess',[
		Site::Form::Admin::ImageHost->new(
			schema		=>	$c->model("DB")->schema,
			inactive	=>	[
				'image',
			],
			init_object => {
				host_id => $image->host->host_id,
				image_type_id => $image->image_type_id,
				photographer => $image->photographer,
				copyright	=>	$image->copyright																
			}
		),
		$image, 
		"Image Updated", 
		"Could not update image", 
		'admin/edithostimage.tt'
	]);	

	
}

=head2 addOrganismHost

Assign a host to an organism

=cut
sub addOrganismHost :Chained('base') :PathPart('add/organism/host') :Args(0) {
	my ($self, $c) = @_;
	
	$c->forward('formprocess',[
		Site::Form::Admin::OrganismHost->new(
			schema		=>	$c->model("DB")->schema,
		),
		$c->model('DB::OrganismsHost')->new_result(
			{}
		), 
		"Organism Host Added", 
		"Could not add Organism Host", 
		'admin/addorganismhost.tt'
	]);
	
}

=head2 viewOrganismsHosts

View all of the hosts organisms

=cut
sub viewOrganismsHosts :Chained('base') :PathPart('view/organisms/hosts') :Args(0) {
	my ($self, $c) = @_;
		
	$c->stash(	
		organisms => [ $c->model('DB::Organism')->search( 
			{}, 
			{
				order_by => [
					'scientific_name'
				]
			}
		)->all], 
		template => 'admin/vieworganismshosts.tt',
	);
}


=head2 viewOrganismHostByID

View an organisms host information

=cut
sub viewOrganismHostByID :Chained('base') :PathPart('view/organism/host') :Args(2) {
	my ($self, $c, $organism_id, $host_id) = @_;
	
	my $organismhost = $c->model('DB::OrganismsHost')->find(
		{
			organism_id	=>	$organism_id,
			host_id	=>	$host_id
		}
	);
	
	$c->stash(
		organismhost => $organismhost
	);
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::OrganismHost->new(
			schema => $c->model('DB')->schema,
			init_object => {
				organism_id => $organismhost->organism_id,
				host_id => $organismhost->host_id,
			}
		), 
		$organismhost, 
		"State Updated", 
		"Could not update state", 
		'admin/editorganismhost.tt'
	]);
	
}

=head2 viewCharacterTypes

View all the character types

=cut
sub viewCharacterTypes :Chained('base') :PathPart('view/charactertypes') :Args(0) {
	my ($self, $c) = @_;
		
	$c->stash(
		charactertypes => [
			$c->model('DB::Charactertype')->searchDisplay()->all
		], 
		template => 'admin/viewcharactertypes.tt'
	);
	
}

=head2 addCharacterType

Add a character type

=cut
sub addCharactertype :Chained('base') :PathPart('add/charactertype') :Args(0) {
	my ($self, $c) = @_;
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::Charactertype->new(
			schema => $c->model('DB')->schema
		), 
		$c->model('DB::Charactertype')->new_result(
			{}
		), 
		"Character Type Added", 
		"Could not add character type", 
		'admin/addcharactertype.tt'
	]);
}

=head2 viewCharacterByID

View a character by its ID

=cut
sub viewCharactertypeByID :Chained('base') :PathPart('view/charactertype') :Args(1) {
	my ($self, $c, $charactertype_id) = @_;
	
	my $charactertype = $c->model('DB::Charactertype')->find($charactertype_id);
	
	$c->stash(
		charactertype => $charactertype
	);
		
	$c->forward('formprocess',[ 
		Site::Form::Admin::Charactertype->new(
			schema => $c->model('DB')->schema,
			init_object => {
				character_type => $charactertype->character_type,
			}
		), 
		$charactertype, 
		"Character Type Updated", 
		"Could not update character type", 
		'admin/editcharactertype.tt'
	]);
	

}
=head2 viewCharacters

View all the characters

=cut
sub viewCharacters :Chained('base') :PathPart('view/characters') :Args(0) {
	my ($self, $c) = @_;
		
	$c->stash(
		characters => [
			$c->model('DB::Character')->search(
				{},
				{ 
					join => 'character_type', 
					order_by => 'character_type.character_type'
				
			})->all
		], 
		template => 'admin/viewcharacters.tt'
	);
	
}





=head2 addCharacter

Add a character

=cut
sub addCharacter :Chained('base') :PathPart('add/character') :Args(0) {
	my ($self, $c) = @_;
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::Character->new(
			schema => $c->model('DB')->schema
		), 
		$c->model('DB::Character')->new_result(
			{}
		), 
		"Character Added", 
		"Could not add character", 
		'admin/addcharacter.tt'
	]);
}

=head2 viewCharacterByID

View a character by its ID

=cut
sub viewCharacterByID :Chained('base') :PathPart('view/character') :Args(1) {
	my ($self, $c, $character_id) = @_;
	
	my $character = $c->model('DB::Character')->find($character_id);
	
	$c->stash(
		character => $character
	);
		
		$c->forward('formprocess',[ 
		Site::Form::Admin::Character->new(
			schema => $c->model('DB')->schema,
			init_object => {
				character_name => $character->character_name,
				character_type_id => $character->character_type_id,
				is_numeric => $character->is_numeric
			}
		), 
		$character, 
		"Character Updated", 
		"Could not update character", 
		'admin/addcharacter.tt'
	]);
	
}

=head2 viewStates

View all states

=cut
sub viewStates :Chained('base') :PathPart('view/states') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		states => [$c->model('DB::State')->search(
			{},
			{
				join => {
        			'character' => {
          				'character_type'
        			}
      			},
      			order_by => [qw/character_type.character_type character.character_name me.state_name/]
			}
		)->all], 
		template => 'admin/viewstates.tt'
	);
}


=head2 addState

Add a state

=cut
sub addState :Chained('base') :PathPart('add/state') :Args(0) {
	my ($self, $c) = @_;
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::State->new(
			schema => $c->model('DB')->schema
		), 
		$c->model('DB::State')->new_result(
			{}
		), 
		"State Added", 
		"Could not add State", 
		'admin/addstate.tt'
	]);
	
}



=head2 viewStateByID

View a state by an ID

=cut
sub viewStateByID :Chained('base') :PathPart('view/state') :Args(1) {
	my ($self, $c, $state_id) = @_;
	
	my $state = $c->model('DB::State')->find($state_id);
	
	$c->stash(
		state => $state
	);
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::State->new(
			schema => $c->model('DB')->schema,
			init_object => {
				state_name => $state->state_name,
				character_id => $state->character_id
			}
		), 
		$state, 
		"State Updated", 
		"Could not update State", 
		'admin/addstate.tt'
	]);
	
}

=head2 addOrganismState

Assign a state to an organism

=cut
sub addOrganismState :Chained('base') :PathPart('add/organism/state') :Args(0) {
	my ($self, $c) = @_;
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::OrganismState->new(
			schema => $c->model('DB')->schema
		), 
		$c->model('DB::OrganismsState')->new_result(
			{}
		), 
		"Organism State Added", 
		"Could not add Organism State", 
		'admin/addorganismstate.tt'
	]);
}


=head2 viewOrganismStates

View all of the states that are assigned to an organism

=cut
sub viewOrganismStates :Chained('base') :PathPart('view/organisms/states') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(	
		organisms => [ $c->model('DB::Organism')->search( 
			{}, 
			{
				order_by => [
					'scientific_name'
				]
			}
		)->all], 
		template => 'admin/vieworganismsstates.tt',
	);
}


=head2 viewOrganismStateByID

View states assigned to organisms

=cut
sub viewOrganismStateByID :Chained('base') :PathPart('view/organism/state') :Args(2) {
	my ($self, $c, $organism_id, $state_id) = @_;
	
	my $organismstate = $c->model('DB::OrganismsState')->find(
		{
			organism_id	=>	$organism_id,
			state_id	=>	$state_id
		}
	);
	
	$c->stash(
		organismstate => $organismstate
	);
	
	$c->forward('formprocess',[ 
		Site::Form::Admin::OrganismState->new(
			schema => $c->model('DB')->schema,
			init_object => {
				organism_id => $organismstate->organism_id,
				state_id => $organismstate->state_id,
				high_value	=>	$organismstate->high_value,
				low_value	=>	$organismstate->low_value
			}
		), 
		$organismstate, 
		"State Updated", 
		"Could not update state", 
		'admin/editorganismstate.tt'
	]);
	
}


=head2 observation

Observation base method

=cut
sub observation:	Chained('base')	:PathPart('observation')	:CaptureArgs(0) { 
	my ($self, $c) = @_;

	
	$c->stash(
		city		=>	'',
		geosuccess	=>	0,
		latitude		=>	'',
		longitude		=>	''
	);
	
	# If data is posted and there is an address, get the geo information
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

=head2 viewObservations

View all of the observations

=cut
sub viewObservations :Chained('base') :PathPart('view/observations') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		# Get all of the organisms
		organisms => [
			$c->model('DB::Organism')->search(
				{},
				{
					order_by => 'common_name'
				}
			)->all
		], 
		template => 'admin/viewobservationsorganism.tt'
	);
}

=head2 addObservation

Add an observation to an organism

=cut
sub addObservation :Chained('observation') :PathPart('add') :Args(0) {
	my ($self, $c) = @_;

	$c->forward('formprocess',[ 
		Site::Form::Admin::OrganismObservation->new(
			schema			=>	$c->model("DB")->schema,
			geo				=>	$c->stash->{geosuccess},
			user_id			=>	0,
			lat				=>	$c->stash->{latitude},
			long			=>	$c->stash->{longitude},
			city			=>	$c->stash->{city}
		),
		$c->model('DB::Observation')->new_result(
			{}
		), 
		"Observation Added", 
		"Could not add observation", 
		'admin/addobservation.tt'
	]);	
}


=head2 viewObservationsByID

View the specific observation

=cut
sub viewObservationByID :Chained('observation') :PathPart('view') :Args(1) {
	my ($self, $c, $observation_id) = @_;
		
	#grab the observation by the id
	my $observation = $c->model('DB::Observation')->find(
		{
			observation_id => $observation_id
		}
	);
	
	#use try catch to make sure that a proper id is set for the observation
	try {
		
		my $month = $observation->date_observed_month;
		$month  =~ s/^0*//;
		
		$c->forward('formprocess',[ 
			Site::Form::Admin::OrganismObservation->new(
				schema			=>	$c->model("DB")->schema,
				geo				=>	$c->stash->{geosuccess},
				user_id			=>	0,
				lat				=>	$c->stash->{latitude},
				long			=>	$c->stash->{longitude},
				city			=>	$c->stash->{city},
				init_object => 
				{
					organism_id 		=> $observation->organism_id,
					observed_location	=> 'address',
					observation_type_id	=>	$observation->observation_type_id,
					address				=>	$observation->latitude.', '.$observation->longitude,
					latitude			=>	$observation->latitude,
					longitude			=>	$observation->longitude,
					day					=>	$observation->date_observed_day,
					month 				=>	$month,
					year 				=>	$observation->date_observed_year,
					location_detail		=>	$observation->location_detail,
					source				=>	$observation->source,
					status_id			=>	$observation->status_id
				},
			),
			$observation, 
			"Observation Updated", 
			"Could not update observation", 
			'admin/viewobservation.tt'
		]);	

		#load the photos for the observation									
		$c->stash(
			observation=> $observation,
			photos => [$c->model('DB::ObservationImage')->search(
				{
					observation_id => $observation_id
				}
			)]
		);
	}
	catch {
		$c->flash->{status_msg} = "No proper ID set";
		$c->forward('viewObservations');
	}	
}

=head2 deleteObservation

Delete an observation

=cut
sub deleteObservation :Chained('observation') :PathPart('delete') :Args(1) {
	my ($self, $c, $observation_id) = @_;

	# Grab the observation by the id
	my $observation = $c->model('DB::Observation')->find(
		{
			observation_id => $observation_id
		}
	);
	
	my @images;
	  	
  	if ($c->request->method eq 'POST') {
  		foreach my $image($observation->observationimages) {
			my $path = Site->path_to(
				'root',
				 $image->filename
			)->stringify;
			push(@images,$path);
			push(@images,$path.'-original.jpg');
		}

  	}
 
  	
  	if ($c->forward('formprocess',[ 
		Site::Form::Admin::DeleteObject->new(
			schema	=>	$c->model("DB")->schema,
		),
		$observation,  
		"Observation deleted", 
		"Could not delete observation", 
		'admin/deleteobservation.tt'
	])) {
		$c->model("Image::Tiler")->deleteImages(
			@images
		);
		$c->response->redirect(
			$c->uri_for(
				$c->controller('Admin')->action_for(
					'/'
				)
			)
		)
	}

}

=head2 addImageToObservations

Add images to an organism's observation

=cut
sub addImageToObservations :Chained('base') :PathPart('add/observation/image') :Args(1) {
	my ($self, $c, $observation_id) = @_;
		
	my $imagepath = '';
	my $filenamepath = '';
	#check to see if the form has been posted
	#this is done outside of the form process method to do some extra processing (for images)
	if ($c->request->method eq 'POST') {
				
		my $organism_url = $c->model("DB::Observation")->find(
		   	{
		   		'observation_id'	=>	$observation_id
		   	}
		)->organism->organism_url;
		
		$imagepath =  Site->path_to(
				'root',
		   		'static', 
		   		'images',
		   		lc($c->config->{Site}->{organisms_singular}),
		   		$organism_url
		)->stringify;
		
		$filenamepath = '/static/images/'.lc($c->config->{Site}->{organisms_singular}).'/'.$organism_url;
		#the image is put into the parameters so that the form can process it straight from the parameters
		$c->request->params->{image} = $c->request->upload(
			'image'
		);
	} 

	$c->forward('formprocess',[ 
		Site::Form::Admin::ImageObservation->new(
			schema		=>	$c->model("DB")->schema,
			imageprocessor	=>	$c->model("Image::Tiler"),
			imageupload		=>	$c->request->params->{image} || 0,
			imagepath		=>	$imagepath,
   			filenamepath	=>	$filenamepath,
			observation_id	=>	$observation_id
		),
		$c->model('DB::ObservationImage')->new_result(
			{}
		), 
		"Image Added", 
		"Could not add image", 
		'admin/addimageobservation.tt'
	]);	
	
}

=head2 addImageToState

Add photos to an organism's state

=cut
sub addImageToState :Chained('base') :PathPart('add/state/image') :Args(1) {
	my ($self, $c, $image_id) = @_;
	
	my $image = $c->model("DB::Observationimage")->find($image_id);
	
	$c->stash(
		image => $image
	);
	
	$c->forward('formprocess_redirect',[ 
		Site::Form::Admin::ImageState->new(
			schema		=>	$c->model("DB")->schema,
			init_object => {
				image_id => $image->image_id
			},
		),
		$c->model('DB::ObservationimagesState')->new_result(
			{}
		), 
		"Images added to State", 
		"Could not add image to state", 
		'admin/addimagestate.tt',
		$c->controller('Admin')->action_for(
			'viewImagesOrganismByID'
		),
		($image->observation->organism_id)
	]);	

}

=head2 deleteImageObservations

Delete images from an observation

=cut
sub deleteImageObservations :Chained('base') :PathPart('delete/observation/image') :Args(1) {
	my ($self, $c, $image_id) = @_;

	
	my @images;
	
	#grab the image by the id
	my $image = $c->model('DB::ObservationImage')->find(
		{
			image_id => $image_id
		}
	);

  	$c->stash(
  		image => $image
  	);
  	my $file = '';
  	
  	if ($c->request->method eq 'POST') {
  		my $path = Site->path_to(
			'root',
			 $image->filename
		)->stringify;
		push(@images,$path);
		push(@images,$path.'-original.jpg');

  	}
  
  	
  	
  	if ($c->forward('formprocess',[ 
		Site::Form::Admin::DeleteObject->new(
			schema	=>	$c->model("DB")->schema,
		),
		$image,  
		"Photo Removed from Observation", 
		"Could not delete observation photo", 
		'admin/deleteimageobservation.tt'
	])) {
		$c->model("Image::Tiler")->deleteImages(
			@images
		);
		$c->response->redirect(
			$c->uri_for(
				$c->controller('Admin')->action_for(
					'/'
				)
			)
		)
	}
}

=head2 editUserByID

Edit a user

=cut
sub editUserByID :Chained('base') :PathPart('edit/user') :Args(1) {
	my ($self, $c, $user_id) = @_;
	
	my $user = $c->model('DB::User')->find(
		$user_id
	);
	
	$c->stash(
		user	=>	$user
	);
	
	$c->forward('formprocess_redirect',[ 
		Site::Form::Admin::User->new(
			schema		=>	$c->model("DB")->schema,
			init_object => {
				email => $user->email,
				status_id => $user->status_id,
				first_name => $user->first_name,
				last_name => $user->last_name,
				roles => $user->all_role_ids,
				username	=>	$user->username
			},
		),
		$user, 
		"User Updated", 
		"Could not updateuser", 
		'admin/edituserbyid.tt',
		$c->controller('Admin')->action_for(
			'viewAllUsers'
		),
	]);	
	
}

=head2 viewAllUsers

View a list of all the users

=cut
sub viewAllUsers :Chained('base') :PathPart('view/users') :Args(0) {
	my ($self, $c) = @_;
				
	$c->stash(
		template => 'admin/viewallusers.tt',
		users => [$c->model('DB::User')->search()]
	);
	
}

=head2 viewAllUsers

View a list of all the users

=cut
sub viewUserByID :Chained('base') :PathPart('view/user') :Args(1) {
	my ($self, $c, $user_id) = @_;
				
	$c->stash(
		template => 'admin/viewuserbyid.tt',
		user => $c->model('DB::User')->find(
			$user_id
		)
	);
	
}

=head2 clearCache

Clear all the caches

=cut
sub clearCache :Chained('base') :PathPart('clearcache') :Args(0) { 
	my ($self, $c) = @_;
	
	if ($c->clear_cached_page('*')) {
		$c->flash->{status_msg} = 'Cache has been cleared';
	}
	else {
		$c->flash->{status_msg} = 'Cache has NOT been cleared';
	}
	
	$c->response->redirect(
		$c->uri_for($c->controller('Admin')->action_for('index'))
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
