package Site::Model::Device::Type;
use strict;
use warnings;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( 
    class       => 'Site::Library::Device::Type',
    constructor => 'new',
    
);

sub prepare_arguments {
	my ($self, $c) = @_; # $app sometimes written as $c
    return  {'headers' => $c->request->headers};
}



1;
