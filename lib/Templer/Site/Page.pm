
#
# This object holds data about each page.
#
# A page is any non-directory beneath the input-directory which matches the pattern
# specified by the user (defaults to "*.skx").
#
# Pages are processed via the M<HTML::Template> module to create the suitable output.
#
package Templer::Site::Page;



#
# Constructor
#
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
    $self->_parse_page( $self->{ 'file' } ) if ( $self->{ 'file' } );
    return $self;
}


#
# Read the file, and parse the header/content.
#
sub _parse_page
{
    my ( $self, $filename ) = (@_);

    open( my $handle, "<:utf8", $filename ) or
      die "Failed to read '$filename' - $!";
    binmode( $handle, ":utf8" );

    my $header = 1;

    while ( my $line = <$handle> )
    {

        # strip trailing newline.
        $line =~ s/[\r\n]*//g;

        if ($header)
        {
            if ( $line =~ /^([^:]+):(.*)$/ )
            {
                my $key = $1;
                my $val = $2;
                $key = lc($key);
                $key =~ s/^\s+|\s+$//g;
                $val =~ s/^\s+|\s+$//g;

                $self->{ $key } = $val;
                print "Templer::Site::Page set: $key => $val\n"
                  if ( $self->{ 'debug' } );
            }
            if ( $line =~ /^----[\r\n]*$/ )
            {
                $header = undef;
            }
        }
        else
        {
            $self->{ 'content' } .= $line . "\n";
        }
    }

    #
    # If we're still in the header at the end of the file
    # then something has gone wrong.
    #
    if ($header)
    {
        print "WARNING: No header found in $filename\n";
    }

    close($handle);
}




#
# Return the body of the page.
#
# Here we perform the textile/markdown expansion if possible.
#
sub content
{
    my ($self) = (@_);

    #
    #  The content we read from the page.
    #
    my $content = $self->{ 'content' };
    my $format = $self->{ 'format' } || undef;

    #
    #  Do we have a formatter plugin for this type?
    #
    if ( $format )
    {
        my $factory = Templer::Plugin::Factory->new();
        my $helper  = $factory->formatter( $format );

        if ( $helper )
        {
            $content = $helper->format( $content );
        }
    }
    return $content;
}


#
# Retrieve a field from the header of the page.
#
sub field
{
    my ( $self, $field ) = (@_);
    return ( $self->{ $field } );
}


#
# Return all known fields/values from the page.
#
sub fields
{
    my ($self) = (@_);

    %$self;
}


#
#  Return the filename we were built from.
#
sub source
{
    my ($self) = (@_);
    $self->field("file");
}


#
# Return the per-page layout file to use, if present.
#
sub layout
{
    my ($self) = (@_);
    $self->field("layout");
}



1;
