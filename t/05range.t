#!/usr/bin/env perl

# Copyright (C) 2003-2010, Sebastian Riedel.

use strict;
use warnings;

use Test::Simple tests => 2;

use Net::Subnets;

my @subnets = qw(10.0.0.0/24 10.0.1.4/32);
my @lowips  = qw(10.0.0.1 10.0.1.4);
my @highips = qw(10.0.0.254 10.0.1.4);

my $sn = Net::Subnets->new;
for (my $i = 0; $i <= $#subnets; $i++) {
    my ($lowip, $highip) = $sn->range(\$subnets[$i]);
    ok((($lowips[$i] eq $$lowip) && ($highips[$i] eq $$highip)));
}
