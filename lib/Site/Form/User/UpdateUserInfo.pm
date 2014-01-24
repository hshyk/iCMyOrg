package Site::Form::User::UpdateUserInfo;

use HTML::FormHandler::Moose;
extends 'Site::Form::Base::User';
use namespace::autoclean;

=head1 NAME

Site::Form::UpdateUserInfo - HTML FormHandler Form

=head1 DESCRIPTION

Update the user information

=head1 METHODS

=cut

has '+item_class' => ( default =>'User' );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

__PACKAGE__->meta->make_immutable;
1;