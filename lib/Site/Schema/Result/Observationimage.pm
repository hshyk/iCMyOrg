use utf8;
package Site::Schema::Result::Observationimage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Observationimage

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

=head1 TABLE: C<observationimages>

=cut

__PACKAGE__->table("observationimages");

=head1 ACCESSORS

=head2 image_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'images_image_id_seq'

=head2 observation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 image_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 filename

  data_type: 'text'
  is_nullable: 0

=head2 photographer

  data_type: 'text'
  is_nullable: 1

=head2 character_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 gender_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 description_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 image_comments

  data_type: 'text'
  is_nullable: 1

=head2 copyright

  data_type: 'text'
  is_nullable: 1

=head2 date_added

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 date_modified

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "image_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "images_image_id_seq",
  },
  "observation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "image_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "filename",
  { data_type => "text", is_nullable => 0 },
  "photographer",
  { data_type => "text", is_nullable => 1 },
  "character_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "gender_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "description_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "image_comments",
  { data_type => "text", is_nullable => 1 },
  "copyright",
  { data_type => "text", is_nullable => 1 },
  "date_added",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "date_modified",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</image_id>

=back

=cut

__PACKAGE__->set_primary_key("image_id");

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

=head2 description

Type: belongs_to

Related object: L<Site::Schema::Result::Observationimagedescriptiontype>

=cut

__PACKAGE__->belongs_to(
  "description",
  "Site::Schema::Result::Observationimagedescriptiontype",
  { description_id => "description_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 gender

Type: belongs_to

Related object: L<Site::Schema::Result::Gender>

=cut

__PACKAGE__->belongs_to(
  "gender",
  "Site::Schema::Result::Gender",
  { gender_id => "gender_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 image_type

Type: belongs_to

Related object: L<Site::Schema::Result::Observationimagetype>

=cut

__PACKAGE__->belongs_to(
  "image_type",
  "Site::Schema::Result::Observationimagetype",
  { image_type_id => "image_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 observation

Type: belongs_to

Related object: L<Site::Schema::Result::Observation>

=cut

__PACKAGE__->belongs_to(
  "observation",
  "Site::Schema::Result::Observation",
  { observation_id => "observation_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 observationimages_states

Type: has_many

Related object: L<Site::Schema::Result::ObservationimagesState>

=cut

__PACKAGE__->has_many(
  "observationimages_states",
  "Site::Schema::Result::ObservationimagesState",
  { "foreign.image_id" => "self.image_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_defaultimages

Type: has_many

Related object: L<Site::Schema::Result::OrganismsDefaultimage>

=cut

__PACKAGE__->has_many(
  "organisms_defaultimages",
  "Site::Schema::Result::OrganismsDefaultimage",
  { "foreign.image_id" => "self.image_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 states

Type: many_to_many

Composing rels: L</observationimages_states> -> state

=cut

__PACKAGE__->many_to_many("states", "observationimages_states", "state");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B0t69eTGad7KvD26OV0eZA

sub create_info_string {
	my ($self) = @_;
	
	my $infostring = '';
	
	if ($self->gender) 
	{
		$infostring .= ', '.$self->gender->gender_name;
	}
	
	if ($self->description) 
	{
		$infostring .= ', '.$self->description->description_name;
	}
	
	if ($self->image_comments) 
	{
		$infostring .= ', '.$self->image_comments;
	}
	
	if ($self->photographer) 
	{
		$infostring .= ', Credit: '.$self->photographer;
	}
	
	return substr($infostring, 1);

}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
