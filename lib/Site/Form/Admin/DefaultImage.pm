package Site::Form::Admin::DefaultImage;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::DefaultImage - HTML FormHandler Form

=head1 DESCRIPTION

The form for system (non observational) image uploads

=head1 METHODS

build_render_list

=cut

has '+item_class' => ( default =>'OrganismsDefaultimage' );
has_field 'image_id' => ( type => 'Select', widget => 'RadioGroup', label => 'Default Character Type Image', render_filter => sub { shift });
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

has 'character_type_id' => (
	isa				=>	'Int',
	is				=>	'rw',
);

has 'organism_id'	=>	(
	isa				=>	'Int',
	is				=>	'rw',
);


sub options_image_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	my $charactertype = $self->schema->resultset('Charactertype')->find($self->character_type_id)->character_type;
	#find all the system images
	my @rows = $self->schema->resultset('Observationimage')->searchSearchSystemImages( 
		$self->organism_id,
		$charactertype
	)->all;
	
	unshift(@rows,  $self->schema->resultset('Observationimage')->new(
		{
			image_id => 0, 
			filename => $self->schema->no_image->{$charactertype}
		}
	));
	
	#return a map for use in the dropdown menu
	return [ map { $_->image_id, create_image($_->filename)  } @rows ];

}

sub create_image {
	my ($filename) = @_;
	
	my $image = '';

	if (index($filename, ".jpg") != -1) {
    	$image =  $filename;
	} 
	else {
		$image = $filename.'/thumb.jpg';
	}
	
	return '<img src="'.$image.'" /><br />';

}

sub update_model {
	my ($self) = shift;
	
	if ($self->field('image_id')->value == 0) {
		return $self->item->delete();
	}
	else {
		return $self->schema->resultset('OrganismsDefaultimage')->update_or_create(
			{
				organism_id			=>	$self->organism_id,
				character_type_id	=>	$self->character_type_id,
				image_id			=>	$self->field('image_id')->value
			}
		)
	}
}

__PACKAGE__->meta->make_immutable;
1;