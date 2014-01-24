package Site::Form::Admin::ImageObservation;

use HTML::FormHandler::Moose;
extends 'Site::Form::User::UserImageObservation';
use namespace::autoclean;

=head1 NAME

 Site::Form::Admin::ImageObservation - HTML FormHandler Form

=head1 DESCRIPTION

The form for system (non observational) image uploads

=head1 METHODS

build_render_list

=cut


has '+enctype' => ( default => 'multipart/form-data');
has '+item_class' => ( default =>'Observationimage' );

sub build_render_list {
	[
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



__PACKAGE__->meta->make_immutable;
1;