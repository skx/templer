#!/usr/bin/perl -w

#
#  Test that the POD we use in our modules is valid.
#


use strict;
use Test::More;
## no critic (Eval)
eval "use Test::Pod 1.00";
## use critic
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;

#
#  Run the test(s).
#
my @poddirs;
if ( -d "t/" )
{
    @poddirs = qw( . );
}
elsif ( -d "../t" )
{
    @poddirs = qw( ../ );
}


all_pod_files_ok( all_pod_files(@poddirs) );
