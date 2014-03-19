#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
# Test that the Templer::Site::copyAssets method will do the right
# thing.
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
BEGIN {use_ok('Templer::Site::Asset');}
require_ok('Templer::Site::Asset');



#
#  Make a temporary directory
#
my $tmp = tempdir( CLEANUP => 1 );
ok( -d $tmp, "We created a temporary directory" );
note("Temporary directory is: $tmp");

#
#  Make the input-subdirectory
#
File::Path::mkpath( $tmp . "/input", { verbose => 0, mode => oct(755) } );
ok( -d $tmp, "We created an input/ directory" );

#
#  Create some assets.
#
createFile( $tmp . "/input/index.skx" );
createFile( $tmp . "/input/logo.png" );
createFile( $tmp . "/input/.htaccess" );
createFile( $tmp . "/input/it's ugly.png" );
createFile( $tmp . '/input/it'."'".'s ugly\.png' );
createFile( $tmp . '/input/it'."'".'s ugly".png' );
createFile( $tmp . '/input/it'."'".'s ugly$.png' );
createFile( $tmp . '/input/it'."'".'s ugly`.png' );
createFile( $tmp . '/input/it"s ugly.png' );

#
#  Now create the Templer::Site object.
#
my $site = Templer::Site->new( input  => "$tmp/input/",
                               output => "$tmp/output",
                               suffix => ".skx",
                             );


#
# Setup the output directory, etc.
#
$site->init();
ok( -d "$tmp/output", "The output directory was created" );

#
# Copy the assets from input/ to output/
#
$site->copyAssets();


ok( -e $tmp . "/output/logo.png",             "Asset copied successfully" );
ok( -e $tmp . "/output/.htaccess",            "Asset copied successfully" );
ok( -e $tmp . "/output/it's ugly.png",        "Asset copied successfully" );
ok( -e $tmp . '/output/it'."'".'s ugly\.png', "Asset copied successfully" );
ok( -e $tmp . '/output/it'."'".'s ugly".png', "Asset copied successfully" );
ok( -e $tmp . '/output/it'."'".'s ugly$.png', "Asset copied successfully" );
ok( -e $tmp . '/output/it'."'".'s ugly`.png', "Asset copied successfully" );
ok( -e $tmp . '/output/it"s ugly.png',        "Asset copied successfully" );
ok( !-e $tmp . "/output/index.skx",           "Page source not copied" );


sub createFile
{
    my ($file) = (@_);

    ok( !-e $file, "The file didn't exist prior to creation" );

    note("File to be created is : $file");

    open( my $handle, ">", $file ) or
      die "Failed to write: $file - $!";
    print $handle "\n";
    close($handle);

    ok( -e $file, "The file was created" );
}
