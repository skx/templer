#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
# Test that the Templer::Site init method will create an
# output directory if it is missing.
#
# Steve
#


use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw! tempdir !;
use File::Path qw! mkpath !;


BEGIN {use_ok('Templer::Site');}
require_ok('Templer::Site');


#
#  Make a temporary directory
#
my $tmp = tempdir( CLEANUP => 1 );
ok( -d $tmp, "We created a temporary directory" );

#
#  Make the input-subdirectory
#
File::Path::mkpath( $tmp . "/input", { verbose => 0, mode => oct(755) } );
ok( -d $tmp, "We created an input/ directory" );

#
#  Now create the Templer::Site object.
#
my $site = Templer::Site->new( input      => "$tmp/input",
                               "in-place" => 1,
                               output     => "$tmp/output"
                             );

ok( !-d "$tmp/output",
    "Before running Templer::Site::init the output directory is missing" );
$site->init();
ok( !-d "$tmp/output", "After running Templer::Site::init in-place worked" );

#
#  Now do it again, but without the in-place mode set.
#
$site = Templer::Site->new( input  => "$tmp/input",
                            output => "$tmp/output" );

ok( !-d "$tmp/output",
    "Before running Templer::Site::init the output directory is missing" );
$site->init();
ok( -d "$tmp/output",
    "After running Templer::Site::init the output directory is created." );
