use utf8;
package Site::Schema::Result::Observationimagedescriptiontype;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Observationimagedescriptiontype

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

=head1 TABLE: C<observationimagedescriptiontypes>

=cut

__PACKAGE__->table("observationimagedescriptiontypes");

=head1 ACCESSORS

=head2 description_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'observationimagedescriptiontype_description_id_seq'

=head2 description_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "description_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "observationimagedescriptiontype_description_id_seq",
  },
  "description_name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</description_id>

=back

=cut

__PACKAGE__->set_primary_key("description_id");

=head1 RELATIONS

=head2 observationimages

Type: has_many

Related object: L<Site::Schema::Result::Observationimage>

=cut

__PACKAGE__->has_many(
  "observationimages",
  "Site::Schema::Result::Observationimage",
  { "foreign.description_id" => "self.description_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YvNc89fRDLuzfFKWilwJdQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
