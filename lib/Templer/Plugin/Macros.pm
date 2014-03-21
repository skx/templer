
=head1 NAME

Templer::Plugin::Macros - A simple regexp macro definition/expansion plugin

=cut

=head1 DESCRIPTION

This class implements a preprocessor (formatter) plugin for C<templer> which
allows regular expression macro definition as well as their expansion. This
plugin is a way to solve the problem of HTML::Template and Text::Template
which do not offer any simple solution to create parametrized shorcuts.

=for example begin

    Title: This is my page
    format: macros
    ----
    <!-- #define to\((.+)\) <a href="http://$1" class="www">$1</a> -->

    <p>This is an url to(steve.org.uk)</p>
    <p>This is another one to to(bruno.boulgour.com)</p>

=for example end

Macros defintion should be on a line by itself which is removed from the
output.

If a variable (global or page specific) named C<macros> is defined then its
content is considered as macro definition to be added to the page content
B<before> parsing it. This allow to store macro definitions common to some
pages, or the whole site (especially convenient when stored in a file and in
conjunction with C<read_file()>).

Inspiration comes from the C preprocessor (which inspired our old GTML tool)
for the simplifcity of definition as well as txt2tags preproc and postproc
directives for the use of regular expression.

=cut

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version,
or

b) the Perl "Artistic License".

=cut

=head1 AUTHOR

Bruno BEAUFILS <bruno@boulgour.com>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 Bruno BEAUFILS <bruno@boulgour.com>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::Macros;



=head2 new

Constructor.  No arguments are supported/expected.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};

    bless( $self, $class );
    return $self;
}


=head2 available

This plugin is always available.

=cut

sub available
{
    return 1;
}


=head2 format

Format the given text.

=cut

sub format
{
    my ( $self, $str, $data ) = (@_);

    if ( $self->available() )
    {

        #
        # If macros variable exist add its content to str
        #
        $str = ${ $data }{ 'macros' } . $str if ( ${ $data }{ 'macros' } );

        my @patterns = ();
        my @replaces = ();
        my $content  = "";

        foreach ( split /\n/, $str )
        {

            #
            # Line contains a macro definition
            #
            if ( /^<!--\s+#define\s+"([^"]+)"\s+(.*)\s+-->$/ ||
                 /^<!--\s+#define\s+'([^']+)'\s+(.*)\s+-->$/ ||
                 /^<!--\s+#define\s+([^\s]+)\s+(.*)\s+-->$/ )
            {
                my $pattern = $1;
                my $replace = $2;
                $replace =~ s{\@}      # prevent at sign from perl
                             {\\@}g;
                $replace =~ s{"}       # prevent double-quotes from perl
                             {\\"}g;
                $replace =~ s{\\(\d+)} # enable use of \1 as back references
                             {\$$1}g;

                push @patterns, $pattern;
                push @replaces, $replace;

                next;
            }

            #
            # Line should be expanded
            #
            else
            {
                my $line = $_;
                foreach ( keys(@patterns) )
                {
                    my $rep = '"' . $replaces[$_] . '"';
                    $line =~ s{$patterns[$_]}
                              {$rep}eeg;
                }
                $content .= "$line\n";
            }
        }

        return $content;
    }
    else
    {
        $str;
    }
}

Templer::Plugin::Factory->new()
  ->register_formatter( "macros", "Templer::Plugin::Macros" );
