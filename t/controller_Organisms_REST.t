use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Site';
use Site::Controller::Organisms_REST;

ok( request('/organisms_rest')->is_success, 'Request should succeed' );
done_testing();
