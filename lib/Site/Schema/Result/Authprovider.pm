use utf8;
package Site::Schema::Result::Authprovider;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Authprovider

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

=head1 TABLE: C<authproviders>

=cut

__PACKAGE__->table("authproviders");

=head1 ACCESSORS

=head2 provider_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'authproviders_provider_id_seq'

=head2 provider_name

  data_type: 'varchar'
  is_nullable: 0
  size: 80

=cut

__PACKAGE__->add_columns(
  "provider_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "authproviders_provider_id_seq",
  },
  "provider_name",
  { data_type => "varchar", is_nullable => 0, size => 80 },
);

=head1 PRIMARY KEY

=over 4

=item * L</provider_id>

=back

=cut

__PACKAGE__->set_primary_key("provider_id");

=head1 RELATIONS

=head2 users

Type: has_many

Related object: L<Site::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "Site::Schema::Result::User",
  { "foreign.provider_id" => "self.provider_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+zEJEVrYp9Ur1aXB1bIPTg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
