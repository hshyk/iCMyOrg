use utf8;
package Site::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Site::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_user_id_seq'

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 80

=head2 status_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 date_added

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 date_modified

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 authid

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 provider_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 forgot_password

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "users_user_id_seq",
  },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 120 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 80 },
  "status_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "authid",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "provider_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "forgot_password",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<unq-users-authid-provider_id>

=over 4

=item * L</authid>

=item * L</provider_id>

=back

=cut

__PACKAGE__->add_unique_constraint("unq-users-authid-provider_id", ["authid", "provider_id"]);

=head2 C<unq-users-email>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("unq-users-email", ["email"]);

=head1 RELATIONS

=head2 observationreviews

Type: has_many

Related object: L<Site::Schema::Result::Observationreview>

=cut

__PACKAGE__->has_many(
  "observationreviews",
  "Site::Schema::Result::Observationreview",
  { "foreign.user_changed" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 provider

Type: belongs_to

Related object: L<Site::Schema::Result::Authprovider>

=cut

__PACKAGE__->belongs_to(
  "provider",
  "Site::Schema::Result::Authprovider",
  { provider_id => "provider_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 status

Type: belongs_to

Related object: L<Site::Schema::Result::Status>

=cut

__PACKAGE__->belongs_to(
  "status",
  "Site::Schema::Result::Status",
  { status_id => "status_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 users_organisms

Type: has_many

Related object: L<Site::Schema::Result::UsersOrganism>

=cut

__PACKAGE__->has_many(
  "users_organisms",
  "Site::Schema::Result::UsersOrganism",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_roles

Type: has_many

Related object: L<Site::Schema::Result::UsersRole>

=cut

__PACKAGE__->has_many(
  "users_roles",
  "Site::Schema::Result::UsersRole",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</users_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "users_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-06-12 16:52:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nbPLidwZiV7DM/UjzbvhOg
use Perl6::Junction qw/any/;
use Try::Tiny;

__PACKAGE__->many_to_many(organisms => 'users_organisms', 'organism');

# Set the password field to use Blowfish encryption
__PACKAGE__->add_columns(
    '+password' => {
        passphrase       => 'rfc2307',
        passphrase_class => 'BlowfishCrypt',
        passphrase_args  => {
            cost        => 14,
            salt_random => 20,
        },
        passphrase_check_method => 'check_password',
    }
);




sub get_full_name {
	my ($self) = @_;
	
	return $self->first_name.' '.$self->last_name;
}

sub has_provider {
	my ($self, $provider) = @_;

	if (lc($self->provider->provider_name) eq lc($provider)) {
			return 1;
	}	
	
	return 0;
}

sub provider_name_lower {
	my ($self) = @_;
	
	return lc($self->provider->provider_name);
}

sub has_role {
	my ($self, $role) = @_;
    
    # Does this user posses the required role?
    return any(map { $_->role } $self->roles) eq $role;
}

sub all_role_ids {
	my ($self) = @_;
	
	 return [map { $_->role_id } $self->roles];
	
}

=item check_status()

Returns whether the user has a given status

=cut
sub check_status {
	my ($self, $status) = @_;

	return ($self->status->status_name eq $status); 
}



sub date_added_display {
	my ($self) = @_;
	
	try  {
		my $date = $self->date_added;
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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
