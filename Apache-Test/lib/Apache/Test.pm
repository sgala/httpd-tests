package Apache::Test;

use strict;
use warnings FATAL => 'all';

use Test qw(ok);
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT = qw(ok plan have_lwp);
our $VERSION = '0.01';

#so Perl's Test.pm can be run inside mod_perl
sub init_test_pm {
    my $r = shift;

    if (defined &Apache::RequestRec::puts) {
        package Apache::RequestRec;
        unless (defined &PRINT) {
            *PRINT = \&puts;
        }
        tie *STDOUT, __PACKAGE__, $r;
    }
    else {
        $r->send_http_header; #1.xx
    }

    $r->content_type('text/plain');

    $Test::TESTOUT = \*STDOUT;
    $Test::planned = 0;
    $Test::ntest = 1;
}

sub plan {
    init_test_pm(shift) if ref $_[0];

    my $condition = pop @_ if ref $_[-1];
    if ($condition) {
        unless (defined &have_lwp) {
            #XXX figure out a better set this up
            #dont want to require Apache::TestRequest/lwp
            #on the server side
            require Apache::TestRequest;
            *have_lwp = \&Apache::TestRequest::has_lwp;
        }
        unless ($condition->()) {
            print "1..0\n";
            exit; #XXX: Apache->exit
        }
    }

    Test::plan(@_);
}

1;


