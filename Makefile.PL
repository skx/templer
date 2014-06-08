# $Id$

use strict;
use lib './t/lib';
use ExtUtils::MakeMaker;

my %prereq_pm = ( 'HTML::Template' => undef,
                  'Test::More' =>undef,
                  'Getopt::Long' => undef,
                );

WriteMakefile(
    NAME         => 'App::Templer',
    VERSION_FROM => 'lib/Templer.pm',
    EXE_FILES    => ['templer', 'templer-generate'],
    PREREQ_PM    => \%prereq_pm,
    ABSTRACT     => 'Extensible Static Site Generator.',
    AUTHOR       => 'Steve Kemp <steve@steve.org.uk>',


    META_MERGE => {
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            homepage   => 'https://github.com/skx/templer/',
            bugtracker => 'https://github.com/skx/templer/issues',
            repository => 'https://github.com/skx/templer.git',

                     },
                  },
             );

