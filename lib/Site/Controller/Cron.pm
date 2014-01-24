package Site::Controller::Cron;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Site::Controller::Cron - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut


=head2 remove_sessions

Remove expired sessions from the database

=cut

sub remove_sessions : Private {
	my ( $self, $c ) = @_;
	$c->log->debug("Deleting expired sessions");
	$c->delete_expired_sessions;
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
