package Site::Form::Review::OrganismObservation;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;



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

has_field 'organism_id'			=> (type => 'Select', label => 'User Selected', required => 1);
has_field 'review_comments'  => (type => 'TextArea', label => 'Comments for the Submitter', cols  => 40 );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

has 'user_id'	=>	(
	is	=>	'rw',
	isa	=>	'Int'
);


=head2 update_model

Override the updating of the model

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
					$_->common_name.' - '.$_->scientific_name 
				 } @rows ];

}


sub update_model {
	my $self = shift;

	
	my $oldname = $self->item->organism->common_name;
	
	my $userorganism = undef;
	
	if (defined $self->item->user_organism) {
		$userorganism = $self->item->user_organism;
	}
	
	if ($self->item->organism_id != $self->field('organism_id')->value) {
		$self->field('review_comments')->value('Observation updated from '.$oldname.' to '.$self->schema->resultset('Organism')->find(
			{
				organism_id	=>	$self->field('organism_id')->value,
			}
		)->common_name.'<br /> '.$self->field('review_comments')->value);
	}
	else {
		$self->field('review_comments')->value('Correctly selected'.'<br /> '.$self->field('review_comments')->value);
	}
	
	#set the fields	
	$self->item->set_columns(
		{
			organism_id	=>	$self->field('organism_id')->value,
			user_organism_id	=>	$self->schema->resultset("UsersOrganism")->update_or_create(
				{
					organism_id	=>	$self->field('organism_id')->value,
		  			user_id		=>	$self->item->user_organism->user_id
				}
			)->user_organism_id,
			status_id	=>	$self->schema->resultset('Observationstatus')->find(
				{
					status_name	=> $self->schema->observationstatus->{published}
				}
			)->status_id
		}
	);
	

	#insert the record			  
	$self->item->insert_or_update();
	
	$self->item->create_related(
		'observationreviews', {
			comments	=>	$self->field('review_comments')->value,
			user_changed	=>	$self->user_id
		}
	);
	
	if (defined $userorganism && $userorganism->observations->count() < 1) {
		$userorganism->delete();
	}
}



__PACKAGE__->meta->make_immutable;
1;