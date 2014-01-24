package Site::Controller::Root;
use Moose;
use namespace::autoclean;
use DateTime;
use feature qw(switch);

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Site::Controller::Root - Root Controller for Site

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
   	
   	#when the path is not found it should show the 404 page
   	$c->stash( 
		template => 'pages/404.tt'
   	 );
   	
   	#set the status code to 404
    $c->response->status(
    	404
    );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
	my ( $self, $c ) = @_;

	my $replace = lc(Site->config->{Site}->{organisms});
	my $path = $c->request->path;
	$path =~ s/organisms/$replace/i;
	$c->request->path($path);
	
	$c->stash(meta => {});
	
	my $cookielayout = '';
	
	if (defined $c->request->cookie('layout')) {
		$cookielayout = $c->request->cookie('layout')->value;
	}

	#check to see if it is an Ajax call
	if ($c->stash->{isajax}) {	
		#unset the Ajax flag
		delete $c->stash->{isajax};
		$c->forward('View::JSON');
	}
	elsif (
		(
			!(grep $_ eq $c->action->namespace, (qw/css js/)) && 
 			!(defined $c->response->redirect())
 		)
 		&& 
 		$c->config->{Layout}->{kiosk}->{enabled} eq 1 
 		&&
 		grep $_ eq $c->request->address, split(/,/, $c->config->{Layout}->{kiosk}->{ip})
	) {
		$c->stash->{isMobile} = 1;
	    $c->stash->{layout} = 'kiosk';
	    $c->stash->{imagetouse} = 'web';
		$c->forward('View::HTMLKiosk');
	}
	#check to see if the browser is mobile, it is not calling the CSS or Javascript and it is not redirecting
 	#elsif ($browser->mobile() && !(grep $_ eq $c->action->namespace, (qw/css js/)) && !(defined $c->response->redirect()))  {
 	elsif (
 		!(grep $_ eq $c->action->namespace, (qw/css js/)) && 
 		!(defined $c->response->redirect()) 
 	) {		
		
		#$c->stash->{browser} = $browser;
	 		
	 	given($cookielayout) {
			when ('desktop') { 
				$c->stash->{imagetouse} = 'web';
				$c->stash->{layout} = 'desktop';
		 	 	}
		   	when ('tablet') { 
				$c->stash->{isMobile} = 1;
				$c->stash->{layout} = 'mobile';
				$c->stash->{imagetouse} = 'web';
				$c->forward('View::HTMLTablet');
		   	}
		   	when ('mobile') { 
		   		$c->stash->{isMobile} = 1;
		   		$c->stash->{layout} = 'mobile';
		   		$c->stash->{imagetouse} = 'mobile';
		   		$c->forward('View::HTMLMobile');	
		   		
		   	}
		   	default { 
		   		if ($c->model("Device::Type")->isTablet()) {
		   			$c->stash->{isMobile} = 1;
		   			$c->stash->{layout} = 'mobile';
		   			$c->stash->{imagetouse} = 'web';
	    			$c->forward('View::HTMLTablet');
	    		}
	    		elsif ($c->model("Device::Type")->isMobile()) {
	    			$c->stash->{isMobile} = 1;
	    			$c->stash->{layout} = 'mobile';
	    			$c->stash->{imagetouse} = 'mobile';
	    			$c->forward('View::HTMLMobile');		
	    		}
	    		else {
	    			$c->stash->{imagetouse} = 'web';
	    			$c->stash->{layout} = 'desktop'
	    		}
		   	}
		}   	    	
  	}
		
	my $date = DateTime->now;
	my $expiredate = $date->add( days => 1 );
	my $expires;
	   
	if (grep $_ eq $c->action->namespace, (qw/css js/)) {
		$expires = 18000;
	}
	else {
		$expires = 0;
	}
   		
	$c->cache_page(
		last_modified => $date->day_abbr.', '.$date->day.' '.$date->month_abbr.' '.$date->year.' '.$date->hms.' GMT',
	    cache_seconds   => 24 * 24 * 60,
	    expires         => $expires,
    );	
		
    foreach my $page(@{$c->stash->{clearpages}}) {
    	$c->clear_cached_page($page);
    	$c->log->debug("Clearing page:".$page);		
    }
}


=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
