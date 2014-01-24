package Site::Model::OAuth::Facebook;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config( 
    class       => 'Site::Library::OAuth::Facebook',
    constructor => 'new',
    
);

sub prepare_arguments {
	my ($self, $c) = @_; # $app sometimes written as $c
     
    return {
     	'app_id'			=>	$c->config->{OAuth}->{facebook}->{app_id},
    	'consumer_key'		=>	$c->config->{OAuth}->{facebook}->{consumer_key},
    	'consumer_secret'	=>	$c->config->{OAuth}->{facebook}->{consumer_secret},
      	'access_token_url'	=>	$c->config->{Auth}->{Config}->{Facebook}->{Access_Token_URL},
    	'graph_url'			=>	$c->config->{Auth}->{Config}->{Facebook}->{Graph_URL},
    	'redirect_url'		=>	$c->config->{Auth}->{Config}->{Facebook}->{Redirect_URL},
    };
}

=head1 NAME

Site::Model::OAuth::Facebook - Catalyst Model

=head1 DESCRIPTION

Catalyst Model - Facebook Authentication

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
