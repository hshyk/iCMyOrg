use utf8;
package Site::Schema::Result::Host;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Host

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

=head1 TABLE: C<hosts>

=cut

__PACKAGE__->table("hosts");

=head1 ACCESSORS

=head2 host_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'host_host_id_seq'

=head2 common_name

  data_type: 'text'
  is_nullable: 0

=head2 scientific_name

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=cut

__PACKAGE__->add_columns(
  "host_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "host_host_id_seq",
  },
  "common_name",
  { data_type => "text", is_nullable => 0 },
  "scientific_name",
  { data_type => "varchar", is_nullable => 1, size => 150 },
);

=head1 PRIMARY KEY

=over 4

=item * L</host_id>

=back

=cut

__PACKAGE__->set_primary_key("host_id");

=head1 RELATIONS

=head2 hostimages

Type: has_many

Related object: L<Site::Schema::Result::Hostimage>

=cut

__PACKAGE__->has_many(
  "hostimages",
  "Site::Schema::Result::Hostimage",
  { "foreign.host_id" => "self.host_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms_hosts

Type: has_many

Related object: L<Site::Schema::Result::OrganismsHost>

=cut

__PACKAGE__->has_many(
  "organisms_hosts",
  "Site::Schema::Result::OrganismsHost",
  { "foreign.host_id" => "self.host_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organisms

Type: many_to_many

Composing rels: L</organisms_hosts> -> organism

=cut

__PACKAGE__->many_to_many("organisms", "organisms_hosts", "organism");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:57CBKRXN0oty76jDvFF5bg

=item host_url()

Get the url of the organisms host

=cut
sub host_url {
	my ($self) = @_;

	my $url = $self->scientific_name;
	$url =~ s/\.//g;
	$url =~ s/ /_/g;
	
	return lc($url);
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
