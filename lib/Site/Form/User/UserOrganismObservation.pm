package Site::Form::User::UserOrganismObservation;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
use DateTime;
use Date::Calc qw(:all);
use feature qw(switch);


=head1 NAME

Site::Form::User::AddUserOrganismObservation - HTML FormHandler Form

=head1 DESCRIPTION

Tag an observation for the user

=head1 METHODS

options_month
options_day
options_month
default_month
default_day
validate
update_model

=cut


has '+item_class'				=> ( default =>'Observation' );
has_field 'organism_id'			=> (type => 'Select', label => 'What did you observe?', required => 1);
has_field 'observed_location'	=> (
	type			=>	'Select', 
	label			=>	'How would you like to add the location to this observation?',
	empty_select	=>	'-----Select-----',
	options 		=>	[
		{ 
			value	=>	'current', 
			label	=>	'Use my current location'
		}, 
		{ 
			value	=>	'address', 
			label	=>	'Type in an address'
		},
		{ 
			value	=>	'map', 
			label	=>	'Make a selection on the map'
		},
		{
			value	=>	'previous',
			label	=>	'Use a previously added location'
		} 
	],
	required		=>	1
);
has_field 'address'				=>	(type => 'Text',label => 'Address', minlength => 5, maxlength => 140, required => 0,  size => 40);
has_field 'previous_locations'	=>	(type => 'Select',label => 'Previously added locations', required => 0);
has_field 'location_detail'		=>	(type => 'Text',label => 'Location description', default=>'New Observation', minlength => 5, maxlength => 140, required => 1,  size => 40);
has_field 'number_seen'			=>	(type => 'Text',label => 'Number Observed', default=>'1', maxlength => 3, required => 1,  size => 40);
has_field 'day'  				=>	(type => 'Select',  label => 'Day Observed', required => 1 );
has_field 'month'				=>	(type => 'Select',  label => 'Month Observed', required => 1 );
has_field 'year'  => (type => 'Select',  label => 'Year Observed', required => 1 );
has_field 'status_id'  => (type => 'Select',  label => 'Status of this Observation', required => 1 );
has_field 'review_comments'  => (type => 'TextArea', label => 'Comments for the Reviewer', cols  => 40 );
has_field 'latitude' => (type => 'Hidden');
has_field 'longitude' => (type => 'Hidden');
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

has 'user_id'	=>	(
	is	=>	'rw',
	isa	=>	'Int'
);

has 'lat'	=>	(
	is	=>	'rw',
	isa	=>	'Str',
	default	=>	''
);

has 'long'	=>	(
	is	=>	'rw',
	isa	=>	'Str',
	default	=>	''
);

has 'city'	=>	(
	is	=>	'rw',
	isa	=>	'Str',
	default	=>	''
);

has 'geo' => (
      is  => 'rw',
      isa => 'Int',
      default	=> 0
);


=head2 options_organism_id

Sets the dropdown options for all of the organisms

=cut
sub options_organism_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Organism')->searchAllOrgansimsAlpha()->all;
	#returns the options for the image type
	return [ map { 
					$_->organism_id, 
					$_->common_name 
				 } @rows ];

}

=head2 options_previous_locations

Sets the dropdown options for the status of the observation

=cut
sub options_previous_locations {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Observation')->searchPreviouslyAddedObservations($self->user_id)->all;
	#returns the options for the image type
	return [ map { 
					$_->observation_id, 
					$_->location_detail.' - '.$_->date_observed_display 
				 } @rows ];

}

=head2 options_status_id

Sets the dropdown options for the status of the observation

=cut
sub options_status_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Observationstatus')->search()->all;
	#returns the options for the image type
	return [ map { 
					$_->status_id, 
					$_->status_name 
				 } @rows ];

}

=head2 options_day

Set the dropdown options for the days

=cut

sub options_day {
	my ($self) = shift;
	
	my @rows  = (1  .. 31);

	return [ map { $_, $_ } @rows ];
	
}

=head2 options_month

Set the dropdown options for the months

=cut

sub options_month {
	my ($self) = shift;

	my @rows =	(	
					1	=>	'January',
					2	=> 	'February',
					3 	=>	'March',
					4	=>	'April',
					5	=>	'May',
					6	=>	'June',
					7	=>	'July',
					8	=>	'August',
					9	=>	'September',
					10	=>	'October',
					11	=>	'November',
					12	=>	'December' 
				);

	return [ map { $_ } @rows ];
}

=head2 options_year

Set the dropdown options for the years

=cut

sub options_year {
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);
	
	my @rows = reverse($year+1900-2 ..$year+1900);
	
	return [ map { $_, $_ } @rows ];
		
}

=head2 default_day

Get the current date and set the day field

=cut

sub default_day {
	
	#get the local time
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);
	
	#return the current date
	return $day;
}

=head2 default_month

Get the current date and set the month field

=cut

sub default_month {
	
	#get the local time
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);
	
	#return the current month
	return $month+1;
}


sub validate {
	my ($self) = shift;

	given ($self->field('observed_location')->value) {
		when ("current") {
			if ($self->field('latitude')->value eq "" || $self->field('longitude')->value eq "") {
				$self->add_form_error("We are not a able to determine the location given");
			}
		}
		when ("map") {
			if ($self->field('latitude')->value eq "" || $self->field('longitude')->value eq "") {
				$self->add_form_error("We are not a able to determine the location given");

			}
		}
		when ("address") {
			if ($self->field('address')->value eq "") {
				$self->add_form_error("Please enter an address");
			}
		}
		when ("previous") {
			if ($self->field('previous_locations')->value eq "") {
				$self->add_form_error("Please select a previously submitted location");
			}
			
			my $prev_observe = $self->schema->resultset("Observation")->find(
				{
					observation_id	=>	$self->field('previous_locations')->value
				}
			);
			
			if (!defined $prev_observe) {
				$self->add_form_error("There was an error looking up your previously submitted observation");
			}
			else{
				$self->lat($prev_observe->latitude);
				$self->long($prev_observe->longitude);
				if ($self->field('location_detail')->value eq $self->field('location_detail')->default) {
					$self->field('location_detail')->value($prev_observe->location_detail);
				}
				
			}
		}
	}
	
	if ($self->field('location_detail')->value eq '') {
		$self->add_form_error("The location description must not be empty")
	}

	if (!$self->geo && $self->field('observed_location')->value ne "previous" ) {
		$self->add_form_error("The location provided your provided is either outside of the area or invalid");	
		
	}
	

	if (!check_date($self->field('year')->value,$self->field('month')->value, $self->field('day')->value)) {
		$self->add_form_error("The date is not valid");	
	}
	elsif (Date_to_Days($self->field('year')->value,$self->field('month')->value, $self->field('day')->value) >  Date_to_Days(Today())) {
		$self->add_form_error("The date cannot be in the future");	
	}
	
	
}

=head2 update_model

Override the updating of the model

=cut

sub update_model {
	my $self = shift;

	if ($self->field('location_detail')->value eq $self->field('location_detail')->default) {
		if ($self->field('address')->value ne '') {
			$self->field('location_detail')->value($self->field('location_detail')->value.' in '.$self->field('address')->value);
		}
		else {
			$self->field('location_detail')->value($self->field('location_detail')->value.' in '.$self->city);
		}	
	}
	my $userorganism = undef;
	
	if (defined $self->item->user_organism) {
		$userorganism = $self->item->user_organism;
	}
	#set the fields	
	$self->item->set_columns(
		{
			user_organism_id	=>	$self->schema->resultset("UsersOrganism")->update_or_create(
				{
					organism_id	=>	$self->field('organism_id')->value,
		  			user_id		=>	$self->user_id
				}
			)->user_organism_id,
			organism_id			=>	$self->field('organism_id')->value,
			observation_type_id	=>	$self->schema->resultset("Observationtype")->find(
				{
					observation_name	=>	$self->schema->userobservation
				}
			)->observation_type_id,
			latitude			=>	$self->lat,
			longitude			=>	$self->long,
			date_observed		=>	$self->field('year')->value."-".$self->field('month')->value."-".$self->field('day')->value,
			status_id			=>	$self->field('status_id')->value,
			location_detail		=>	$self->field('location_detail')->value,
			number_seen			=>	$self->field('number_seen')->value
		}
	);
	
	#insert the record			  
	$self->item->insert_or_update();
	
	if ($self->field('status_id')->value eq $self->schema->resultset("Observationstatus")->find(
		{
			status_name	=>	$self->schema->observationstatus->{review}
		}
	)->status_id &&  $self->field('review_comments')->value ne '') {
		$self->item->create_related(
			'observationreviews', {
				comments		=> $self->field('review_comments')->value,
				user_changed	=>	$self->user_id
			}
		);
	}
	
	if (defined $userorganism && $userorganism->observations->count() < 1) {
		$userorganism->delete();
	}
}



__PACKAGE__->meta->make_immutable;
1;