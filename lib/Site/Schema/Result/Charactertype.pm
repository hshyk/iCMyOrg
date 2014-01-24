use utf8;
package Site::Schema::Result::Charactertype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Charactertype

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

=head1 TABLE: C<charactertypes>

=cut

__PACKAGE__->table("charactertypes");

=head1 ACCESSORS

=head2 character_type_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'charactertypes_character_type_id_seq'

=head2 character_type

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "character_type_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "charactertypes_character_type_id_seq",
  },
  "character_type",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</character_type_id>

=back

=cut

__PACKAGE__->set_primary_key("character_type_id");

=head1 RELATIONS

=head2 characters

Type: has_many

Related object: L<Site::Schema::Result::Character>

=cut

__PACKAGE__->has_many(
  "characters",
  "Site::Schema::Result::Character",
  { "foreign.character_type_id" => "self.character_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 observationimages

Type: has_many

Related object: L<Site::Schema::Result::Observationimage>

=cut

__PACKAGE__->has_many(
  "observationimages",
  "Site::Schema::Result::Observationimage",
  { "foreign.character_type_id" => "self.character_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_defaultimages

Type: has_many

Related object: L<Site::Schema::Result::OrganismsDefaultimage>

=cut

__PACKAGE__->has_many(
  "organisms_defaultimages",
  "Site::Schema::Result::OrganismsDefaultimage",
  { "foreign.character_type_id" => "self.character_type_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fpbGkzXvZw1FyqHe6dq1pQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
