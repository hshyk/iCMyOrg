use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Site';
use Site::Controller::Cron;

ok( request('/cron')->is_success, 'Request should succeed' );
done_testing();
