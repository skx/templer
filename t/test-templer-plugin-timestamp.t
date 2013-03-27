#!/usr/bin/perl -Ilib/ -I../lib/
#
#  Test the execution of timestamp plugin.
#
#  NOTE: We have to make a Templer::Page object so that source
# is correct.
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
BEGIN {use_ok('Templer::Plugin::TimeStamp');}
require_ok('Templer::Plugin::TimeStamp');



#
#  Create a config file
#
my $cfg = Templer::Global->new();

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  Create a temporary tree.
#
my $dir = tempdir( CLEANUP => 1 );

#
#  Create a page.
#
open( my $handle, ">", $dir . "/input.wgn" );
print $handle <<EOF;
Title: This is my page title.
myear: timestamp(%Y)
mmon: timestamp(%m)
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

ok( %updated,            "Fetching the fields of the page succeeded" );
ok( $updated{ 'myear' }, "The fields contain a year-reference" );
ok( $updated{ 'mmon' },  "The fields contain a year-reference" );

#
#  The year + month from the expanded template
#
my $myear = $updated{ 'myear' };
my $mmon  = $updated{ 'mmon' };
$mmon =~ s/^0//g;


#
#  Get the current year/month/day, etc, to compare with the
# plugin-found values.
#
my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
$year += 1900;
$mon  += 1;


#
#  Is all OK?
#
is( $myear, $year, "The year is correct" );
is( $mmon,  $mon,  "The month is correct" );



#
# All done.
#
