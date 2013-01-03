package Templer::Plugin::FileGlob;

use Cwd;


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
    #  Look for a value of "file_glob" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^file_glob\((.*)\)/ )
        {

            #
            #  Populate an array of hash-refs referring to files which match
            #  a particular glob.
            #
            #  Could be used for many things, will be used for image-gallaries.
            #
            my $pattern = $1;
            $pattern =~ s/['"]//g;
            $pattern =~ s/^\s+|\s+$//g;

            #
            #  Make sure we're relative to teh directory name.
            #
            my $dirName = $page->source();
            if ( $dirName =~ /^(.*)\/(.*)$/ )
            {
                $dirName = $1;
            }
            my $pwd = cwd();
            chdir( $dirName . "/" );

            # add the data
            my $ref;
            foreach my $img ( glob($pattern) )
            {

                #
                # Data reference - moved here so we can add height/width if the
                # glob refers to an image, and if we have Image::Size installed.
                #
                my %meta = ( file => $img );

                if ( $img =~ /\.(jpe?g|png|gif)$/i )
                {
                    my $module = "use Image::Size;";
                    ## no critic (Eval)
                    eval($module);
                    ## use critic
                    if ( !$@ )
                    {
                        ( $meta{ 'width' }, $meta{ 'height' } ) =
                          imgsize( $dirName . "/" . $img );
                    }
                }
                push( @$ref, \%meta );
            }

            if ($ref)
            {
                $hash{ $key } = $ref;
            }
            else
            {
                print
                  "WARNING: pattern '$pattern' matched zero files for page " .
                  $page->source() . "\n";
                delete $hash{ $key };
            }
            chdir($pwd);
        }
    }

    #
    #  Return.
    #
    return ( \%hash );
}


#
#  Name is largely irrelevant.  Do we need to set it?
#
Templer::Plugin::Factory->new()
  ->register_plugin( "file_glob", "Templer::Plugin::FileGlob" );
