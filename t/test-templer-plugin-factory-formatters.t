#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
#  Test we can instantiate the two formatter plugins, and that
# they work.
#
# Steve
# --
#


use strict;
use warnings;

use Test::More qw! no_plan !;




#
#  Load the factory
#
BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Load the plugins.
#
BEGIN {use_ok('Templer::Plugin::Textile');}
require_ok('Templer::Plugin::Textile');

BEGIN {use_ok('Templer::Plugin::Markdown');}
require_ok('Templer::Plugin::Markdown');

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  We should have two plugins registered
#
my @known = $factory->formatters();
is( scalar @known, 2, "There are two known formatters" );

#
#  Get the textile by name
#
isa_ok( $factory->formatter("textile"), "Templer::Plugin::Textile" );
isa_ok( $factory->formatter("TEXTILE"), "Templer::Plugin::Textile" );
isa_ok( $factory->formatter("TEXTile"), "Templer::Plugin::Textile" );

#
#  Get the markdown plugin, by name.
#
isa_ok( $factory->formatter("markdown"), "Templer::Plugin::Markdown" );
isa_ok( $factory->formatter("MARKDOWN"), "Templer::Plugin::Markdown" );
isa_ok( $factory->formatter("MARkdown"), "Templer::Plugin::Markdown" );

#
#  Input testing
#
my $input = "**STRONG**";

if ( $factory->formatter("textile")->available() )
{
    my $t_out = $factory->formatter("textile")->format($input);
    ok( $t_out =~ /class="caps"/i, "Formatting with textile worked" );
}
else
{
    my $t_out = $factory->formatter("textile")->format($input);
    is( $input, $t_out,
        "When disabled the textile plugin didn't modify our text" );
}



if ( $factory->formatter("markdown")->available() )
{
    my $m_out = $factory->formatter("markdown")->format($input);
    ok( $m_out =~ /strong/i, "Formatting with markdown worked" );
}
else
{
    my $m_out = $factory->formatter("markdown")->format($input);
    is( $input, $m_out,
        "When disabled the markdown plugin didn't modify our text" );
}
