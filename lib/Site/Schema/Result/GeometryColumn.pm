use utf8;
package Site::Schema::Result::GeometryColumn;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::GeometryColumn

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::EncodedColumn>

=item * L<DBIx::Class::PassphraseColumn>

=item * L<DBIx::Class::VirtualColumns>

=back

=cut

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "TimeStamp",
  "EncodedColumn",
  "PassphraseColumn",
  "VirtualColumns",
);

=head1 TABLE: C<geometry_columns>

=cut

__PACKAGE__->table("geometry_columns");

=head1 ACCESSORS

=head2 f_table_catalog

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 f_table_schema

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 f_table_name

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 f_geometry_column

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 coord_dimension

  data_type: 'integer'
  is_nullable: 0

=head2 srid

  data_type: 'integer'
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=cut

__PACKAGE__->add_columns(
  "f_table_catalog",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "f_table_schema",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "f_table_name",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "f_geometry_column",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "coord_dimension",
  { data_type => "integer", is_nullable => 0 },
  "srid",
  { data_type => "integer", is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</f_table_catalog>

=item * L</f_table_schema>

=item * L</f_table_name>

=item * L</f_geometry_column>

=back

=cut

__PACKAGE__->set_primary_key(
  "f_table_catalog",
  "f_table_schema",
  "f_table_name",
  "f_geometry_column",
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SNQs48Cj9964vwMRJ6epBg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
