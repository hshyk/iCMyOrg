package Site::Form::Organisms::SearchOrganismsByDescription;

use HTML::FormHandler::Moose;
use Date::Calc qw(check_date);
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Organisms::SearchOrganismsByDescription - HTML FormHandler Form

=head1 DESCRIPTION

The form for searching for organisms by description

=head1 METHODS

options_character

=cut

has '+item_class' => ( 
	default =>'Character',
);

has_field 'character_type_id'	=> (
	type	=>	'Select',
	label	=>	'Character Type', 
);

has_field 'habitat_id'			=> (
	type			=>	'Select',
	label 			=>	'Select a habitat', 
	empty_select	=>	'-----Select a Habitat-----',
);

has_field 'observed_day'		=> (
	type	=> 'Select',
	label	=> 'Use a date observed?', 
	options	=> [
		{ 
			value		=> 0, 
			label		=> 'No', 
			selected	=> 'selected'
		}, 
		{ 
			value => 1, 
			label => 'Yes'
		}
	],
);

has_field 'day'  => (type => 'Select', label => 'When was this observed?', required => 0 );
has_field 'month'  => (type => 'Select', label => '', required => 0 );

has_field 'observed_location' => (
	type => 'Select', 
	label => 'Use a location observed?', 
	required => 0, 
									options => [
												{ value => 'no', label => 'No'}, 
												{ value => 'current', label => 'Use current location'},
												{ value => 'address', label => 'Type in address'},
												{ value => 'map', label => 'Select on map'}]);
has_field 'address' => (type => 'Text', label => 'What is the address?', minlength => 5, maxlength => 140, required => 0,  size => 40);
has_field 'month'  => (type => 'Select', label => '');
has_field 'latitude' => (type => 'Hidden');
has_field 'longitude' => (type => 'Hidden');
has_field 'submit' => ( type => 'Submit', value => 'Find' );


=head2 options_character

Sets the list of characters for the dropdown

=cut

sub options_character_type_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the characters (except for the All type) and sort them by their name
	my @rows = $self->schema->resultset('Charactertype')->searchDisplay()->all;
	
	#return a map for use in the dropdown menu
	return [ map { $_->character_type_id, $_->character_type } @rows ];

}

sub options_habitat_id {
	my ($self) = shift;
	
	#make sure the data model is set
	return unless $self->schema;
	
	#find all the characters (except for the All type) and sort them by their name
	my @rows = $self->schema->resultset('State')->search( 
		{
			'character.character_name' => 'Habitats'
		}, 
		{
			join     => [
				qw/ character /
			],
			order_by => { 
				-asc => 'state_name'
			}
		}
	)->all;

	return [ map { $_->state_id, $_->state_name } @rows ];

}

=head2 options_day

Set the dropdown options for the days

=cut

sub options_day {
	
	my @rows  = (1  .. 31);

	return [ map { $_, $_ } @rows ];
	
}

=head2 options_month

Set the dropdown options for the months

=cut

sub options_month {
	
	my @rows =	(	
					1	=>	'January',
					2	=> 	'February',
					3 	=>	'March',
					4	=>	'April',
					5	=>	'May',
					6	=>	'June',
					7	=>	'July',
					8	=>	'August',
					9	=>	'September',
					10	=>	'October',
					11	=>	'November',
					12	=>	'December' 
				);

	return [ map { $_ } @rows ];
}


=head2 default_day

Get the current date and set the day field

=cut

sub default_day {
	
	#get the local time
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);
	
	#return the current date
	return $day;
}

=head2 default_month

Get the current date and set the month field

=cut

sub default_month {
	
	#get the local time
	my ($sec,$min,$hour,$day,$month,$year,@rest) =   localtime(time);
	
	#return the current month
	return $month+1;
}

__PACKAGE__->meta->make_immutable;
1;