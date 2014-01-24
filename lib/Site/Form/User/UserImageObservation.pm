package Site::Form::User::UserImageObservation;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::User::UserImageObservation - HTML FormHandler Form

=head1 DESCRIPTION

The form for image uploads

=head1 METHODS

options_image_type_id
update_model
image_upload

=cut



has '+enctype' => ( default => 'multipart/form-data');
has '+item_class' => ( default =>'Observationimage' );
has_field 'image' => ( type => 'Upload', label => 'Upload Image',  messages => { max_size => 'This file is too big.  Please keep file sizes under 5MB' }, max_size => 5000000, min_size => undef, required => 1,);
has_field 'image_type_id' => (type => 'Select',label => 'Image Type', required => 1);
has_field 'character_type_id'  => (type => 'Select', label => 'Life Stage', required => 0 );
has_field 'gender_id'  => (type => 'Select', label => 'Gender', required => 0, empty_select => '---Select a Gender---' );
has_field 'description_id'  => (type => 'Select', label => 'What is being shown in the photo?', required => 0, , empty_select => '---Select description---' );
has_field 'image_comments'  => (type => 'TextArea', label => 'Comments about this photo(s)', size => 60, cols => 40  );
has_field 'photographer'  => (type => 'Text', label => 'Photographer', required => 0 );
has_field 'copyright'  => (type => 'Text', label => 'Copyright', required => 0 );

has 'imageprocessor' => (
	isa				=>	'Object | Int',
	is				=>	'ro',
	default			=>	0
);

has 'imageupload' => (
	isa				=>	'Object | Int',
	is				=>	'ro',
	default			=>	0
);

has 'imagepath'	=>	(
	isa				=>	'Str',
	is				=>	'ro',
);

has 'filenamepath'	=>	(
	isa				=>	'Str',
	is				=>	'ro',
);

has 'observation_id'	=> (
	isa				=>	'Int',
	is				=>	'rw',
);



has_field 'submit' => ( type => 'Submit', value => 'Submit' );


=head2 options_image_type_id

Sets the dropdown options for the imagetype

=cut
sub options_image_type_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Observationimagetype')->search(
		{}
	)->all;
	
	#returns the options for the image type
	return [ map { 
					$_->image_type_id, 
					$_->image_type_name 
				 } @rows ];

}

=head2 options_image_type_id

Sets the dropdown options for the imagetype

=cut
sub options_character_type_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Charactertype')->searchDisplay();
	#returns the options for the image type
	return [ map { 
					$_->character_type_id, 
					$_->character_type 
				 } @rows ];

}

=head2 options_image_type_id

Sets the dropdown options for the imagetype

=cut
sub options_gender_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Gender')->search();
	#returns the options for the image type
	return [ map { 
					$_->gender_id, 
					$_->gender_name 
				 } @rows ];

}

=head2 options_image_type_id

Sets the dropdown options for the imagetype

=cut
sub options_description_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Observationimagedescriptiontype')->search();
	#returns the options for the image type
	return [ map { 
					$_->description_id, 
					$_->description_name 
				 } @rows ];

}

=head2 update_model

Overrides the function for updating the model

=cut
sub update_model {
	my $self = shift;
	
	# this is for updating an already tiled image
	if (!$self->imageupload) {
		# normal functionality for updating
		return $self->SUPER::update_model;
	}
	
	if (!($self->imageupload->tempname eq undef)) {
		 
		my @allimages;
		$self->imageprocessor->checkFileExists($self->imagepath, $self->imageupload->tempname);
		if ($self->imageprocessor->isZip($self->imageupload)){
			@allimages = $self->imageprocessor->saveImageThumbnailTileZip($self->imagepath, $self->imageupload->tempname );
		}
		else {
	   		push (@allimages, $self->imageprocessor->saveImageThumbnailTile($self->imagepath, $self->imageupload->tempname));
		}
		
		foreach my $randfile (@allimages) {
	  		#set the column values
	  		#$self->item->set_columns(
	  		my $row =
				{
		  			observation_id => $self->observation_id, 
		  			filename =>$self->filenamepath.'/'.$randfile,
		  			image_type_id => $self->field('image_type_id')->value, 
		     		photographer => $self->field('photographer')->value,
		     		copyright	=>	$self->field('copyright')->value,
		     		character_type_id =>   $self->field('character_type_id')->value,
		     		description_id =>   $self->field('description_id')->value,
		     		image_comments =>   $self->field('image_comments')->value,
		     		gender_id =>   $self->field('gender_id')->value,
	  			};
	
            $self->resultset->create( $row );
		}	
   	} 
}

sub validate_image {
	my $self = shift;
	return unless ($self->imageprocessor eq 0) || ($self->imageprocessor->validateFileType($self->imageupload->tempname, 1) eq 0);
	
	$self->field('image')->add_error(
		'The file uploaded is not a valid image or zip file'
	);
}




__PACKAGE__->meta->make_immutable;
1;