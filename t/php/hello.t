use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, have_module 'php4';

## hello.php source:
## <?php echo "Hello World"?>
##
## result should be 'Hello World'

my $result = GET_BODY "/php/hello.php";
ok $result eq 'Hello World';
