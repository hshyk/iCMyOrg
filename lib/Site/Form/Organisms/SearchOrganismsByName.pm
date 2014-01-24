package Site::Form::Organisms::SearchOrganismsByName;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
use namespace::autoclean;

=head1 NAME

Site::Form::Organisms::SearchOrganismsByDescription - HTML FormHandler Form

=head1 DESCRIPTION

The form for searching for organisms by name

=head1 METHODS

=cut

has '+item_class' => ( default =>'Name' );
has_field 'common_name' => (type => 'Text',label => 'Common Name', minlength => 5, maxlength => 140, required => 0);
has_field 'scientific_name' => (type => 'Text',label => 'Scientific Name', minlength => 5, maxlength => 140, required => 0);
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

__PACKAGE__->meta->make_immutable;
1;