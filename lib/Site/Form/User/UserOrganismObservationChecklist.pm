package Site::Form::User::UserOrganismObservationChecklist;

use HTML::FormHandler::Moose;
extends 'Site::Form::User::UserOrganismObservation';
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
has_field 'organisms' => ( type => 'Repeatable');
has_field 'organisms.organism_id' => ( type => 'PrimaryKey' );
has_field 'organisms.common_name' => ( type => 'Display', set_html => 'html_common_name' );
has_field 'organisms.numberseen' => (type => 'Text', do_label	=> 0, default	=> 0, size	=>	10 );
has_field 'add' => ( type => 'Submit', value => 'Add Observations' );


has 'common_names' => (
	isa				=>	'ArrayRef',
	is				=>	'rw',
);

has 'common_name_count' =>	(
	isa		=>	'Int',
	is		=>	'rw',
	default	=>	0
);

sub html_common_name {
	my ($self, $stuff) = shift;
	
	my $common_name = @{$self->common_names}[$self->common_name_count];
	$self->common_name_count($self->common_name_count + 1); 

	return  '<br /><br />'.$common_name.'';	
}

=head2 options_status_id

Sets the dropdown options for the status of the observation

=cut
sub options_status_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Observationstatus')->search(
		{
			status_name	=> { -not_in => $self->schema->observationstatus->{review}}
		}
	)->all;
	#returns the options for the image type
	return [ map { 
					$_->status_id, 
					$_->status_name 
				 } @rows ];

}

sub init_object { 
	my $self = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Organism')->searchAllOrgansimsAlpha()->all;
	
	my $organisms = [];
	my @commonnames;
	my $count = 0;
	foreach my $organism (@rows){
		push(@$organisms, {organism_id	=> $organism->organism_id});
		$commonnames[$count] = $organism->common_name;
		$count++;
	}
	$self->common_names(\@commonnames);
	return { organisms => $organisms }
	
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
	
	# Add all the observations in a transaction
	$self->schema->txn_do( sub {
		
		foreach my $element  ($self->field('organisms')->fields) {
			
			foreach my $organism ($element ->value) {
				if ($organism->{numberseen} > 0) {
					$self->item($self->schema->resultset("Observation")->new_result(
						{}
					));
					
					$self->item->set_columns(
						{
							user_organism_id	=>	$self->schema->resultset("UsersOrganism")->update_or_create(
								{
									organism_id	=>	$organism->{organism_id},
						  			user_id		=>	$self->user_id
								}
							)->user_organism_id,
							organism_id			=>	$organism->{organism_id},
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
							number_seen			=>	$organism->{numberseen}
						}
					);
			
					#insert the record			  
					$self->item->insert();
				}
			}
		}
		 
	});
}



__PACKAGE__->meta->make_immutable;
1;