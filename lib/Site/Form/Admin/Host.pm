package Site::Form::Admin::Host;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::Host - HTML Formhandler Class

=head1 DESCRIPTION

Add a host

=head1 METHODS

=cut

has '+item_class' => (default =>'Host');
has_field 'scientific_name' => (type => 'Text', label => 'Scientific Name', minlength => 1, maxlength => 40, required => 1, size => 60);
has_field 'common_name'  => (type => 'Text', label => 'Common Name', size => 60 );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

__PACKAGE__->meta->make_immutable;
1;