use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Site';
use Site::Controller::Authentication;

ok( request('/authentication')->is_success, 'Request should succeed' );
done_testing();
