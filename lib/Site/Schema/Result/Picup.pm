use utf8;
package Site::Schema::Result::Picup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Picup

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

=head1 TABLE: C<picup>

=cut

__PACKAGE__->table("picup");

=head1 ACCESSORS

=head2 observation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 passkey

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 ip_address

  data_type: 'inet'
  is_nullable: 0

=head2 date_added

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "observation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "passkey",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "ip_address",
  { data_type => "inet", is_nullable => 0 },
  "date_added",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</observation_id>

=back

=cut

__PACKAGE__->set_primary_key("observation_id");

=head1 RELATIONS

=head2 observation

Type: belongs_to

Related object: L<Site::Schema::Result::Observation>

=cut

__PACKAGE__->belongs_to(
  "observation",
  "Site::Schema::Result::Observation",
  { observation_id => "observation_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tCdHEf+GtfGTgkmGM+hRmw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
