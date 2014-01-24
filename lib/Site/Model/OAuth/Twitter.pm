package Site::Model::OAuth::Twitter;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( 
    class       => 'Site::Library::OAuth::Twitter',
    constructor => 'new',
    
);

sub prepare_arguments {
	my ($self, $c) = @_;
   
    return {
    	'consumer_key'		=>	$c->config->{OAuth}->{twitter}->{consumer_key},
    	'consumer_secret'	=>	$c->config->{OAuth}->{twitter}->{consumer_secret},
    	'token_url'			=>	$c->config->{Auth}->{Config}->{Twitter}->{OAuth_Token_URL},
    	'access_token_url'	=>	$c->config->{Auth}->{Config}->{Twitter}->{Access_Token_URL},
    	'request_token_url'	=>	$c->config->{Auth}->{Config}->{Twitter}->{Request_Token_URL},
    };
}

=head1 NAME

Site::Model::OAuth::Twitter - Catalyst Model

=head1 DESCRIPTION

Catalyst Model - Twitter Authentication

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
