package Net::Subnets;

use strict;
use vars qw($VERSION);

$VERSION = '0.14';

sub new { bless( {} ) }

sub subnets {
    my ( $self, $subnets ) = @_;
    my %masks;
    foreach (@$subnets) {
        /^(.+?)\/(.+)$/o;
        my $host    = $1;
        my $mask    = $2;
        my $revmask = 32 - ( $mask || 32 );
        $self->{subnets}
          { unpack( "N", pack( "C4", split( /\./, $host ) ) ) >> $revmask } =
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

1;
__END__

=head1 NAME

Net::Subnets - Match large lists of IP addresses against many CIDR subnets

=head1 SYNOPSIS

    use Net::Subnets;
    my $sn = Net::Subnets->new;
    $sn->subnets(\@subnets);
    if (my $subnetref = $sn->check(\$address)) {
        ...
    }

=head1 DESCRIPTION

Very fast matches large lists of IP addresses against many CIDR subnets.

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

This is a simple and efficient example:

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

=head1 AUTHOR

Sebastian Riedel (sri@cpan.org),
Juergen Peters (juergen.peters@taulmarill.de)

=head1 COPYRIGHT

Copyright 2003 Sebastian Riedel & Juergen Peters. All rights reserved.

This library is free software. You can redistribute it and/or
modify it under the same terms as perl itself.

=cut
