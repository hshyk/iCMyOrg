use utf8;
package Site::Schema::Result::Character;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Character

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

=head1 TABLE: C<characters>

=cut

__PACKAGE__->table("characters");

=head1 ACCESSORS

=head2 character_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'characters_character_id_seq'

=head2 character_name

  data_type: 'text'
  is_nullable: 0

=head2 is_numeric

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 character_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "character_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "characters_character_id_seq",
  },
  "character_name",
  { data_type => "text", is_nullable => 0 },
  "is_numeric",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "character_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</character_id>

=back

=cut

__PACKAGE__->set_primary_key("character_id");

=head1 RELATIONS

=head2 character_type

Type: belongs_to

Related object: L<Site::Schema::Result::Charactertype>

=cut

__PACKAGE__->belongs_to(
  "character_type",
  "Site::Schema::Result::Charactertype",
  { character_type_id => "character_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 states

Type: has_many

Related object: L<Site::Schema::Result::State>

=cut

__PACKAGE__->has_many(
  "states",
  "Site::Schema::Result::State",
  { "foreign.character_id" => "self.character_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rzP4jOrICY3x75v+csfqEQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
