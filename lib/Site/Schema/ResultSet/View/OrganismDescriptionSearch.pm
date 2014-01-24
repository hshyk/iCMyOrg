package Site::Schema::ResultSet::View::OrganismDescriptionSearch;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

 Site::Schema::ResultSet::View::OrganismDescriptionSearch;

=cut

=head2 findProviderIDByName



=cut

sub searchQuery {
	my ($self, $charactertype, $query, $bind, $rows,  $page) = @_;

	$self->result_source->view_definition($query);
	
	return $self->search(
		{
		}, 
		{
			prefetch => {
				'organism'	
			},			
			order_by => { 
				-desc => [qw/
					ordercount 
					me.organism_id
				/] 
			},
			bind => [@$bind],
			rows => $rows || 10,
        	page => $page || 1,
		}
	)
}

sub searchDescriptionJSON {
	my ($self, $query, $bind, $charactertype, $rows, $page  ) = @_;
	
	my @results;
	
	

	foreach my $organism ($self->searchQuery($charactertype, $query, $bind, $rows, $page)->all) {
		
		my $item;
		#my $image = $organism->organism->character_image(
		#	$charactertype
		#);

		$item->{'scientific_name'} = $organism->organism->scientific_name;
		$item->{'common_name'} = $organism->organism->common_name;
		$item->{'organism_url'} = $organism->organism->organism_url;
		
		if (defined $organism->ordercount) {
		
			$item->{'score'} = $organism->ordercount;
			
			if ($item->{'score'} >= 100) {
				$item->{'score'} = '99';
			}
			
			if (!($item->{'score'} > 1)) {
				$item->{'score'} = '1';
			}
		}
		
		$item->{'image_id'} = $organism->character_image->image_info->image_id;
		$item->{'image_path'} = $organism->character_image->image_info->filename; 
							
		push(@results, $item); 
	}

	return \@results;
}


1;