use utf8;
package Site::Schema::Result::State;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::State

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

=head1 TABLE: C<states>

=cut

__PACKAGE__->table("states");

=head1 ACCESSORS

=head2 state_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'states_state_id_seq'

=head2 state_name

  data_type: 'text'
  is_nullable: 0

=head2 character_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "state_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "states_state_id_seq",
  },
  "state_name",
  { data_type => "text", is_nullable => 0 },
  "character_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</state_id>

=back

=cut

__PACKAGE__->set_primary_key("state_id");

=head1 RELATIONS

=head2 character

Type: belongs_to

Related object: L<Site::Schema::Result::Character>

=cut

__PACKAGE__->belongs_to(
  "character",
  "Site::Schema::Result::Character",
  { character_id => "character_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 observationimages_states

Type: has_many

Related object: L<Site::Schema::Result::ObservationimagesState>

=cut

__PACKAGE__->has_many(
  "observationimages_states",
  "Site::Schema::Result::ObservationimagesState",
  { "foreign.state_id" => "self.state_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_states

Type: has_many

Related object: L<Site::Schema::Result::OrganismsState>

=cut

__PACKAGE__->has_many(
  "organisms_states",
  "Site::Schema::Result::OrganismsState",
  { "foreign.state_id" => "self.state_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 images

Type: many_to_many

Composing rels: L</observationimages_states> -> image

=cut

__PACKAGE__->many_to_many("images", "observationimages_states", "image");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iHdrL2gB7snXvSyf72Xwzg

__PACKAGE__->many_to_many("organisms", "organisms_states", "organism");

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
