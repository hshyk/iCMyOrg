package Site::Model::Geo::IP;
use strict;
use warnings;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( 
    class       => 'Site::Library::Geo::GeoCity',
    constructor => 'new',
    
);

sub prepare_arguments {
	my ($self, $c) = @_; # $app sometimes written as $c
     return { Site->path_to(
			'lib',
	   		'site', 
	   		'library', 
	   		'geo', 
	   		'GeoLiteCity.dat'
   		)->stringify };
}

sub mangle_arguments {
        my ($self, $args) = @_;
        return %$args; # now the args are a plain list
}

1;
