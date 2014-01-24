package Site::Controller::Review;
use Moose;
use namespace::autoclean;

use Site::Form::Review::OrganismObservation;

with 'Site::Action::FormProcess';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::Review - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub begin :Private {
	my ($self, $c) = @_;
}

=head2 access_denied

Redirects to login page when access is denied

=cut

sub access_denied : Private {
	my ( $self, $c, $action ) = @_;
	
	#redirect to the login page
	if (defined $c->request->cookie('hasloggedin') && !defined ($c->flash->{status_msg})) {
		$c->flash->{status_msg} = "Your session has timed out, please login again.";
	}
	
	$c->session->{login_redirect} = $c->request->uri;
	$c->response->redirect(
		$c->uri_for($c->controller('Authentication')->action_for('login'))
	);
}

=head2 base

The base method for administration.
All others methods are chained of this base

=cut

sub base :Chained('/') :PathPart('review') :CaptureArgs(0) {
	my ($self, $c) = @_;
	
	$c->flash->{error_msg} = "";
	$c->stash(
		cache => 0
	);
	$c->stash->{clearpages} = [];
		
}

=head2 index

The index page for administration

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	
	# If either of above don't work out, send to the login page
	$c->stash(
		template => 'review/index.tt'
	);
}

sub viewPendingObservations :Chained('base') :PathPart('view/pending') :Args(0) {
	my ($self, $c) = @_;
	
	$c->stash(
		observations => [
			$c->model('DB::Observation')->searchPendingForReviewObservations()->all
		], 
		template => 'review/viewpendingobservations.tt'
	);
}

sub viewObservationByID :Chained('base') :PathPart('view/observation') :Args(1) {
	my ($self, $c, $observation_id) = @_;
	
	my $observation = $c->model('DB::Observation')->find(
		{
			'observestatus.status_name'	=>	$c->config->{Observations}->{Status}->{Review},
			'me.observation_id'			=>	$observation_id
		},
		{
			join		=>	'observestatus'
		}
	);
	
	$c->stash(
		observation	=>	$observation,
	);

	if ($c->forward('formprocess',[
			 Site::Form::Review::OrganismObservation->new(
				schema			=>	$c->model("DB")->schema,
				user_id			=>	$c->user()->user_id,
				init_object => {
					organism_id			=>	$observation->organism_id,
				}
			),
			$observation,
			"Observation has been updated", 
			"Could not update your observation", 
			'review/viewobservation.tt',
		])) {
			$c->stash->{email} = {
	            to      => $observation->user_organism->users->email,
	            from		=>	$c->config->{Email}->{default_from},
	            subject	=> 'Your observation has been reviewed',
	            template	=> 'reviewedobservation.tt',
        	};
        	$c->forward( $c->view('Email'));
        	
        	
        	$c->response->redirect(
				$c->uri_for(
					$c->controller(
						'Review'
					)->action_for(
						'viewPendingObservations'
					)
				)
			);
		}
	
	

}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
