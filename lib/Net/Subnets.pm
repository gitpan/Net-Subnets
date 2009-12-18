# Copyright (C) 2003-2009, Sebastian Riedel.

package Net::Subnets;

use strict;
use vars qw/$VERSION/;

$VERSION = '1.0';

sub new {
    my $self = shift;
    return bless({}, (ref($self) || $self));
}

sub subnets {
    my ($self, $subnets) = @_;
    my %masks;
    foreach (@$subnets) {
        /^(.+?)\/(.+)$/o;
        my $revmask = 32 - ($2 || 32);
        $self->{subnets}{$revmask}
          {unpack("N", pack("C4", split(/\./, $1))) >> $revmask} = $_;
        $masks{$revmask}++;
    }
    @{$self->{masks}} =
      sort({$masks{$a} <=> $masks{$b}} keys(%masks));
}

sub check {
    my ($self, $address) = @_;
    foreach (@{$self->{masks}}) {
        my $option = unpack("N", pack("C4", split(/\./, $$address))) >> $_;
        if ($self->{subnets}{$_}{$option}) {
            return \($self->{subnets}{$_}{$option});
        }
    }
    return 0;
}

sub range {
    my ($self, $subnet) = @_;
    $$subnet =~ /^(.+?)\/(.+)$/o;
    my $net =
      pack('C4', split(/\./, $1))
      & pack('B*', (1 x $2) . (0 x (32 - ($2 || 32))));
    my $lowip = join('.', unpack('C4', pack('B*', (0 x 31) . 1) | $net));
    my $highip = join('.',
        unpack('C4', pack('B*', (0 x $2) . (1 x (31 - $2)) . 0) | $net));
    if ($2 == 32) {
        return (\$highip, \$highip);
    }
    return (\$lowip, \$highip);
}

sub list {
    my ($self, $lowip, $highip) = @_;
    my $lowint  = unpack("N", pack("C4", split(/\./, $$lowip)));
    my $highint = unpack("N", pack("C4", split(/\./, $$highip)));
    my @list = (join('.', unpack('C4', pack('N', $lowint))));
    while ($lowint lt $highint) {
        push(@list, join('.', unpack('C4', pack('N', ++$lowint))));
    }
    return \@list;
}

1;
__END__

=head1 NAME

Net::Subnets - Computing Subnets In Large Scale Networks

=head1 SYNOPSIS

    use Net::Subnets;
    my $sn = Net::Subnets->new;
    $sn->subnets(\@subnets);
    if (my $subnetref = $sn->check(\$address)) {
        ...
    }
    my ($lowipref, highipref) = $sn->range(\$subnet);
    my $listref = $sn->list(\($lowipref, $highipref));

=head1 DESCRIPTION

Very fast matches large lists of IP addresses against many CIDR subnets and
calculates IP address ranges.

This is a simple and efficient example for subnet matching:

    use Net::Subnets;

    my @subnets   = qw(10.0.0.0/24 10.0.1.0/24);
    my @addresses = qw/10.0.0.1 10.0.1.2 10.0.3.1/;

    my $sn = Net::Subnets->new;
    $sn->subnets(\@subnets);
    my $results;
    foreach my $address (@addresses) {
        if (my $subnetref = $sn->check(\$address)) {
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
        my ($lowipref, $highipref) = $sn->range(\$subnet);
        $results .= "$subnet: $$lowipref - $$highipref\n";
    }
    print( $results );
    
This is a simple example for list generation:
    
    use Net::Subnets;

    my $lowip  = '192.168.0.1';
    my $highip = '192.168.0.100';

    my $sn = Net::Subnets->new;
    my $listref = $sn->list(\($lowip, $highip));
    foreach my $address (@$listref) {
        # do something cool
    }

=head1 METHODS

=head2 C<new>

    my $subnets = Net::Subnets->new;

    Creates an "Net::Subnets" object.

=head2 C<subnets>

    $subnets->subnets([qw(10.0.0.0/24 10.0.1.0/24)]);

    The C<subnets> method lets you prepare a list of CIDR subnets.

=head2 C<check>

    my $match = $subnets->check(\$address);

    The C<check> method lets you check an IP address against the previously
    prepared subnets.

=head2 C<range>

    my ($lowest, $highest) = $subnets->range(\$subnet)

    The C<range> method lets you calculate the IP address range of a subnet.

=head2 C<list>

    my $list = $subnets->list(\$lowest, $highest);

    The C<list> method lets you calculate a list containing all IP addresses
    in a given range.

=head1 AUTHOR

Sebastian Riedel (sri@cpan.org),
Juergen Peters (juergen.peters@taulmarill.de)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2009, Sebastian Riedel.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
