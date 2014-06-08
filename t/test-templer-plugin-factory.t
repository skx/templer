#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
#  Test we can load our singleton class-factory, and
# register/fetch a trivial class with it.
#
# Steve
#


use strict;
use warnings;

use Test::More qw! no_plan !;


#
#  Simple class is just a class that has a new() method / constructor
# we can stash away and retrieve.
#
package Simple::Class;

sub new
{
    my $class = shift;
    bless {}, $class;
}

sub hello
{
    return "world";
}




package main;

BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

my $factory2 = Templer::Plugin::Factory->new();
ok( $factory2, "Loaded the factory object." );
isa_ok( $factory2, "Templer::Plugin::Factory" );

is( $factory, $factory2, "Our singleton is a singleton" );

#
#  The plugins are auto-loaded, so we'll have formatters.
#
my @known = $factory->formatters();
is( scalar @known, 4, "There are four known formatters" );

#
#  Register a formatter.
#
$factory->register_formatter( "tmp", "Simple::Class" );
@known = $factory->formatters();
is( scalar @known, 5, "There is now another formatter." );


#
#  Get the formatter by name, testing that mixed case works
#
foreach my $name (qw! tmp TMP tMp !)
{
    my $f = $factory->formatter($name);
    isa_ok( $f, "Simple::Class", "Fetching the plugin by name - $name" );
    is( $f->hello(), "world", "The stub class behaves as expected" );
}

#
#  TODO: Variable-Plugin tests.
#
