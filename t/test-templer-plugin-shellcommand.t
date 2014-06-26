#!/usr/bin/perl -Ilib/ -I../lib/
#
#  Test the execution of shell commands via our plugin.
#
# Steve
# --



use strict;
use warnings;

use Test::More qw! no_plan !;

#
#  Load the factory
#
BEGIN {use_ok('Templer::Site');}
require_ok('Templer::Site');
BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Load the plugin.
#
BEGIN {use_ok('Templer::Plugin::ShellCommand');}
require_ok('Templer::Plugin::ShellCommand');



#
#  The config object
#
my $site = Templer::Site->new();


#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  The test data we have.
#
my %input = ( "title" => "This is my page title.",
              "foo"   => "run_command( /bin/ls /etc )",
              "bar"   => "baz"
            );

SKIP:
{
    skip "/bin/ls was not found." unless ( -x "/bin/ls" );

    #
    #  Expand the variables
    #
    my $ref = $factory->expand_variables( $site, undef, \%input );
    ok( $ref, "Calling the plugin returned something sane." );

    #
    #  Get the updated values which we expect to be unchanged.
    #
    is( $ref->{ 'title' },
        "This is my page title.",
        "After calling the plugin the sane value is unchanged." );

    is( $ref->{ 'bar' },
        "baz", "After calling the plugin the sane value is unchanged." );

    #
    #  Now see if our "foo" value was replaced by the output of the shell
    # command.
    #
    my $shell = $ref->{ 'foo' };
    ok( length($shell), "The shell command execution returned something." );
    ok( $shell =~ /passwd/,    "Which looks a little sane." );
    ok( $shell =~ /fstab/,     "And a little more sane." );
}
