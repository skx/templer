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


#
#  Load the module.
#
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


#
#  These are the files/directories we expect to be created.
#
#  The hash-values are the type of created thing we expect:
#
#    1   =>  Directory.
#    0   =>  File.
my %EXPECTED = (
    "input"                  => 1,
    "output"                 => 1,
    "includes"               => 1,
    "layouts"                => 1,
    "input/index.wgn"        => 0,
    "input/about.wgn"        => 0,
    "input/robots.txt"       => 0,
    "layouts/default.layout" => 0,
    "templer.cfg"            => 0,

               );



#
#  Test that the entries don't exist at the moment.
#
foreach my $file ( sort keys %EXPECTED )
{
    ok( !-e $dir . "/" . $file,
        "Before the site was constructed file was missing: $file" );
}


#
#  Now create the new site.
#
ok( $helper->create($dir), "Creating the new site succeeded" );


#
#  Test that they were present
#
foreach my $file ( sort keys %EXPECTED )
{
    my $type = $EXPECTED{ $file };

    ok( -e $dir . "/" . $file, "File created, as expected: $file" );

    if ( $type == 0 )
    {
        ok( !-d $dir . "/" . $file, "Entry is a file - $file" );
    }
    elsif ( $type == 1 )
    {
        ok( -d $dir . "/" . $file, "Entry is a directory - $file" );
    }
    else
    {
        ok( undef, "The test-type made no sense" );
    }
}

#
# All done.
#
