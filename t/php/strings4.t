use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, have_module 'php4';

my $expected = <<EXPECT;
&lt;&gt;&quot;&amp;��
&lt;&gt;&quot;&amp;&aring;&Auml;
EXPECT

my $result = GET_BODY "/php/strings4.php";

ok $result eq $expected;
