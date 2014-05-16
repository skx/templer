#!/usr/bin/perl -Ilib/ -I../lib/
#
#  Test the execution of RootPath plugin.
#
# Bruno
# --

use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw! tempdir !;

#
#  Load the factory
#
BEGIN {use_ok('Templer::Site');}
require_ok('Templer::Site');
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
#  Create a site object.
#
my $site = Templer::Site->new( input => $dir );
$site->init();

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  Create a source file at root level
#
open( my $handle, ">", $dir . "/input.skx" );
print $handle <<EOF;
title: a title
root: path_to()
css: path_to(css)
----
This is my page content.
EOF
close($handle);

#
#  Create a source file at level 1 from root
#
mkdir("$dir/1");
open( $handle, ">", $dir . "/1/input.skx" );
print $handle <<EOF;
root: path_to()
css: path_to(css)
----
This is my page content.
EOF
close($handle);

#
#  Create first page and ensure title is there
#
my $page0 = Templer::Site::Page->new( file => $dir . "/input.skx" );
ok( $page0, "We created a page object at root level" );
isa_ok( $page0, "Templer::Site::Page", "  Which has the correct type:" );
is( $page0->field("title"), "a title", "  ...and the correct title" );

#
#  Get the data, after plugin-expansion for page at root level
#
my %original = $page0->fields();
my $ref      = $factory->expand_variables( $site, $page0, \%original );
my %updated  = %$ref;

ok( %updated,          "Fetching the fields of the first page succeeded" );
ok( $updated{ 'css' }, "There is a path_to(css) variable" );
is( $updated{ 'css' }, "./css", "  Which has the right value" );
ok( $updated{ 'root' }, "There is a path_to web root" );
is( $updated{ 'root' }, ".", "  Which has the right value" );

#
#  Create second page and ensure title is there
#
my $page1 = Templer::Site::Page->new( file => $dir . "/1/input.skx" );
ok( $page1, "We created a page object at level 1 from root" );
isa_ok( $page1, "Templer::Site::Page", "  Which has the correct type:" );

#
#  Get the data, after plugin-expansion for page at level 1
#
%original = $page1->fields();
$ref      = $factory->expand_variables( $site, $page1, \%original );
%updated  = %$ref;

ok( %updated,          "Fetching the fields of the second page succeeded" );
ok( $updated{ 'css' }, "There is a path_to(css) variable" );
is( $updated{ 'css' }, "../css", "  Which has the right value" );
ok( $updated{ 'root' }, "There is a path_to web root" );
is( $updated{ 'root' }, "..", "  Which has the right value" );

#
# All done.
#
