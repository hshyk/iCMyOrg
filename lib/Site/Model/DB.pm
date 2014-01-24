package Site::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Site::Schema',
    
    connect_info => {
		dsn 		=>	Site->config->{DB}->{dsn},
		user		=>	Site->config->{DB}->{user},
        password	=>	Site->config->{DB}->{password},
    },
    
	traits       => 'SchemaProxy',
);

=head1 NAME

Site::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Site>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Site::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.59

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
