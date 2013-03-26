#!/usr/bin/perl -Ilib/ -I../lib/
#
#  Test the execution of RootPath plugin.
#
# Steve
# --



use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw! tempdir !;

#
#  Load the factory
#
BEGIN {use_ok('Templer::Global');}
require_ok('Templer::Global');
BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Load the plugin + dependency
#
BEGIN {use_ok('Templer::Site::Page');}
require_ok('Templer::Site::Page');
BEGIN {use_ok('Templer::Plugin::RootPath');}
require_ok('Templer::Plugin::RootPath');



#
#  Create a temporary tree.
#
my $dir = tempdir( CLEANUP => 1 );

#
#  Create a config file
#
my $cfg = Templer::Global->new( input => $dir );

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  Create a page.
#
open( my $handle, ">", $dir . "/input.wgn" );
print $handle <<EOF;
Title: This is my page title.
css: path_to(css)
----

This is my page content.

EOF
close($handle);

#
#  Create the page
#
my $page = Templer::Site::Page->new( file => $dir . "/input.wgn" );
ok( $page, "We created a page object" );
isa_ok( $page, "Templer::Site::Page", "Which has the correct type" );


#
#  Get the title to be sure
#
is( $page->field("title"),
    "This is my page title.",
    "The page has the correct title" );

#
#  Get the data, after plugin-expansion
#
my %original = $page->fields();
my $ref      = $factory->expand_variables( $cfg, $page, \%original );
my %updated  = %$ref;

ok( %updated,        "Fetching the fields of the page succeeded" );
ok( $updated{'css'}, "There is a path_to(css) variable" );
is( $updated{'css'}, "/css", "Which has the right value" );

#
# All done.
#
