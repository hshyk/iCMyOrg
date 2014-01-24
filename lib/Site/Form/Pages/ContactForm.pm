package Site::Form::Pages::ContactForm;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Pages::ContactForm - HTML FormHandler Form

=head1 DESCRIPTION

Contact with bugs, issues, feature request, comments

=head1 METHODS

=cut

has '+item_class' => ( default =>'Contactform' );
has_field 'first_name' => (type => 'Text',label => 'First Name', minlength => 1, maxlength => 50, size => 40,  required => 1,);
has_field 'last_name' => (type => 'Text',label => 'Last Name', minlength => 1, maxlength => 70, size => 40,  required => 1,);
has_field 'email' => (type => 'Email', label => 'Email', minlength => 1, maxlength => 100, size => 40, required => 1);
has_field 'issue_type' => (type => 'Select',label => 'Issue Type', required => 0,  
								options => [
									{ value => 'question', label => 'Question', selected => 'selected'},
									{ value => 'comment', label => 'Comment'}, 
									{ value => 'error', label => 'Website Error/Bug'}, 
									{ value => 'feature', label => 'Feature Request'}, 
									{ value => 'photo', label => 'Missing Photo Submission'},  
]);
has_field 'device' => (type => 'Text',label => 'What device are you using to access the site (Desktop, iPhone, Android)?  Please specify device name and operating system version if possible.', minlength => 1, maxlength => 70, size => 40, required => 0,);
has_field 'information' => (type => 'TextArea', label => 'Information', required => 1); 
has_field 'submit' => ( type => 'Submit', value => 'Submit' );



__PACKAGE__->meta->make_immutable;
1;