package Site::Form::Admin::ImageHost;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::ImageHost - HTML FormHandler Form

=head1 DESCRIPTION

The form for image uploads

=head1 METHODS

options_image_type_id
update_model

=cut


has '+enctype' => ( default => 'multipart/form-data');
has '+item_class' => ( default =>'Hostimage' );
has_field 'host_id' => (type => 'Select',label => 'Host', required => 1);
has_field 'image' => ( type => 'Upload', label => 'Upload Image', max_size => undef, min_size => undef, required => 1 );
has_field 'image_type_id' => (type => 'Select',label => 'Image Type', required => 1);
has_field 'photographer'  => (type => 'Text', label => 'Photographer', required => 0 );
has_field 'copyright'  => (type => 'Text', label => 'Copyright', required => 0 );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

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

=head2 options_image_type_id

Sets the dropdown options for the imagetype

=cut

sub options_host_id{
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Host')->search(
		{
			scientific_name => { '!=' => undef}
		},
		{
			order_by => 'scientific_name'
		}
		
	)->all;
	
	#returns the options for the image type
	return [ map { 
			$_->host_id, 
			$_->scientific_name 
		} @rows ];

}

sub options_image_type_id {
	my ($self) = shift;
	
	return unless $self->schema;
	
	#get all of the image types
	my @rows = $self->schema->resultset('Hostimagetype')->search(
		{}
	)->all;
	#returns the options for the image type
	return [ map { 
					$_->image_type_id, 
					$_->image_type_name 
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
		  			host_id => $self->field('host_id')->value, 
		  			filename =>$self->filenamepath.'/'.$randfile,
		  			image_type_id => $self->field('image_type_id')->value, 
		     		photographer => $self->field('photographer')->value,
		     		copyright	=>	$self->field('copyright')->value,	
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