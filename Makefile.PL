
use strict;

use ExtUtils::MakeMaker;

my %prereq_pm = ( 'HTML::Template'    => 0,
                  'Getopt::Long'      => 0,
                  'Module::Pluggable' => 0,
                );

my %test_pm = (
               # solely for the test-suite.
               'Test::More'       => 0,
               'Test::Pod'        => 0,
               'Test::Strict'     => 0,
               'Test::Exception'  => 0,
               'Test::NoTabs'     => 0,
              );

WriteMakefile(
    NAME         => 'App::Templer',
    VERSION_FROM => 'lib/Templer.pm',
    EXE_FILES    => ['bin/templer', 'bin/templer-generate'],
    PREREQ_PM    => \%prereq_pm,
    TEST_REQUIRES => \%test_pm,
    ABSTRACT     => 'Extensible Static Site Generator.',
    AUTHOR       => 'Steve Kemp <steve@steve.org.uk>',
    LICENSE      => 'perl',


    META_MERGE => {
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            homepage   => 'https://github.com/skx/templer/',
            bugtracker => 'https://github.com/skx/templer/issues',
            repository => 'https://github.com/skx/templer.git',
            GitMirror  => 'http://git.steve.org.uk/skx/templer',
                     },
                  },
             );

