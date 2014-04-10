#!/usr/bin/perl -Ilib/ -I../lib/ -w
#
#  Test we can instantiate the known filter-plugins, and that
# they work when Templer::Site use HTTML::Template.
#
# Bruno
#

use strict;
use warnings;

use Test::More qw! no_plan !;
use Test::Exception;
use File::Temp qw! tempdir !;

#
#  Load the factory
#
BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Load the filter plugins.
#
BEGIN {use_ok('Templer::Plugin::Dollar');}
require_ok('Templer::Plugin::Dollar');

BEGIN {use_ok('Templer::Plugin::Strict');}
require_ok('Templer::Plugin::Strict');

#
#  Load the Template engine
#
BEGIN {use_ok('HTML::Template');}
require_ok('HTML::Template');

#
#  Load the site manager
#
BEGIN {use_ok('Templer::Site');}
require_ok('Templer::Site');

BEGIN {use_ok('Templer::Site::Page');}
require_ok('Templer::Site::Page');

BEGIN {use_ok('Templer::Site::Asset');}
require_ok('Templer::Site::Asset');

#
#  Instantiate the helper.
#
my $factory = Templer::Plugin::Factory->new();
ok( $factory, "Loaded the factory object." );
isa_ok( $factory, "Templer::Plugin::Factory" );

#
#  We should have only a small number of known plugins registered.
#
my @known = $factory->filters();
is( scalar @known, 2, "There are only two filter" );

#
#  The names are what we expect.
#
my @sorted = sort(@known);
is( $sorted[0], "dollar", "The first is Dollar" );
is( $sorted[1], "strict", "The second is Strict" );

#
#  Get the Dollar plugin by name, testing that case sensitivity
#  isn't important.
#
isa_ok( $factory->filter("dollar"), "Templer::Plugin::Dollar" );
isa_ok( $factory->filter("DOLLAR"), "Templer::Plugin::Dollar" );
isa_ok( $factory->filter("DollaR"), "Templer::Plugin::Dollar" );

#
#  Unknown plugins are an error
#
foreach my $name (qw! fake test missing unknown !)
{
    ok( !$factory->filter($name), "Unknown plugin fails: $name" );
}

#
#  Attempting to load a plugin with a missing name is an error.
#
dies_ok( sub {$factory->filter(undef)}, "Missing plugin-name causes die()" );
dies_ok( sub {$factory->filter("")},    "Missing plugin-name causes die()" );

#
#  Dollar filter testing
#
my $input = '${title escape=html} ${author} ${email escape="url"}';
my $h_out = $factory->filter("dollar")->filter($input);
my $h_exp =
  '<tmpl_var name="title" escape=html> <tmpl_var name="author"> <tmpl_var name="email" escape="url">';

ok( $factory->filter("dollar")->available(),
    "Dollar Filter is always available" );
is( $h_out, $h_exp, "Dollar filter make correct change" );

#
#  Strict filter testing
#
$input = '<tmpl_var name="title"/> <tmpl_else/> <tmpl_include NAME="foo"/>';
$h_out = $factory->filter("strict")->filter($input);
$h_exp = '<tmpl_var name="title"> <tmpl_else> <tmpl_include NAME="foo">';

ok( $factory->filter("strict")->available(),
    "Strict Filter is always available" );
is( $h_out, $h_exp, "Strict filter make correct change" );

#
#  Create a temporary tree.
#
my $dir = tempdir( CLEANUP => 1 );
mkdir "$dir/input";
mkdir "$dir/layouts";

#
#  Create a template file.
#
open( my $handle, ">", $dir . "/layouts/default.layout" );
print $handle <<EOF;
<title><tmpl_var name="title"/></title>
<meta name='author' content='\${author}'/>
\${content}
EOF
close($handle);

#
#  Create an input page.
#
open( $handle, ">", $dir . "/input/index.skx" );
print $handle <<EOF;
Title: A simple title
Author: Someone
Body: Something inside
template-filter: dollar, strict
----
\${body}
EOF
close($handle);

#
#  Instantiate a site
#
my %data = ( "in-place"     => 0,
             "include-path" => "$dir/includes",
             "input"        => "$dir/input/",
             "layout"       => "default.layout",
             "layout-path"  => "$dir/layouts",
             "output"       => "$dir/output/",
             "plugin-path"  => "$dir/plugins",
             "suffix"       => ".skx",
             "verbose"      => 0,
             "debug"        => 0,
             "force"        => 0,
           );
my $site = Templer::Site->new(%data);
ok( $site, "Loaded the site object." );
isa_ok( $site, "Templer::Site" );

#
#  Build site process should use template filters in template as well as page
#  content
#
$site->init();
$site->build();

local $/ = undef;
open( $handle, "<", $dir . "/output/index.html" );
$h_out = <$handle>;
close($handle);

$h_exp = <<EOF;
<title>A simple title</title>
<meta name='author' content='Someone'/>
Something inside

EOF

is( $h_out, $h_exp, "Site building filters template correctly" );
