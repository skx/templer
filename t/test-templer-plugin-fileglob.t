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
Files: file_glob( *.txt );
----

This is my page content.

EOF
close($handle);


#
#  Now create some files.
#
createFile( $dir . "/foo.txt" );
createFile( $dir . "/ok.txt" );
createFile( $dir . "/bar.txt" );

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
my $ref      = $factory->expand_variables( $page, \%original );
my %updated  = %$ref;

ok( %updated,            "Fetching the fields of hte page succeeded" );
ok( $updated{ 'files' }, "The fields contain a file reference" );

foreach my $obj ( @{ $updated{ 'files' } } )
{
    ok( $obj->{ 'file' }, "The file reference has a name" );
    ok( $obj->{ 'file' } =~ /\.txt$/, "The file reference is sane" );
}
is( scalar( @{ $updated{ 'files' } } ),
    3, "We received the number of files we expected" );

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
