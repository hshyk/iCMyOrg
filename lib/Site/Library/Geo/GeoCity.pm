package Site::Library::Geo::GeoCity;
use strict;
use warnings;
use Moose;
use feature qw(switch);
extends 'Geo::IP::PurePerl';

my $location = undef;


sub geocodeLocation {
	my ($self, $loc) = @_;
	
	$location = $self->get_city_record_as_hash($loc);

	return $location;
}

sub checkInArea {
	my ($self, $type, $area) = @_;
	
	given($type){
		when ('city') {
			return $location->{city} eq $area;
		}
		when ('state' || 'region') {
			return $location->{region} eq $area;
		}
		when('country_code') {
			return $location->{country_code} eq $area;
		}
		when('postal') {
			return $location->{postal_code} eq $area;
		}
	}
	
	return 0;

	
}

sub getLatitude {
	my ($self) = @_;
	
	return $location->{latitude};
}

sub getLongitude {
	my ($self) = @_;
	
	return $location->{longitude};
}

sub getCity {
	my ($self) = @_;

	return $location->{city};
}
1;
