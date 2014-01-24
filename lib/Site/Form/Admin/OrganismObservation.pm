package Site::Form::Admin::OrganismObservation;

use HTML::FormHandler::Moose;
extends 'Site::Form::User::UserOrganismObservation';
use namespace::autoclean;
use DateTime;
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


has '+item_class' => ( default =>'Observation' );

sub build_render_list {
	[
		'organism_id',
		'observation_type_id',
		'source',
		'observed_location',
		'address',
		'location_detail',
		'day',
		'month',
		'year',
		'status_id',
		'latitude',
		'longitude',
		'number_seen',
		'submit'
	]
}

has_field 'organism_id' => (type => 'Select',label => 'Organism', required => 1);
has_field 'observation_type_id'  => (type => 'Select',  label => 'Observation Type', required => 1 );
has_field 'source' =>(type => 'Text',label => 'Source', minlength => 1, maxlength => 140, required => 0,  size => 40);



=head2 options_year

Set the dropdown options for the years

=cut

sub options_year {
	my ($self) = shift;
		
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);
	
	my @rows = reverse($year+1900-100 ..$year+1900);
	
	return [ map { $_, $_ } @rows ];
		
}

=head2 options_organism_id

Sets the list of organisms for the dropdown

=cut

sub options_observation_type_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the organisms and sort them by their scientific name
	my @rows = $self->schema->resultset('Observationtype')->searchDisplay()->all;
	
	#return a map for use in the dropdown menu
	return [ 
		map { 
			$_->observation_type_id, 
			$_->observation_name 
		} 
		@rows 
	];
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
					
	#set the fields	
	$self->item->set_columns(
		{
			user_organism_id	=>	undef,
			organism_id			=>	$self->field('organism_id')->value,
			observation_type_id	=>	$self->field('observation_type_id')->value,
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
}



__PACKAGE__->meta->make_immutable;
1;