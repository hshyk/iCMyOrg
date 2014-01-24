package Site::Model::Image::Tiler;
use strict;
use warnings;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( 
    class       => 'Site::Library::Image::Tiler',
    constructor => 'new',
);

sub prepare_arguments {
	my ($self, $c) = @_;
   
    return {
    	'directory'	=>	$c->config->{uploadtmp},
    	'convert'	=>	$c->config->{ImageMagick}->{system_convert},
    	'mogrify'	=>	$c->config->{ImageMagick}->{system_mogrify},
    	'separator'	=>	$c->config->{ImageMagick}->{file_separator}
    };
}



=head1 NAME

Site::Model::Image::Tiler - Catalyst Model

=head1 DESCRIPTION

Catalyst Model - Create tiles of images for Google Maps

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
