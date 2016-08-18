use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;
use Apache::TestRequest;

my %headers = (
               "Hello:World\n" => ["Hello", "World"],
#              "Hello  :  World\n" => ["Hello", "World"],
#              "Hello  :  World   \n" => ["Hello", "World"],
#              "Hello \t :  World  \n" => ["Hello", "World"],
               "Hello: Foo\n Bar\n" => ["Hello", "Foo Bar"],
               "Hello: Foo\n\tBar\n" => ["Hello", "Foo Bar"],
               "Hello: Foo\n    Bar\n" => ["Hello", qr/Foo +Bar/],
               "Hello: Foo \n Bar\n" => ["Hello", qr/Foo +Bar/],
               );

my $uri = "/modules/cgi/env.pl";

plan tests => (scalar keys %headers) * 3, need_cgi;

foreach my $key (sort keys %headers) {

    print "testing: $key";

    my $sock = Apache::TestRequest::vhost_socket('default');
    ok $sock;

    Apache::TestRequest::socket_trace($sock);

    $sock->print("GET $uri HTTP/1.0\r\n");
    $sock->print($key);
    $sock->print("\r\n");
    
    # Read the status line
    chomp(my $response = Apache::TestRequest::getline($sock) || '');
    $response =~ s/\s$//;

    ok t_cmp($response, qr{HTTP/1\.. 200 OK}, "response success");
    
    my $line;

    do {
        chomp($line = Apache::TestRequest::getline($sock) || '');
        $line =~ s/\s$//;
    }
    while ($line ne "");
    
    my $found = 0;

    my ($name, $value) = ($headers{$key}[0], $headers{$key}[1]);

    do {
        chomp($line = Apache::TestRequest::getline($sock) || '');
        $line =~ s/\r?\n?$//;
        if ($line ne "" && !$found) {
            my @part = split(/ = /, $line);
            if (@part && $part[0] eq "HTTP_" . uc($name)) {
                print "header: [".$part[1]."] vs [".$value."]\n";
                ok t_cmp $part[1], $value, "compare header $name value";
                $found = 1;
            }
        }
    }
    while ($line ne "");

    ok 0 unless $found;
}
    
