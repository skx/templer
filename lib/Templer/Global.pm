
=head1 NAME

Templer::Global - Configuration-file parser for templer.

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Templer::Global;

    my $site   = Templer::Global->new( file => "./templer.cfg" );
    my $suffix = $site->field( "suffix" );

=cut

=head1 DESCRIPTION

This class is responsible for parsing the top-level templer.cfg file
which we assume will be present in a templer-based site.

The file is a simple key=value store, with comments being prefixed by
the hash ("#") character, and ignored.

This object is created when templer is started so that the options may
be parsed/read.  Once that happens the options are merged with the
command-line flags, and this object isn't touched again.

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

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2015 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Global;


=head2 new

Constructor.

Any parameters specified in our single hash-argument are saved away,
the filename specified in the 'file' parameter will be opened and parsed.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};

    #
    #  Allow user supplied values to override our defaults
    #
    foreach my $key ( keys %supplied )
    {
        $self->{ lc $key } = $supplied{ $key };
    }

    bless( $self, $class );
    $self->_readGlobalCFG( $self->{ 'file' } ) if ( $self->{ 'file' } );
    return $self;
}



=head2 _readGlobalCFG

Read the specified configuration file.  Called by the constructor if
a filename was specified.

=cut

sub _readGlobalCFG
{
    my ( $self, $filename ) = (@_);

    #
    #  If the configuration file doesn't exist that's a shame.
    #
    return if ( !-e $filename );

    #
    #  Open the file, making sure we're UTF-8 safe.
    #
    open( my $handle, "<:utf8", $filename ) or
      die "Failed to read '$filename' - $!";
    binmode( $handle, ":utf8" );

    while ( my $line = <$handle> )
    {

        # strip trailing newline.
        $line =~ s/[\r\n]*//g;

        # skip comments.
        next if ( $line =~ /^#/ );

        # If the line is :  key = value
        if ( $line =~ /^([^=]+)=(.*)$/ )
        {
            my $key = $1;
            my $val = $2;
            $key = lc($key);
            $key =~ s/^\s+|\s+$//g;
            $val =~ s/^\s+|\s+$//g;

            #
            # command expansion?
            #
            if ( $val =~ /(.*)`([^`]+)`(.*)/ )
            {

                # store
                my $pre  = $1;
                my $cmd  = $2;
                my $post = $3;

                # get output
                my $output = `$cmd`;
                chomp($output);

                # build up replacement.
                $val = $pre . $output . $post;
            }

            #
            # If the line is pre/post-build then save the values as an array
            #
            if ( $key =~ /^(pre|post)-build$/ )
            {
                push( @{ $self->{ $key } }, $val );
            }
            else
            {

                #
                # The general case is store the value in the key.
                #
                $self->{ $key } = $val;
            }
            print "Templer::Global set: $key => $val\n"
              if ( $self->{ 'debug' } );
        }
    }
    close($handle);
}



=head2 field

Retrieve a value from the file, by key.

This is only called by templer to retrieve the pre/post-build
commands to execute.

=cut

sub field
{
    my ( $self, $field ) = (@_);
    return ( $self->{ $field } );
}


=head2 fields

Retrieve all known key/value pairs.

This is called by templer to retrieve all global settings, which
can then be merged with its defaults.

=cut

sub fields
{
    my ($self) = (@_);

    %$self;
}


1;
