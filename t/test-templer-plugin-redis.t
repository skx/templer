#!/usr/bin/perl -Ilib/ -I../lib/
#
# Test the Redis plugin.
#
# This test assumes that redis is installed and running on the localhost.
#
# Steve
# --



use strict;
use warnings;

use Test::More qw ! no_plan !;
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
BEGIN {use_ok('Templer::Plugin::Redis');}
require_ok('Templer::Plugin::Redis');


#
#  Should we skip?
#
my $skip = 0;


#
#  Ensure that we have Redis installed.
#
## no critic (Eval)
eval "use Redis";
## use critic
$skip = 1 if ($@);


#
# Connect to redis
#
my $redis;
eval {$redis = new Redis();};
$skip = 1 if ($@);
$skip = 1 unless ($redis);
$skip = 1 unless ( $redis && $redis->ping() );


if ($skip)
{
    plan skip_all => "Redis must be running on localhost";
}

#
#  Create a config file
#
my $site = Templer::Site->new();

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
Title: This is my redis-page title.
count: redis_get( "steve.kemp" );
----

This is my page content.

EOF
close($handle);


#
#  See if there is an existing value for the redis key "steve.kemp"
#
my $val = $redis->get("steve.kemp");

#
#  Set a known-value either way.
#
$redis->set( "steve.kemp", "is.me" );

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
    "This is my redis-page title.",
    "The page has the correct title"
  );

#
#  Get the data, after plugin-expansion, which should mean that the
# count is populated to something.
#
my %original = $page->fields();
my $ref      = $factory->expand_variables( $site, $page, \%original );
my %updated  = %$ref;

ok( %updated,            "Fetching the fields of the page succeeded" );
ok( $updated{ 'count' }, "The fields contain a count reference" );
is( $updated{ 'count' }, "is.me", "The field has the correct value" );

#
#  If there was previously a value, reset it.
#
if ($val)
{
    $redis->set( "steve.kemp", $val );
}
else
{

    #
    #  Otherwise cleanup
    #
    $redis->del("steve.kemp");
}


#
# All done.
#
