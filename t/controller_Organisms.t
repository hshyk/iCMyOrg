use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Site';
use Site::Controller::Organisms;

ok( request('/organisms')->is_success, 'Request should succeed' );
done_testing();
