package Net::Subnets;

use strict;
use vars qw($VERSION);

$VERSION = '0.16';

sub new { bless( {} ) }

sub subnets {
    my ( $self, $subnets ) = @_;
    my %masks;
    foreach (@$subnets) {
        /^(.+?)\/(.+)$/o;
        my $revmask = 32 - ( $2 || 32 );
        $self->{subnets}
          { unpack( "N", pack( "C4", split( /\./, $1 ) ) ) >> $revmask } =
          $_;
        $masks{$revmask}++;
    }
    @{ $self->{masks} } =
      sort( { $masks{$a} <=> $masks{$b} } keys(%masks) );
}

sub check {
    my ( $self, $address ) = @_;
    foreach ( @{ $self->{masks} } ) {
        my $option =
          unpack( "N", pack( "C4", split( /\./, $$address ) ) ) >> $_;
        if ( $self->{subnets}{$option} ) {
            return \( $self->{subnets}{$option} );
        }
    }
    return 0;
}

sub range {
    my ( $self, $subnet ) = @_;
    $$subnet =~ /^(.+?)\/(.+)$/o;
    my $net =
      pack( 'C4', split( /\./, $1 ) ) &
      pack( 'B*', ( 1 x $2 ) . ( 0 x ( 32 - ( $2 || 32 ) ) ) );
    my $lowip =
      join( '.', unpack( 'C4', pack( 'B*', ( 0 x 31 ) . 1 ) | $net ) );
    my $highip = join(
        '.',
        unpack(
            'C4', pack( 'B*', ( 0 x $2 ) . ( 1 x ( 31 - $2 ) ) . 0 ) | $net
        )
    );
    if ( $2 == 32 ) {
        return ( \$highip, \$highip );
    }
    return ( \$lowip, \$highip );
}

1;
__END__

=head1 NAME

Net::Subnets - Computing subnets in large scale networks

=head1 SYNOPSIS

    use Net::Subnets;
    my $sn = Net::Subnets->new;
    $sn->subnets(\@subnets);
    if (my $subnetref = $sn->check(\$address)) {
        ...
    }
    my ($lowipref, highipref) = $sn->range(\$subnet);

=head1 DESCRIPTION

Very fast matches large lists of IP addresses against many CIDR subnets and
calculates IP address ranges.

The following functions are provided by this module:

    new()
        Creates an "Net::Subnets" object.
        It takes no arguments.

    subnets(\@subnets)
        The subnets() function lets you prepare a list of CIDR subnets.
        It takes an array reference.

    check(\$address)
        The check() function lets you check an IP address against the
        previously prepared subnets.
        It takes a scalar reference and returns a scalar reference to
        the first matching CIDR subnet.

    range(\$subnet)
        The range() function lets you calculate the IP address range
        of a subnet.
        It takes a scalar reference and returns two scalar references to
        the lowest and highest IP address.

This is a simple and efficient example for subnet matching:

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

This is a simple example for range calculation:

    use Net::Subnets;

    my @subnets = qw(10.0.0.0/24 10.0.1.0/24);

    my $sn = Net::Subnets->new;
    my $results;
    foreach my $subnet (@subnets) {
        my ($lowipref, $highipref) = $sn->range($subnet);
        $results .= "$subnet: $$lowipref - $$highipref\n";
    }
    print($results);

=head1 AUTHOR

Sebastian Riedel (sri@cpan.org),
Juergen Peters (juergen.peters@taulmarill.de)

=head1 COPYRIGHT

Copyright 2003 Sebastian Riedel & Juergen Peters. All rights reserved.

This library is free software. You can redistribute it and/or
modify it under the same terms as perl itself.

=cut
