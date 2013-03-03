

#
#  A package for reading the global configuration file.
#
#  We assume that every project contains a "./templer.cfg" file in the
# top-level directory.  Here we parse that, if present.
#
package Templer::Global;

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


sub _readGlobalCFG
{
    my ( $self, $filename ) = (@_);

    #
    #  If the global configuration file doesn't exist that's a shame.
    #
    return if ( !-e $filename );

    open( my $handle, "<:utf8", $filename ) or
      die "Failed to read '$filename' - $!";
    binmode( $handle, ":utf8" );

    while ( my $line = <$handle> )
    {

        # strip trailing newline.
        $line =~ s/[\r\n]*//g;

        next if ( $line =~ /^#/ );

        if ( $line =~ /^([^=]+)=(.*)$/ )
        {
            my $key = $1;
            my $val = $2;
            $key = lc($key);
            $key =~ s/^\s+|\s+$//g;
            $val =~ s/^\s+|\s+$//g;

            #
            # If the line is pre/post-build then save the values
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



#
# Retrieve a value from the file, by key.
#
sub field
{
    my ( $self, $field ) = (@_);
    return ( $self->{ $field } );
}


#
# Retrieve all known key/value pairs.
#
sub fields
{
    my ($self) = (@_);

    %$self;
}


#
# Return the global-layout file.
#
sub layout
{
    my ($self) = (@_);
    $self->field("layout");
}


#
#  Set a global value
#
sub set
{
    my ( $self, $key, $values ) = (@_);
    $self->{ $key } = $values;
}



1;
