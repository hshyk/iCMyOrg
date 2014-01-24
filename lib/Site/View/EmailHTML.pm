package Site::View::EmailHTML;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
        # Change default TT extension
        TEMPLATE_EXTENSION => '.tt',
        # Set the location for TT files
        INCLUDE_PATH => [
                Site->path_to( 'root', 'src' ),
            ],
        # Set to 1 for detailed timer stats in your HTML as comments
        TIMER              => 0,
        # This is your wrapper template located in the 'root/src'
        WRAPPER => 'templates/email.tt',
       
    );

=head1 NAME

Site::View::HTML - TT View for Site

=head1 DESCRIPTION

TT View for Site.

=head1 SEE ALSO

L<Site

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
