package Site::Action::FormProcess;
use MooseX::MethodAttributes::Role;
use namespace::autoclean;
    

=head1 NAME

Site::Controller::Action::FormProcess

=head1 DESCRIPTION

Action - Different types of form processing

=head1 METHODS

=cut

=head2 formprocess
 
Form processing

=cut      
sub formprocess :Private {
	my ($self, $c, $form, $model, $status_msg, $error_msg, $view) = @_;
	
	my $isProcessed = 0;
	# Check to see if the form has been posted
	if ($c->request->method eq 'POST') {
		
		# Process the form
		$isProcessed = $form->process(
			item => $model, 
			params => $c->request->params 
		);
		
		# If the form is validated pass in the completed status message
		if ($form->validated) {
			$c->flash->{status_msg} = $status_msg;
		}
		# If the form has an error pass in the error message
		else {
			$c->flash->{error_msg} = $error_msg;
		}
	}
    
    # Load the view and the form to pass to the controller    
	$c->stash( 
		template	=>	$view, 
		form		=>	$form
	);
	
	return $isProcessed;
}

=head2 formprocess_basic
 
Basic form processing only checks if posted and process the form

=cut      
sub formprocess_basic :Private {
	my ($self, $c, $form) = @_;
	
	# If the form is posted just do processing (no views, messages, etc)
	if ($c->request->method eq 'POST') {	
		return $form->process(
			params => $c->request->params 
	 	);
		
	}
}

=head2 formprocess_nomodel
 
Basic form processing, does not contain a model

=cut  
sub formprocess_nomodel :Private {
	my ($self, $c, $form, $view) = @_;
	
	$c->stash( 
		template => $view, 
		form => $form
	);
	
	# If the form is posted just do processing (no views, messages, etc)
	if ($c->request->method eq 'POST') {	
		return $form->process(
			params => $c->request->params 
	 	);
		
	}
}

=head2 formprocess_redirect
 
Form processign with redirect after form is completed, validated and saved

=cut  
sub formprocess_redirect :Private {
	my ($self, $c, $form, $model, $status_msg, $error_msg, $view, $redirect_url, $redirect_params) = @_;
	
	my $isProcessed = 0;
	# Check to see if the form has been posted
	if ($c->request->method eq 'POST') {
		
		# Process the form
		$isProcessed = $form->process(
			item => $model, 
			params => $c->request->params 
		);
		
		# If the form is validated pass in the completed status message
		if ($form->validated) {
			$c->flash->{status_msg} = $status_msg;
			# Redirect with URL and Parameters (if any)
			$c->response->redirect(
    			$c->uri_for(
    				$redirect_url,
    				$redirect_params
    			)
    		 );
		}
		# If the form has an error pass in the error message
		else {
			$c->flash->{error_msg} = $error_msg;
		}
	}
    
    # Load the view and the form to pass to the controller    
	$c->stash( 
		template	=>	$view, 
		form		=>	$form
	 );
	
	return $isProcessed;
}

1;