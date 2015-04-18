use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.48;



my %WriteMakefileArgs = (
    NAME         => 'App::Templer',
    VERSION_FROM => 'lib/Templer.pm',
    EXE_FILES    => ['bin/templer', 'bin/templer-generate'],
    PREREQ_PM    => {

        # These are hard requirements.
        'HTML::Template'    => 0,
        'Getopt::Long'      => 0,
        'Module::Pluggable' => 0,

        # These are OPTIONAL.
        "Image::Size"    => 0,
        "Redis"          => 0,
        "Text::Markdown" => 0,
        "Text::Template" => 0,
        "Text::Textile"  => 0,

        # solely for the test-suite.
        'Test::More'      => 0,
        'Test::Pod'       => 0,
        'Test::Strict'    => 0,
        'Test::Exception' => 0,
        'Test::NoTabs'    => 0,

    },
    ABSTRACT => 'Extensible Static Site Generator.',
    AUTHOR   => 'Steve Kemp <steve@steve.org.uk>',
    LICENSE  => 'perl',

    MIN_PERL_VERSION => '5.008',

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


WriteMakefile(%WriteMakefileArgs);
