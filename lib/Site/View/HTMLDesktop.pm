package Site::View::HTMLDesktop;
use Moose;
use namespace::autoclean;

extends 'Site::View::HTMLBase';

__PACKAGE__->config(
    # This is your wrapper template located in the 'root/src'
    WRAPPER	=> 'templates/desktop.tt',
);

 
=head1 NAME

Site::View::HTMLDesktop - TT View for Site

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
