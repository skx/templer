#!/usr/bin/perl -Ilib/ -I../lib/
#
#  Test the execution of file-globbing command via our plugin.
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
BEGIN {use_ok('Templer::Site');}
require_ok('Templer::Site');
BEGIN {use_ok('Templer::Plugin::Factory');}
require_ok('Templer::Plugin::Factory');

#
#  Load the plugin + dependency
#
BEGIN {use_ok('Templer::Site::Page');}
require_ok('Templer::Site::Page');
BEGIN {use_ok('Templer::Plugin::FileGlob');}
require_ok('Templer::Plugin::FileGlob');



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
Title: This is my page title.
Files: file_glob( foo/* );
----

This is my page content.

EOF
close($handle);


#
#  Now create some files.
#
mkdir("$dir/foo");
createFile( $dir . "/foo/foo.txt" );
createFile( $dir . "/foo/ok.txt" );
createFile( $dir . "/foo/bar.txt" );
createFile( $dir . "/foo/bar" );

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
my $ref      = $factory->expand_variables( $site, $page, \%original );
my %updated  = %$ref;

ok( %updated,            "Fetching the fields of the page succeeded" );
ok( $updated{ 'files' }, "The fields contain a file reference" );

foreach my $obj ( @{ $updated{ 'files' } } )
{
    ok( $obj->{ 'file' }, "The file reference has a name" );
    ok( $obj->{ 'file' } =~ m{^foo/}, "The file reference is sane" );
    if ( $obj->{ 'file' } eq 'foo/bar' )
    {
        is( $obj->{ 'dirname' },   'foo', "The file dirname is captured" );
        is( $obj->{ 'basename' },  'bar', "The file basename is captured" );
        is( $obj->{ 'extension' }, undef, "The file extension is empty" );
    }
    elsif ( $obj->{ 'file' } eq 'foo/bar.txt' )
    {
        is( $obj->{ 'dirname' },   'foo', "The file dirname is captured" );
        is( $obj->{ 'basename' },  'bar', "The file basename is captured" );
        is( $obj->{ 'extension' }, 'txt', "The file extension is captured" );
    }
}
is( scalar( @{ $updated{ 'files' } } ),
    4, "We received the number of files we expected" );

#
# All done.
#




#
#  Create a file, given a name.
#
sub createFile
{
    my ($filename) = (@_);

    ok( !-e $filename, "The file we're creating is not present" );

    open( my $handle, ">", $filename );
    print $handle "\n";
    close($handle);

    ok( -e $filename, "We created a temporary file" );
}
