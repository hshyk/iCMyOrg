use utf8;
package Site::Schema::Result::Organism;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Organism

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

=head1 TABLE: C<organisms>

=cut

__PACKAGE__->table("organisms");

=head1 ACCESSORS

=head2 organism_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'organisms_organism_id_seq'

=head2 scientific_name

  data_type: 'text'
  is_nullable: 0

=head2 common_name

  data_type: 'text'
  is_nullable: 1

=head2 family_name

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "organism_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "organisms_organism_id_seq",
  },
  "scientific_name",
  { data_type => "text", is_nullable => 0 },
  "common_name",
  { data_type => "text", is_nullable => 1 },
  "family_name",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</organism_id>

=back

=cut

__PACKAGE__->set_primary_key("organism_id");

=head1 RELATIONS

=head2 observations

Type: has_many

Related object: L<Site::Schema::Result::Observation>

=cut

__PACKAGE__->has_many(
  "observations",
  "Site::Schema::Result::Observation",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_defaultimages

Type: has_many

Related object: L<Site::Schema::Result::OrganismsDefaultimage>

=cut

__PACKAGE__->has_many(
  "organisms_defaultimages",
  "Site::Schema::Result::OrganismsDefaultimage",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_hosts

Type: has_many

Related object: L<Site::Schema::Result::OrganismsHost>

=cut

__PACKAGE__->has_many(
  "organisms_hosts",
  "Site::Schema::Result::OrganismsHost",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_states

Type: has_many

Related object: L<Site::Schema::Result::OrganismsState>

=cut

__PACKAGE__->has_many(
  "organisms_states",
  "Site::Schema::Result::OrganismsState",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_organisms

Type: has_many

Related object: L<Site::Schema::Result::UsersOrganism>

=cut

__PACKAGE__->has_many(
  "users_organisms",
  "Site::Schema::Result::UsersOrganism",
  { "foreign.organism_id" => "self.organism_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 hosts

Type: many_to_many

Composing rels: L</organisms_hosts> -> host

=cut

__PACKAGE__->many_to_many("hosts", "organisms_hosts", "host");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-06-13 15:03:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m51gVmOdwNP4cBG5+nJ0/g


__PACKAGE__->many_to_many(users => 'users_organisms', 'users');

__PACKAGE__->many_to_many(states => 'organisms_states', 'state');

=item organism_url()

Create the url part of the name

=cut
sub organism_url {
	my ($self) = @_;

	my $url = $self->scientific_name;
	$url =~ s/ /_/g;
	
	return lc($url);
}



sub default_image {
	my ($self, $charactertype) = @_;
	$charactertype = $charactertype	||  $self->result_source->schema->defaultcharacter;

	foreach ($self->organisms_defaultimages) {
		if ($_->character_type->character_type eq $charactertype) {
			return $_->image;
		}
		
	}

	return $self->result_source->schema->resultset('Observationimage')->new(
		{
			image_id => 0, 
			filename => $self->result_source->schema->no_image->{$charactertype}
		}
	);
	
}



# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
