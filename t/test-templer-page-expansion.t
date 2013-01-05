#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
# Test we only expand the variables in a page once.
#
# Steve
#


use strict;
use warnings;

use Test::More qw! no_plan !;


#
#  Simple class is a plugin that appends "BOO" to the value of any key.
#
package Simple::Class;

sub new
{
    my $class = shift;
    bless {}, $class;
}

sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    my %hash = %$data;
    foreach my $key ( keys %hash )
    {
        $hash{ $key } = $hash{ $key } . "BOO";
    }
    return ( \%hash );
}
Templer::Plugin::Factory->new()->register_plugin( "Simple::Class" );




package main;

BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

BEGIN {use_ok('Templer::Site::Page');}
require_ok('Templer::Site::Page');

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  Create a page
#
my $page = Templer::Site::Page->new( "foo"   => "bar",
                                     "title" => "This is the page title." );

ok( $page, "Page found" );
isa_ok( $page, "Templer::Site::Page", "And has the correct type" );

#
#  Get the title, and ensure it is OK.
#
is( $page->field("title"),
    "This is the page title.",
    "The page title matches what we expect" );

#
#  Get the fields - which will be expanded by our plugin.
#
my %updated = $page->fields();
is( $updated{ 'title' },
    "This is the page title.BOO",
    "The field was expanded"
  );
is( $updated{ 'foo' }, "barBOO", "The field was expanded" );

#
#  Repeat to make sure all is still OK.
#
%updated = $page->fields();
is( $updated{ 'title' },
    "This is the page title.BOO",
    "The field was expanded"
  );
is( $updated{ 'foo' }, "barBOO", "The field was expanded" );

