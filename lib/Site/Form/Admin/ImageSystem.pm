package Site::Form::Admin::ImageSystem;

use HTML::FormHandler::Moose;
extends 'Site::Form::User::UserImageObservation';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::ImageSystem - HTML FormHandler Form

=head1 DESCRIPTION

The form for system (non observational) image uploads

=head1 METHODS

build_render_list
options_image_type_id
update_model
validate_image

=cut


has '+enctype' => ( default => 'multipart/form-data');
has '+item_class' => ( default =>'Observationimage' );
has_field 'organism_id' => (type => 'Select',label => 'Organism', required => 1);

sub build_render_list {
	[
		'organism_id',
		'image',
		'image_type_id',
		'character_type_id',
		'gender_id',
		'description_id',
		'image_comments',
		'photographer',
		'copyright',
		'submit'
	]
}

before 'update_model' => sub {
	my $self = shift;
	$self->observation_id(
		$self->schema->resultset("Observation")->findSystemObservation(
			$self->field('organism_id')->value,
		)->observation_id
	);

};

=head2 options_organism_id

Sets the list of organisms for the dropdown

=cut

sub options_organism_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the organisms and sort them by their scientific name
	my @rows = $self->schema->resultset('Organism')->search( 
		{}, 
		{
			order_by => [
				'scientific_name'
			]
		}
	)->all;
	
	#return a map for use in the dropdown menu
	return [ 
		map { 
			$_->organism_id, 
			$_->scientific_name 
		} 
		@rows 
	];
}



__PACKAGE__->meta->make_immutable;
1;