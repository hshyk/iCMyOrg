use utf8;
package Site::Schema::Result::UsersOrganism;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::UsersOrganism

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

=head1 TABLE: C<users_organisms>

=cut

__PACKAGE__->table("users_organisms");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 organism_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_organism_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_organisms_user_organism_id_seq'

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "organism_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_organism_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_organisms_user_organism_id_seq",
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_organism_id>

=back

=cut

__PACKAGE__->set_primary_key("user_organism_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<unq-users_organisms-user_id-organism_id>

=over 4

=item * L</user_id>

=item * L</organism_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "unq-users_organisms-user_id-organism_id",
  ["user_id", "organism_id"],
);

=head1 RELATIONS

=head2 observations

Type: has_many

Related object: L<Site::Schema::Result::Observation>

=cut

__PACKAGE__->has_many(
  "observations",
  "Site::Schema::Result::Observation",
  { "foreign.user_organism_id" => "self.user_organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 user

Type: belongs_to

Related object: L<Site::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Site::Schema::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dLHND3l6dNAqKUNoMLMKbQ

#This needs to be renamed due to the fact that user is a reserved keyword in PostgreSQL
__PACKAGE__->belongs_to(
  "users",
  "Site::Schema::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
