use strict;
use Test::Simple tests => 4;
use Net::Subnets;

my @subnets   = qw(10.0.0.0/24 10.0.1.0/24);
my @good_addr = qw(10.0.0.1 10.0.1.2);
my @bad_addr  = qw(10.0.3.4 20.0.0.1);

my $sn = Net::Subnets->new;
$sn->subnets( \@subnets );

foreach my $addr (@good_addr) {
    ok( $sn->check( \$addr ) );
}

foreach my $addr (@bad_addr) {
    ok( !$sn->check( \$addr ) );
}