package Site::Form::Admin::Organism;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

=head1 NAME

Site::Form::Admin::Organism - HTML Formhandler Class

=head1 DESCRIPTION

Add and organism

=head1 METHODS

=cut

has '+item_class' => (default =>'Organism');
has_field 'family_name' => (type => 'Text', label => 'Family Name', minlength => 1, maxlength => 120,  size => 60);
has_field 'scientific_name' => (type => 'Text', label => 'Scientific Name', minlength => 1, maxlength => 120, required => 1, size => 60);
has_field 'common_name'  => (type => 'Text', label => 'Common Name', size => 60 );
has_field 'description'  => (type => 'TextArea', label => 'Description', cols  => 40, input_class	=>'ckeditor' );
has_field 'submit' => ( type => 'Submit', value => 'Submit' );

 sub render_filter {
        my $string = shift;
     
        return $string;
}

around 'update_model' => sub {
	my $orig = shift;
    my $self = shift;
    my $item = $self->item;

	$self->schema->txn_do( sub {
		$self->$orig(@_);
	
		$item->find_or_create_related(
			'observations',
			{
				observation_type_id	=>	$self->schema->resultset("Observationtype")->find(
					{
						'observation_name'	=>	$self->schema->systemobservation
					}
				)->observation_type_id,
				status_id			=>	$self->schema->resultset("Observationstatus")->find(
					{
						'status_name'	=>	$self->schema->observationstatus->{published}
					}
				)->status_id
			},
		);     
	});
};

__PACKAGE__->meta->make_immutable;
1;