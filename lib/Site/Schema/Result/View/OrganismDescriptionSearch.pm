package Site::Schema::Result::View::OrganismDescriptionSearch;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;

=head1 NAME

Site::Schema::Result::View::OrganismDescriptionSearch

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('organisms');

# ->table, ->add_columns, etc.

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

#the query to find and rank organisms near by
__PACKAGE__->result_source_instance->view_definition(
""
);


__PACKAGE__->add_columns(
  "ordercount",
  {
    data_type         => "integer",
    is_nullable       =>	1,
  },
   "organism_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "organisms_organism_id_seq",
  },

 );
 
 __PACKAGE__->set_primary_key("organism_id");
 
 
__PACKAGE__->belongs_to(
	"organism",
	"Site::Schema::Result::Organism",
 	{ organism_id => "organism_id" },
 	{ join_type => 'left outer'},
);




1;