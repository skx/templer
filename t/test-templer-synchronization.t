#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
# Test that the Templer::Site::sync method will do the right
# thing.
#
# Bruno
#

use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw! tempdir !;
use File::Path qw! mkpath !;

#
# Load needed objects
#
BEGIN {use_ok('Templer::Site');}
require_ok('Templer::Site');

BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

BEGIN {use_ok('Templer::Site::Page');}
require_ok('Templer::Site::Page');

BEGIN {use_ok('Templer::Site::Asset');}
require_ok('Templer::Site::Asset');

#
# Make a temporary directory
#
my $tmp = tempdir( CLEANUP => 0 );
ok( -d $tmp, "We created a temporary directory" );
note("Temporary directory is: $tmp");

#
# Make the input-subdirectory
#
File::Path::mkpath( $tmp . "/input", { verbose => 0, mode => oct(755) } );
ok( -d $tmp . "/input", "We created an input/ directory" );

#
# Create a layout file.
#
File::Path::mkpath( $tmp . "/layouts", { verbose => 0, mode => oct(755) } );
ok( -d $tmp . "/layouts", "We created a layouts directory" );

open( my $handle, ">", $tmp . "/layouts/default.layout" );
print $handle <<EOF;
<title><tmpl_var name="title"/></title>
EOF
close($handle);
ok( -f $tmp . "/layouts/default.layout", "We created a layout file" );

#
# Create a page
#
open( $handle, ">", $tmp . "/input/index.skx" );
print $handle <<EOF;
Title: This is my page title.
----
This is my page content.
EOF
close($handle);
ok( -f $tmp . "/input/index.skx", "We created a source page" );

#
# Create some assets
#
createFile( $tmp . "/input/logo.png" );
createFile( $tmp . "/input/.htaccess" );

#
#  Now create the Templer::Site object.
#
my %data = ( "in-place"     => 0,
             "include-path" => "$tmp/includes",
             "input"        => "$tmp/input/",
             "layout"       => "default.layout",
             "layout-path"  => "$tmp/layouts",
             "output"       => "$tmp/output/",
             "plugin-path"  => "$tmp/plugins",
             "suffix"       => ".skx",
             "verbose"      => 0,
             "debug"        => 0,
             "force"        => 0,
             "sync"         => 1,
           );
my $site = Templer::Site->new(%data);
isa_ok( $site, "Templer::Site" );

#
# Setup the output directory, etc.
#
$site->init();
ok( -d "$tmp/output", "The output directory was created" );

#
# Create garbage directory
#
File::Path::mkpath( $tmp . "/output/garbage",
                    { verbose => 0, mode => oct(755) } );
ok( -d $tmp, "We created an output/garbage empty directory" );

#
# Create garbage file
#
createFile( $tmp . "/output/garbage.png" );
ok( -e $tmp . "/output/garbage.png", "We created an output/garbage file" );

#
# Generate everything
#
$site->build();
$site->copyAssets();
$site->sync();

ok( -e $tmp . "/output/index.html", "Page generated correctly" );
ok( -e $tmp . "/output/logo.png",   "Asset copied successfully" );
ok( -e $tmp . "/output/.htaccess",  "Asset copied successfully" );
ok( !-e $tmp . "/garbage.png",      "Garbage file removed correctly" );
ok( !-e $tmp . "/garbage",          "Garbage directory removed correctly" );


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
