package Site::Schema::ResultSet::State;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

Site::Schema::ResultSet::Character

=cut

=head2 by_name

Find OAuth users by name

=cut

sub convert_inches_to_cm {
	my ($self, $value) = @_;
	
	return $value * 25.4;
}

sub getStateByCharacter {
	my ($self, $character) = @_;
	
	return $self->search(	
		{
			character_id => $character
		}
	)
}

sub getStateByCharacterJSON {
	my ($self, $character) = @_;
	
	my $stateNames;
				
	#puts state id and value into an array
	foreach ($self->getStateByCharacter($character)->all) {
		$stateNames->{$_->state_id} = $_->state_name;
	}
	
	return $stateNames;
}


1;