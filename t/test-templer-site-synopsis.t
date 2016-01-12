#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
# Test that the Templer::Site synopsis code works
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
open( my $pagefile, '>', $tmp . "/input/test.skx" );
print $pagefile "test page";
close( $pagefile);

open( my $assetfile, '>', $tmp . "/input/test.css" );
print $assetfile "test asset";
close( $assetfile);



#
#  Now create the Templer::Site object.
#
my $site = Templer::Site->new( suffix     => ".skx",
                               input      => "$tmp/input",
                               output     => "$tmp/output"
                             );

#
#  Get pages
#
my @pages  = $site->pages();
ok( scalar(@pages) == 1, "one page");

#
#  Get assets
#
my @assets  = $site->assets();
ok( scalar(@assets) == 1, "one asset");
