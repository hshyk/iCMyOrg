use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Site';
use Site::Controller::Review;

ok( request('/review')->is_success, 'Request should succeed' );
done_testing();
