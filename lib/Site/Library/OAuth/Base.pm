package Site::Library::OAuth::Base;
use Moose;
use namespace::autoclean;
use Net::OAuth;
use LWP::UserAgent;
use Data::Random;


$ENV{PERL_NET_HTTPS_SSL_SOCKET_CLASS} = "Net::SSL";
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;


sub oauth_request {
	my $self = shift;
	my $i = {
		'type'				=>	'',
		'extra_params'		=>	{},
		'token'				=>	'',
		'token_secret'		=>	'',
		'consumer_key'		=>	'',
		'consumer_secret'	=>	'',
		'verifier'			=>	'',
		'request_url'		=>	'',
		'callback'			=>	'',
		'method'			=> 'POST',
		@_,
	};

	# Set the request information
	my $request = Net::OAuth->request(
		$i->{'type'}
	)->new(
		consumer_key		=>	$i->{'consumer_key'},
		consumer_secret		=>	$i->{'consumer_secret'},
		token				=>	$i->{'token'},
		token_secret		=>	$i->{'token_secret'},
		request_url			=>	$i->{'request_url'},
		request_method		=>	$i->{'method'},
		signature_method	=>	'HMAC-SHA1',
		timestamp			=>	time,
		verifier			=>	$i->{'verifier'},
		nonce				=>	join('',Data::Random::rand_chars(size=>16, set=>'alphanumeric')),
		extra_params		=>	$i->{'extra_params'},
		callback			=>	$i->{'callback'}
	);
	
	# Sign the request
	$request->sign;

	# Create the user agent
	my $ua = LWP::UserAgent->new;
	
	
	my $response = '';
	
	# Depending on the type of method will either do a GET or POST call
	if ($i->{'method'} eq 'GET') {
		$response = $ua->get(
			$request->to_url
		);
	}
	else {
		$response = $ua->post(
			$request->to_url
		);
	}

	return $response;	
}

=head1 NAME

Site::Model::OAuth::Base - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
