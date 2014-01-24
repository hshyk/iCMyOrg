use utf8;
package Site::Schema::Result::Observationreview;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Observationreview

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

=head1 TABLE: C<observationreviews>

=cut

__PACKAGE__->table("observationreviews");

=head1 ACCESSORS

=head2 review_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'observationreviews_review_id_seq'

=head2 observation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 comments

  data_type: 'text'
  is_nullable: 1

=head2 user_changed

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "review_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "observationreviews_review_id_seq",
  },
  "observation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "comments",
  { data_type => "text", is_nullable => 1 },
  "user_changed",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</review_id>

=back

=cut

__PACKAGE__->set_primary_key("review_id");

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

=head2 user_changed

Type: belongs_to

Related object: L<Site::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user_changed",
  "Site::Schema::Result::User",
  { user_id => "user_changed" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-06-12 16:52:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l3AA41h8/S5LLjShPfwpBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
