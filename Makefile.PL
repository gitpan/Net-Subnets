#!/usr/bin/env perl

# Copyright (C) 2003-2009, Sebastian Riedel.

use strict;
use warnings;

use ExtUtils::MakeMaker;

my $mm = $ExtUtils::MakeMaker::VERSION;

# Son, when you participate in sporting events,
# it's not whether you win or lose, it's how drunk you get.
WriteMakefile(
    NAME         => 'Net::Subnets',
    AUTHOR       => 'Sebastian Riedel (sri@cpan.org)',
    VERSION_FROM => 'lib/Net/Subnets.pm',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008001'},
                resources => {
                    license => 'http://dev.perl.org/licenses/',
                    repository =>
                      'http://github.com/kraih/net-subnets/tree/master'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),

    PREREQ_PM => {'ExtUtils::MakeMaker' => 0, 'Test::More' => 0}
);
