#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
# Test we can create a new site.
#
# Steve
#


use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw! tempdir !;


package main;

BEGIN {use_ok('Templer::Site::New');}
require_ok('Templer::Site::New');

#
#  Instantiate the helper.
#
my $helper = Templer::Site::New->new();
ok( $helper, "Created the helper object." );
isa_ok( $helper, "Templer::Site::New", "It is the correct type" );

#
#  Create a temporary directory to work with.
#
my $dir = tempdir( CLEANUP => 1 );
ok( -d $dir, "Created temporary directory" );

foreach my $file (
    qw! input input/index.wgn input/about.wgn input/robots.txt templer.cfg layouts/default.layout !
  )
{
    ok( !-e $dir . "/" . $file, "The input directory doesn't have: $file" );
}

#
#  Create the site
#
ok( $helper->create($dir), "Creating the new site succeeded" );


#
#  Test it appeared
#
foreach my $file (
    qw! input input/index.wgn input/about.wgn input/robots.txt templer.cfg layouts/default.layout !
  )
{
    ok( -e $dir . "/" . $file, "The file now exists: $file" );
}

#
# All done.
#
