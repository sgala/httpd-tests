use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;
use Ext-Modules::TestEnv;

plan tests => 1, \&Ext-Modules::TestEnv::has_php4;

my $expected = <<EXPECT;
Testing strtok: passed
Testing strstr: passed
Testing strrchr: passed
Testing strtoupper: passed
Testing strtolower: passed
Testing substr: passed
Testing rawurlencode: passed
Testing rawurldecode: passed
Testing urlencode: passed
Testing urldecode: passed
Testing quotemeta: passed
Testing ufirst: passed
Testing strtr: passed
Testing addslashes: passed
Testing stripslashes: passed
Testing uniqid: passed
EXPECT

my $result = GET_BODY "/php/strings2.php";

ok $result eq $expected;
