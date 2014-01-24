package Site::Model::Device::Browser;
use strict;
use warnings;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config( 
    class       => 'HTTP::BrowserDetect',
    constructor => 'new',
    
);

sub prepare_arguments {
	my ($self, $c) = @_; # $app sometimes written as $c
    return  {$c->request->user_agent};
}

sub mangle_arguments {
        my ($self, $args) = @_;
        return %$args; # now the args are a plain list
}


1;
