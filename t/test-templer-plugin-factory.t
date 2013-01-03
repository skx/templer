#!/usr/bin/perl -Ilib/ -I../lib/ -w

use strict;
use warnings;

use Test::More qw! no_plan !;


#
#  Simple class is just a class that has a new() method / constructor
# we can stash away and retrieve.
#
package Simple::Class;
sub new {
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
ok( $factory , "Loaded the factory object.");
isa_ok( $factory, "Templer::Plugin::Factory" );

my $factory2=  Templer::Plugin::Factory->new();
ok( $factory2 , "Loaded the factory object.");
isa_ok( $factory2, "Templer::Plugin::Factory" );

is( $factory, $factory2, "Our singleton is a singleton" );

#
#  No plugins registered
#
my @known = $factory->formatters();
is( scalar @known, 0 , "There are no known formatters" );

#
#  Register a formatter.
#
$factory->register_formatter( "tmp", "Simple::Class" );
@known = $factory->formatters();
is( scalar @known, 1 , "There is now one known formatters" );


#
#  Get the formatter by name
#
my $f = $factory->formatter( "tmp" );
isa_ok( $f, "Simple::Class" );


#
#  TODO: Variable-Plugin tests.
#
is( $f->hello(), "world", "The stub class behaves as expected" );
