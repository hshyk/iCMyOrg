use utf8;
package Site::Schema::Result::OrganismsDefaultimage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::OrganismsDefaultimage

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

=head1 TABLE: C<organisms_defaultimages>

=cut

__PACKAGE__->table("organisms_defaultimages");

=head1 ACCESSORS

=head2 organism_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 character_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 image_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "organism_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "character_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "image_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</organism_id>

=item * L</character_type_id>

=back

=cut

__PACKAGE__->set_primary_key("organism_id", "character_type_id");

=head1 RELATIONS

=head2 character_type

Type: belongs_to

Related object: L<Site::Schema::Result::Charactertype>

=cut

__PACKAGE__->belongs_to(
  "character_type",
  "Site::Schema::Result::Charactertype",
  { character_type_id => "character_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 image

Type: belongs_to

Related object: L<Site::Schema::Result::Observationimage>

=cut

__PACKAGE__->belongs_to(
  "image",
  "Site::Schema::Result::Observationimage",
  { image_id => "image_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 organism

Type: belongs_to

Related object: L<Site::Schema::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "Site::Schema::Result::Organism",
  { organism_id => "organism_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cUWsGIsH7faz+yAnHIsU4w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
