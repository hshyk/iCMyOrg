package Site::Library::OAuth::Facebook;
use Moose;
use namespace::autoclean;

use JSON;
extends 'Site::Library::OAuth::Base';

sub new {
	my ($class, $args) = @_;

    my $self  = {
    	app_id				=>	$args->{app_id},
    	consumer_key		=>	$args->{consumer_key},
    	consumer_secret		=>	$args->{consumer_secret},
    	access_token_url	=>	$args->{access_token_url},
    	graph_url			=>	$args->{graph_url},
    	redirect_url		=>	$args->{redirect_url},
    	
    };
    bless $self, $class;
}

sub request {
	my ($self, $code, $redirect) = @_;

	my $response = $self->oauth_request(
		'consumer_key' => $self->{consumer_key},
		'consumer_secret' => $self->{consumer_secret},
		'request_url' =>$self->{access_token_url},
		'extra_params' => { 
			client_id => 	$self->{app_id},
			redirect_uri => $redirect,
			client_secret => $self->{consumer_secret},
			code => $code,
		},
	);

	#if the OAuth response was successful call to grab the 
	if ($response->is_success)
	{
		#create a user agent to be able to grab information about the user from Faceboook
		my $ua = LWP::UserAgent->new;
		my $graph = $ua->get($self->{graph_url}.$response->content);

		#get the user data (from JSON format)
		return from_json($graph->{'_content'});
	}
	else {
		return 0;
	}
}

sub redirect_url {
	my ($self, $redirect, $state, $touch) = @_;
	
	my $display = '';
	
	if ($touch) {
		$display = '&display=touch';
	}
	return $self->{redirect_url}.$self->{app_id}."&redirect_uri=".$redirect."&state=".$state.$display;
}

=head1 NAME

Site::Model::OAuth::Facebook - Catalyst Model

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
