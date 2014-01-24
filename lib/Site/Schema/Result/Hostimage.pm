use utf8;
package Site::Schema::Result::Hostimage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::Hostimage

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

=head1 TABLE: C<hostimages>

=cut

__PACKAGE__->table("hostimages");

=head1 ACCESSORS

=head2 image_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'hostimages_image_id_seq'

=head2 host_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

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

=head2 copyright

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "image_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "hostimages_image_id_seq",
  },
  "host_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "image_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "filename",
  { data_type => "text", is_nullable => 0 },
  "photographer",
  { data_type => "text", is_nullable => 1 },
  "copyright",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</image_id>

=back

=cut

__PACKAGE__->set_primary_key("image_id");

=head1 RELATIONS

=head2 host

Type: belongs_to

Related object: L<Site::Schema::Result::Host>

=cut

__PACKAGE__->belongs_to(
  "host",
  "Site::Schema::Result::Host",
  { host_id => "host_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 image_type

Type: belongs_to

Related object: L<Site::Schema::Result::Hostimagetype>

=cut

__PACKAGE__->belongs_to(
  "image_type",
  "Site::Schema::Result::Hostimagetype",
  { image_type_id => "image_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-05-01 21:28:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7wSpY66mJhOpEeZ3/j9S8A

=item create_info_string()

Generates a information about the host

=cut
sub create_info_string {
	my ($self) = @_;
	
	my $infostring = '';
	
	if ($self->host->common_name) 
	{
		$infostring .= $self->host->common_name;
	}
	
	if ($self->host->scientific_name) 
	{
		$infostring .= '<br /> (<em>'.$self->host->scientific_name.'</em>)';
	}

	return $infostring;

}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
