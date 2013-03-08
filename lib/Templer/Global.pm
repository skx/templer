
=head1 NAME

Templer::Global - The configuration for a templer-based site.

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
which we assume will be present in each templer-based site.

The file is a simple key=value store, with comments being prefixed by
the hash ("#") character, and ignored.

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

Copyright (C) 2012-2013 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Global;


=head2 new

Constructor.  The hash of parameters is saved away, and the filename
specified in the 'file' parameter will be opened and parsed.

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

=cut

sub field
{
    my ( $self, $field ) = (@_);
    return ( $self->{ $field } );
}


=head2 fields

Retrieve all known key/value pairs.

=cut

sub fields
{
    my ($self) = (@_);

    %$self;
}


=head2 layout

Return the global-layout file.

This is a helper for:

=for example begin

    my $layout = $obj->field( 'layout' );

=for example end

=cut

sub layout
{
    my ($self) = (@_);
    $self->field("layout");
}


=head2 set

Set a global value.

=cut

sub set
{
    my ( $self, $key, $values ) = (@_);
    $self->{ $key } = $values;
}



1;
