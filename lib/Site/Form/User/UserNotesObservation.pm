package Site::Form::User::UserNotesObservation;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::User::UserNotesObservation - HTML FormHandler Form

=head1 DESCRIPTION

Add notes to a observation for a user

=head1 METHODS

update_model

=cut


has '+item_class' => ( default =>'Observationnote' );
has_field 'notes' => (type => 'TextArea',label => 'Add Notes', minlength => 1, maxlength => 150, required => 1, rows => 10, cols =>40);
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

has 'observation_id' => (
	isa				=>	'Int',
	is				=>	'rw',
);

before 'update_model' => sub {
	my $self = shift;

	$self->item->observation_id(
		$self->observation_id
	);

};

__PACKAGE__->meta->make_immutable;
1;