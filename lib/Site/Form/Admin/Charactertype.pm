package Site::Form::Admin::Charactertype;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;
 
=head1 NAME

Site::Form::Admin::Character - HTML Formhandler Class

=head1 DESCRIPTION

Add a character

=head1 METHODS

=cut

has '+item_class' => ( default =>'Charactertype' );
has_field 'character_type' => (type => 'Text',label => 'Character Type', minlength => 1, maxlength => 60, required => 1, size => 60);
has_field 'submit' => ( type => 'Submit', value => 'Submit' );




__PACKAGE__->meta->make_immutable;
1;