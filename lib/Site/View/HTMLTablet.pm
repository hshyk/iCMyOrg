package Site::View::HTMLTablet;
use Moose;
use namespace::autoclean;
use strict;
use warnings;

extends 'Site::View::HTMLBase';

__PACKAGE__->config(
	static => {
          dirs => [
               'static',
                qr/^(images|css|js)/,
            ],
        },
     # This is your wrapper template located in the 'root/src'
    WRAPPER => 'templates/tablet.tt',   
);

=head1 NAME

Site::View::HTMLMobile - TT View for Site

=head1 DESCRIPTION

TT View for Site.

=head1 SEE ALSO

L<Site>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
