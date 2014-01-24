package Site::Controller::Pages;
use Moose;
use namespace::autoclean;

use Site::Form::Pages::ContactForm;

with 'Site::Action::FormProcess';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::Pages - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut



=head2 index

=cut

sub index :Path('/') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template	=>	'pages/index.tt',
		cache		=>	1
	);
}

 sub sitemap : Path('/sitemap.xml') :Args(0) {
	my ( $self, $c ) = @_;
	
	$c->stash(
		cache		=>	1
	);

    $c->res->body($c->sitemap_as_xml());
    $c->res->headers->content_type('application/xml');
}

sub robots : Path('/robots.txt') :Args(0) {
	my ( $self, $c ) = @_;
	
	$c->stash(
		cache		=>	1
	);
	
	my $text = "User-agent: *"."\n";
	$text .= "Disallow: /".lc($c->config->{Site}->{organisms})."/user/" ."\n";
	$text .= "Disallow: /".lc($c->config->{Site}->{organisms})."/lifelist/"."\n";
	$text .= "Disallow: /".lc($c->config->{Site}->{organisms})."/observation/"."\n";
	
	
	$c->res->body($text);
	 $c->res->headers->content_type('text/plain');	
	
}



sub changeLayout :Path('/layout') :Args(1) {
	my ( $self, $c, $type ) = @_;
	
	my @layouts = ('desktop', 'mobile', 'tablet');
	
	if(grep $_ eq $type, @layouts)
	{
		$c->response->cookies->{'layout'} =
		{ 
    		value => $type,
    		expires => '+1h'
		};
	
		$c->session->{layout} = $type;
		$c->stash(
			layout => $type,
			cache => 0
		);
				
		$c->response->redirect(
			$c->uri_for(
				$c->controller('Pages')->action_for('index'),
				'',
				'',
				{'layout' => $type}
			),
		);
	}
	else {
		$c->response->redirect(
			$c->uri_for(
				$c->controller('Pages')->action_for('index'),
			),
		);
	}
}

sub about :Path('/about') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template => 'pages/about.tt',
		usecache => 1
	);
}

sub instructions :Path('/instructions') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template => 'pages/instructions.tt'
	);
}

sub howtoUse :Path('/instructions/howtouse') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template => 'pages/howtouse.tt',
		usecache => 1
	);
}

sub instructionsDesktop :Path('/instructions/desktop') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template => 'pages/tipsdesktop.tt',
		usecache => 1
	);
}

sub instructionsiOS :Path('/instructions/ios') :Args(0) {
    my ( $self, $c ) = @_;

	$c->stash(
		template => 'pages/tipsios.tt',
		usecache => 1
	);
}

sub instructionsAndroid :Path('/instructions/android') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;

	$c->stash(
		template => 'pages/tipsandroid.tt',
		usecache => 1
	);
}


sub contactUs :Path('/contact') :Args(0) :Sitemap {
    my ( $self, $c ) = @_;
    
    my $email;
    my $first_name;
    my $last_name;
    
    if ($c->user()) {
    	$email = $c->user()->email;
    	$first_name = $c->user()->first_name;
    	$last_name = $c->user()->last_name;
    	
    }
    $c->stash(usecache => 1);
   $c->forward('formprocess',[
		Site::Form::Pages::ContactForm->new(
			init_object => {
				email		=>	$email,
				first_name	=>	$first_name,
				last_name	=>	$last_name
			}
		),
		$c->model('DB::Contactform')->new_result(
			{}
		),
		"Thank you for contacting us!", 
		"There are errors in your submission", 
		'pages/contactform.tt',
	]);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
