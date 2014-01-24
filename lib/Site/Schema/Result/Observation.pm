use utf8;
package Site::Schema::Result::Observation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Observation

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

=head1 TABLE: C<observations>

=cut

__PACKAGE__->table("observations");

=head1 ACCESSORS

=head2 observation_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'observations_observation_id_seq'

=head2 organism_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 datum

  data_type: 'text'
  is_nullable: 1

=head2 observation_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 latitude

  data_type: 'double precision'
  is_nullable: 1

=head2 longitude

  data_type: 'double precision'
  is_nullable: 1

=head2 geom

  data_type: 'geometry'
  is_nullable: 1

=head2 user_organism_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 date_observed

  data_type: 'date'
  is_nullable: 1

=head2 source

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 location_detail

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

=head2 number_seen

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 status_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "observation_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "observations_observation_id_seq",
  },
  "organism_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "datum",
  { data_type => "text", is_nullable => 1 },
  "observation_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "latitude",
  { data_type => "double precision", is_nullable => 1 },
  "longitude",
  { data_type => "double precision", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
  "user_organism_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "date_observed",
  { data_type => "date", is_nullable => 1 },
  "source",
  { data_type => "varchar", is_nullable => 1, size => 120 },
  "location_detail",
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
  "number_seen",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "status_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</observation_id>

=back

=cut

__PACKAGE__->set_primary_key("observation_id");

=head1 RELATIONS

=head2 observation_type

Type: belongs_to

Related object: L<Site::Schema::Result::Observationtype>

=cut

__PACKAGE__->belongs_to(
  "observation_type",
  "Site::Schema::Result::Observationtype",
  { observation_type_id => "observation_type_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 observationimages

Type: has_many

Related object: L<Site::Schema::Result::Observationimage>

=cut

__PACKAGE__->has_many(
  "observationimages",
  "Site::Schema::Result::Observationimage",
  { "foreign.observation_id" => "self.observation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 observationnotes

Type: has_many

Related object: L<Site::Schema::Result::Observationnote>

=cut

__PACKAGE__->has_many(
  "observationnotes",
  "Site::Schema::Result::Observationnote",
  { "foreign.observation_id" => "self.observation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 observationreviews

Type: has_many

Related object: L<Site::Schema::Result::Observationreview>

=cut

__PACKAGE__->has_many(
  "observationreviews",
  "Site::Schema::Result::Observationreview",
  { "foreign.observation_id" => "self.observation_id" },
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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 picup

Type: might_have

Related object: L<Site::Schema::Result::Picup>

=cut

__PACKAGE__->might_have(
  "picup",
  "Site::Schema::Result::Picup",
  { "foreign.observation_id" => "self.observation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 status

Type: belongs_to

Related object: L<Site::Schema::Result::Observationstatus>

=cut

__PACKAGE__->belongs_to(
  "status",
  "Site::Schema::Result::Observationstatus",
  { status_id => "status_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user_organism

Type: belongs_to

Related object: L<Site::Schema::Result::UsersOrganism>

=cut

__PACKAGE__->belongs_to(
  "user_organism",
  "Site::Schema::Result::UsersOrganism",
  { user_organism_id => "user_organism_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-06-11 14:19:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qI1ewYiMqUqFHqHLBxoIdA

__PACKAGE__->might_have(
  "images",
	"Site::Schema::Result::Observationimage",
  { "foreign.observation_id" => "self.observation_id" },
  { join_type => 'left outer'},
);

# Need to rename so that it does not conflict with User status
__PACKAGE__->belongs_to(
  "observestatus",
  "Site::Schema::Result::Observationstatus",
  { status_id => "status_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

use DateTime;
use DateTime::Format::Strptime;
use Try::Tiny;

sub date_observed_display {
	my ($self) = @_;
	
	try  {
		my $date = $self->date_observed;
		$date =~ s/T|00|://g;
		 
		my $format = new DateTime::Format::Strptime(
			pattern => '%Y-%m-%d',
		);
	
		my $formatted = $format->parse_datetime($date);

		return $formatted->strftime("%B %d, %Y");
	}
	catch {
		return '';
	}	
}

sub date_observed_format {
	my ($self) = @_;
	
	try  {
		my $date = $self->date_observed;
		$date =~ s/T|00|://g;
		 
		return $date;
	}
	catch {
		return '';
	}	
}

sub date_observed_day {
	my ($self) = @_;
	
	try  {
		my $date = $self->date_observed;
		$date =~ s/T|00|://g;
		my $format = new DateTime::Format::Strptime(
			pattern => '%Y-%m-%d',
		);
	
		my $formatted = $format->parse_datetime($date);

		return $formatted->strftime("%d");
	}
	catch {
		return '';
	}	
}

sub date_observed_month {
	my ($self) = @_;
	
	try  {
		my $date = $self->date_observed;
		$date =~ s/T|00|://g;
		
		my $format = new DateTime::Format::Strptime(
			pattern => '%Y-%m-%d',
		);
	
		my $formatted = $format->parse_datetime($date);

		return $formatted->strftime("%m");
	}
	catch {
		return '';
	}	
}

sub date_observed_year {
	my ($self) = @_;
	
	try  {
		my $date = $self->date_observed;
		$date =~ s/T|00|://g;
		
		my $format = new DateTime::Format::Strptime(
			pattern => '%Y-%m-%d',
		);
	
		my $formatted = $format->parse_datetime($date);

		return $formatted->strftime("%Y");
	}
	catch {
		return '';
	}	
}

sub first_image{
	my ($self, $charactertype) = @_;
	
	if (defined $self->images) {
		return $self->images;	
	}
	else {
		return $self->organism->default_image($charactertype);	
	}
}

sub latest_review_comment() {
	my ($self) = @_;
	
	return $self->observationreviews->search(
		{},
		{
			order_by	=>	{ -desc => ['review_id'] }
		}
	)->first()->comments;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
