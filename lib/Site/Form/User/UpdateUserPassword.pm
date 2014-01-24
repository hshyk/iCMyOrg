package Site::Form::User::UpdateUserPassword;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::UpdateUserPassword - HTML FormHandler Form

=head1 DESCRIPTION

Update the user password

=head1 METHODS

=cut

has '+item_class' => ( default =>'PasswordChange' );
has_field 'password_current'  => (type => 'Password', label => 'Current Password', minlength => 6, maxlength => 40, required => 1,  size => 40 );
has_field 'password_new'  => (type => 'Password', label => 'New Password', minlength => 6, maxlength => 40, required => 1,  size => 40 );
has_field 'password_confirm'  => (type => 'PasswordConf', password_field => 'password_new', 'new_password', label => 'Confirm your New Password', minlength => 6, maxlength => 40, required => 1,  size => 40 );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

sub update_model {
	my ($self) = shift;
		
	$self->item->set_columns(
		{
			password => $self->field('password_new')->value
		}
	);
	
	#insert the data					  
	$self->item->update();
}



sub validate_password_current {
	my ($self) = shift;
	
	my $user = $self->item->check_password($self->field('password_current')->value);
	
	if (!$user) {
			$self->field('password_current')->add_error(
			'Your old password is incorrect'
		);
	}
	

	
	
}



__PACKAGE__->meta->make_immutable;
1;