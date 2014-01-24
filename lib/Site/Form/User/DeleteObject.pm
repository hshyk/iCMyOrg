package Site::Form::User::DeleteObject;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::User::DeleteObject - HTML FormHandler Form

=head1 DESCRIPTION

Delete an object

=head1 METHODS

update_model

=cut


has '+item_class' => ( default =>'Object' );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );


=head2 update_model

Override the updating of the model

=cut

sub update_model {
	my $self = shift;
	
	$self->item->delete();
	
}

__PACKAGE__->meta->make_immutable;
1;