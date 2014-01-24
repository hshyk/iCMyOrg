package Site::Library::OAuth::Twitter;
use Moose;
use namespace::autoclean;

use Net::OAuth;
extends 'Site::Library::OAuth::Base';

sub new {
	my ($class, $args) = @_;

    my $self  = {
    	token_url			=> $args->{token_url},
    	access_token_url	=>	$args->{access_token_url},
    	request_token_url	=>	$args->{request_token_url},
    	consumer_key		=>	$args->{consumer_key},
    	consumer_secret		=>	$args->{consumer_secret},
    };
    bless $self, $class;
}

sub request_token {
	my ( $self, $redirect ) = @_;
	
	$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;
	
	my $response = $self->oauth_request(
		'type' => 'request_token',
		'request_url' => $self->{request_token_url},
		'token' => '',
		'token_secret' => '',
		'consumer_key' => $self->{consumer_key},
		'consumer_secret' => $self->{consumer_secret},
		'callback' =>  $redirect,
	); 
	
	#we now have a request token, forward the user to see if they need to authorize the application
	if ($response->is_success) {
		return Net::OAuth->response('request_token')->from_post_body(
			$response->content
		);
	}
	else {
		return 0;
	}	
}


sub request_user {
	my ( $self, $token, $token_secret, $verifier) = @_;
	
	$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A; 

	my $response = $self->oauth_request(
		'type' => 'access_token',
		'request_url' => $self->{access_token_url},
		'token' => $token,
		'token_secret' => $token_secret,
		'consumer_key' => $self->{consumer_key},
		'consumer_secret' => $self->{consumer_secret},
		'verifier' => $verifier,
	);
	
	#if the tokens are valid login or create the OAuth user		
	if ($response->is_success) {
			#get the user info from the post body content
		return Net::OAuth->response('access_token')->from_post_body(
			$response->content
		);
	}
	else {
		return 0;
	}
}

sub redirect_url {
	my ($self, $token) = @_;
	
	return $self->{token_url}.$token;
}
=head1 NAME

Site::Model::OAuth::Twitter - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

1;
