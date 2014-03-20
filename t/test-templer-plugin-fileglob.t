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
my $site = Templer::Site->new( suffix => ".skx" );

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
open( my $handle, ">", $dir . "/input.skx" );
print $handle <<EOF;
Title: This is my page title.
Files: file_glob( foo/* );
----

This is my page content.

EOF
close($handle);

#
#  Now create some files (one of which is a templer input page)
#
mkdir("$dir/foo");
createFile( $dir . "/foo/foo.txt" );
createFile( $dir . "/foo/ok.txt" );
createFile( $dir . "/foo/bar.txt" );
createFile( $dir . "/foo/bar" );
open( $handle, ">", $dir . "/foo/input.skx" );
print $handle <<EOF;
Title: An included page
Variable: Value
----

This is another page content.

EOF
close($handle);


#
#  Create the page
#
my $page = Templer::Site::Page->new( file => $dir . "/input.skx" );
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
    my $file = $obj->{ 'file' };
    ok( $obj->{ 'file' }, "The file reference has a name : $obj->{ 'file' }" );
    ok( $obj->{ 'file' } =~ m{^foo/}, "    file reference is sane" );
    if ( $file eq "foo/foo.txt" )
    {
        is( $obj->{ 'content' },   "something", "    content is propagated" );
        is( $obj->{ 'dirname' },   'foo',       "    dirname is captured" );
        is( $obj->{ 'basename' },  'foo',       "    basename is captured" );
        is( $obj->{ 'extension' }, 'txt',       "    extension is captured" );
    }
    elsif ( $file eq "foo/ok.txt" )
    {
        is( $obj->{ 'content' },   "something", "    content is propagated" );
        is( $obj->{ 'dirname' },   'foo',       "    dirname is captured" );
        is( $obj->{ 'basename' },  'ok',        "    basename is captured" );
        is( $obj->{ 'extension' }, 'txt',       "    extension is captured" );
    }
    elsif ( $file eq "foo/bar.txt" )
    {
        is( $obj->{ 'content' },   "something", "    content is propagated" );
        is( $obj->{ 'dirname' },   'foo',       "    dirname is captured" );
        is( $obj->{ 'basename' },  'bar',       "    basename is captured" );
        is( $obj->{ 'extension' }, 'txt',       "    extension is captured" );
    }
    elsif ( $file eq "foo/bar" )
    {
        is( $obj->{ 'content' },   "something", "    content is propagated" );
        is( $obj->{ 'dirname' },   'foo',       "    dirname is captured" );
        is( $obj->{ 'basename' },  'bar',       "    basename is captured" );
        is( $obj->{ 'extension' }, undef,       "    extension is empty" );
    }
    elsif ( $file eq "foo/input.skx" )
    {
        is( $obj->{ 'variable' },
            'Value', "    input variables are propagated" );
        is( $obj->{ 'dirname' },   'foo',   "    dirname is captured" );
        is( $obj->{ 'basename' },  'input', "    basename is captured" );
        is( $obj->{ 'extension' }, 'skx',   "    extension is captured" );
    }
}
is( scalar( @{ $updated{ 'files' } } ),
    5, "We received the number of files we expected" );

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
    print $handle "something";
    close($handle);

    ok( -e $filename, "We created a temporary file" );
}
