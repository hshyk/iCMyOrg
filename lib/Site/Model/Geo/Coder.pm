package Site::Model::Geo::Coder;
use strict;
use warnings;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( 
    class       => 'Site::Library::Geo::Google',
    constructor => 'new',
    
);

sub prepare_arguments {
	my ($self, $c) = @_; # $app sometimes written as $c
     return { apikey => $c->config->{GoogleMaps}->{api_key} };
}

sub mangle_arguments {
        my ($self, $args) = @_;
        return %$args; # now the args are a plain list
}

1;
