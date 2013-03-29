#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
#  Test we can instantiate the known formatter-plugins, and that
# they work.
#
# Steve
# --
#


use strict;
use warnings;

use Test::More qw! no_plan !;
use Test::Exception;



#
#  Load the factory
#
BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Load the formatter plugins.
#
BEGIN {use_ok('Templer::Plugin::HTML');}
require_ok('Templer::Plugin::HTML');

BEGIN {use_ok('Templer::Plugin::Markdown');}
require_ok('Templer::Plugin::Markdown');

BEGIN {use_ok('Templer::Plugin::Perl');}
require_ok('Templer::Plugin::Perl');

BEGIN {use_ok('Templer::Plugin::Textile');}
require_ok('Templer::Plugin::Textile');




#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  We should have only a small number of known plugins registered.
#
my @known = $factory->formatters();
is( scalar @known, 4, "There are four known formatters" );

#
# The names are what we expect.
#
my @sorted = sort(@known);
is( $sorted[0], "html",     "The first is HTML" );
is( $sorted[1], "markdown", "The second is markdown" );
is( $sorted[2], "perl",     "The third is markdown" );
is( $sorted[3], "textile",  "The fourth is textile" );


#
#  Get the HTML plugin by name, testing that case sensitivity
# isn't important.
#
isa_ok( $factory->formatter("html"), "Templer::Plugin::HTML" );
isa_ok( $factory->formatter("HTML"), "Templer::Plugin::HTML" );
isa_ok( $factory->formatter("htML"), "Templer::Plugin::HTML" );

#
#  Get the markdown plugin by name, testing that case sensitivity
# isn't important.
#
isa_ok( $factory->formatter("markdown"), "Templer::Plugin::Markdown" );
isa_ok( $factory->formatter("MARKDOWN"), "Templer::Plugin::Markdown" );
isa_ok( $factory->formatter("MARkdown"), "Templer::Plugin::Markdown" );

#
#  Get the perl plugin by name, testing that case sensitivity
# isn't important.
#
isa_ok( $factory->formatter("perl"), "Templer::Plugin::Perl" );
isa_ok( $factory->formatter("PERl"), "Templer::Plugin::Perl" );
isa_ok( $factory->formatter("PERL"), "Templer::Plugin::Perl" );

#
#  Get the textile plugin by name, testing that case sensitivity
# isn't important.
#
isa_ok( $factory->formatter("textile"), "Templer::Plugin::Textile" );
isa_ok( $factory->formatter("TEXTILE"), "Templer::Plugin::Textile" );
isa_ok( $factory->formatter("TEXTile"), "Templer::Plugin::Textile" );



#
#  Unknown plugins are an error
#
foreach my $name (qw! fake test missing unknown !)
{
    ok( !$factory->formatter($name), "Unknown plugin fails: $name" );
}


#
#  Attempting to load a plugin with a missing name is an error.
#
dies_ok( sub {$factory->formatter(undef)}, "Missing plugin-name causes die()" );
dies_ok( sub {$factory->formatter("")},    "Missing plugin-name causes die()" );


#
#  Input testing
#
my $input = "**STRONG** The number is {42}.";
my $h_out = $factory->formatter("html")->format($input);
my $m_out = $factory->formatter("markdown")->format($input);
my $p_out = $factory->formatter("perl")->format($input);
my $t_out = $factory->formatter("textile")->format($input);


#
#  The HTML formatter won't make any changes.
#
ok( $factory->formatter("html")->available(),
    "HTML Formatter is always available" );
is( $input, $h_out, "HTML formatter resulted in no changes" );


#
#  Markdown
#
if ( $factory->formatter("markdown")->available() )
{
    ok( $m_out =~ /strong/i, "Formatting with markdown worked" );
}
else
{
    is( $input, $m_out,
        "When disabled the markdown plugin didn't modify our text" );
}


#
#  Perl
#
if ( $factory->formatter("perl")->available() )
{
    ok( $p_out =~ / 42\./, "Formatting with perl worked" );
}
else
{
    is( $input, $m_out,
        "When disabled the perl plugin didn't modify our text" );
}



#
#  Textile
#
if ( $factory->formatter("textile")->available() )
{
    ok( $t_out =~ /class="caps"/i, "Formatting with textile worked" );
}
else
{
    is( $input, $t_out,
        "When disabled the textile plugin didn't modify our text" );
}

