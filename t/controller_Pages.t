use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Site';
use Site::Controller::Pages;

ok( request('/pages')->is_success, 'Request should succeed' );
done_testing();
