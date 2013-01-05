package Templer::Plugin::FileContents;


#
# Constructor
#
sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}


#
#  Given an input hash, of key:value pairs, we update any that match.
#
sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "run_command" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^read_file\((.*)\)/ )
        {

            #
            #  Read a file contents.
            #
            my $file = $1;

            $file =~ s/['"]//g;
            $file =~ s/^\s+|\s+$//g;

            if ( $file eq "SELF" )
            {
                $file = $page->source();
            }
            else
            {
                my $dirName = $page->source();
                if ( $dirName =~ /^(.*)\/(.*)$/ )
                {
                    $dirName = $1;
                }
                $file = $dirName . "/" . $file unless ( $file =~ /^\// );
            }

            $hash{ $key } = $self->file_contents($file);
        }
    }

    #
    #  Return.
    #
    return ( \%hash );
}


#
#  Return the contents of the named file.
#
sub file_contents
{
    my ( $self, $name ) = (@_);

    my $content = "";

    if ( -e $name )
    {
        open( my $handle, "<:utf8", $name ) or
          return "";

        binmode( $handle, ":utf8" );

        while ( my $line = <$handle> )
        {
            $content .= $line;
        }
        close($handle);
    }
    else
    {
        print "WARNING: Attempting to read a file that doesn't exist: $name\n";
    }

    $content;
}

#
#  Register the plugin.
#
Templer::Plugin::Factory->new()->register_plugin( "Templer::Plugin::FileContents" );
