use utf8;
package Site::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07022 @ 2013-03-01 14:45:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Q2Uvlg1y0X+0dWbGmNsITA


has	'no_image' => (
	is	=>	'rw'
);

has 'locationregex' => (
    is => 'rw',
);

has	'roles'	=> (
	is	=>	'rw'
);

has 'systemobservation' => (
    is => 'rw',
);

has 'defaultcharacter' => (
	is	=>	'rw'
);

has	'userobservation'	=>	(
	is	=>	'rw'
);

has	'systemcharactertype'	=>	(
	is	=>	'rw'
);

has 'observationstatus'	=>	(
	is	=>	'rw'
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
