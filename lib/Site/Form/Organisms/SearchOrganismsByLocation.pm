package Site::Form::Organisms::SearchOrganismsByLocation;

use HTML::FormHandler::Moose;
use Date::Calc qw(check_date);
extends 'HTML::FormHandler';
use namespace::autoclean;

=head1 NAME

Site::Form::Organisms::SearchOrganismsByDescription - HTML FormHandler Form

=head1 DESCRIPTION

The form for searching for organisms by address

=head1 METHODS

=cut

has '+item_class' => ( default =>'Address' );
has_field 'observed_location' => (
	type => 'Select', 
	label => 'Location',
	empty_select => '-----Select type of observation-----',
	options => [
		{ value => 'current', label => 'Use current location'}, 
		{ value => 'address', label => 'Type in  address'},
		{ value => 'map', label => 'Select on map'}, 
	]
);
has_field 'address' => (type => 'Text',label => 'Address', minlength => 5, maxlength => 140, required => 1,  size => 40);
has_field 'day'  => (type => 'Select',  label => 'Date', required => 1, inactive => 1 );
has_field 'month'  => (type => 'Select', label => '', required => 1, inactive => 1);
has_field 'latitude' => (type => 'Hidden');
has_field 'longitude' => (type => 'Hidden');
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

=head2 options_day

Set the dropdown options for the days

=cut

sub options_day {
	my ($self) = shift;
	
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