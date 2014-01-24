package Site::Library::Geo::Google;
use strict;
use warnings;
use Moose;
use feature qw(switch);
extends 'Geo::Coder::Google::V3';

my $location = undef;

sub geocodeLocation {
	my ($self, $loc) = @_;
	
	$location = $self->geocode(location	=> $loc);
	
 	return $location;
}

sub checkInArea {
	my ($self, $type, $area) = @_;

	given($type){
		when ('city') {
			return getArea('locality') eq $area;
		}
		when ('state' || 'region') {
			return getArea('administrative_area_level_1') eq $area;
		}
		when('country') {
			return getArea('country') eq $area;

		}
		when('postal') {
			return getArea('postal_code') eq $area;
		}
	}
	
	return 0;
	
}

sub getArea {
	my ($name) = @_;

	foreach my $loc ($location->{'address_components'}) {
		foreach( @$loc) {
			if ($name ~~ $_->{'types'}) {
				return $_->{'short_name'}
			}
		}
	}
	return 0;
}


sub getLatitude {
	my ($self) = @_;
	
	return $location->{'geometry'}->{'location'}->{'lat'};
}

sub getLongitude {
	my ($self) = @_;
	
	return $location->{'geometry'}->{'location'}->{'lng'};
}

sub getCity {
	my ($self) = @_;

	return getArea('locality');
}

1;
