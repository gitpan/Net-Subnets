#!/usr/bin/perl -w

use strict;
use Net::Subnets;

my @subnets   = qw(10.0.0.0/24 10.0.1.0/24);
my @addresses = qw(10.0.0.1 10.0.1.2 10.0.3.1);

my $sn = Net::Subnets->new;
$sn->subnets( \@subnets );
my $results;
foreach my $address (@addresses) {
    if ( my $subnetref = $sn->check( \$address ) ) {
        $results .= "$address: $$subnetref\n";
    }
    else {
        $results .= "$address: not found\n";
    }
}
print($results);
