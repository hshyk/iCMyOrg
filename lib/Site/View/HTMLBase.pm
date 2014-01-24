package Site::View::HTMLBase;
use Moose;
use namespace::autoclean;
use Template::AutoFilter;

extends 'Catalyst::View::TT';


sub escape_js_string {
    my $s = shift;
    $s =~ s/(\\|'|"|\/)/\\$1/g;
    return $s;
};

__PACKAGE__->config(
	# Change default TT extension
    TEMPLATE_EXTENSION	=> '.tt',
    # Set the location for TT files
    INCLUDE_PATH	=> [
		Site->path_to( 'root', 'src' ),
	],
    # Set to 1 for detailed timer stats in your HTML as comments
	TIMER	 => 0,
    FILTERS => {
         escape_js  => \&escape_js_string,
    }
);

 
=head1 NAME

Site::View::HTMLBase - Base HTML TT View 

=head1 DESCRIPTION

Base HTML TT View for Site.

=head1 SEE ALSO

L<Site>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
