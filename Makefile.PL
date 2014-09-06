use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
    NAME         => 'App::Templer',
    VERSION_FROM => 'lib/Templer.pm',
    EXE_FILES    => ['bin/templer', 'bin/templer-generate'],
    PREREQ_PM    => {
        'HTML::Template'    => 0,
        'Getopt::Long'      => 0,
        'Module::Pluggable' => 0,

        # these are OPTIONAL.
        "Image::Size"    => 0,
        "Redis"          => 0,
        "Text::Markdown" => 0,
        "Text::Template" => 0,
        "Text::Textile"  => 0,
                 },
    TEST_REQUIRES => {

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




unless ( eval {ExtUtils::MakeMaker->VERSION(6.56)} )
{
    my $br = delete $WriteMakefileArgs{ BUILD_REQUIRES };
    my $pp = $WriteMakefileArgs{ PREREQ_PM };
    for my $mod ( keys %$br )
    {
        if ( exists $pp->{ $mod } )
        {
            $pp->{ $mod } = $br->{ $mod } if $br->{ $mod } > $pp->{ $mod };
        }
        else
        {
            $pp->{ $mod } = $br->{ $mod };
        }
    }
}

delete $WriteMakefileArgs{ CONFIGURE_REQUIRES }
  unless eval {ExtUtils::MakeMaker->VERSION(6.52)};

WriteMakefile(%WriteMakefileArgs);
