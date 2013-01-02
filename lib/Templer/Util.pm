#
# A collection of static utility methods.
#
package Templer::Util;



#
# Load a module, dynamically, and return 1 on succss.
#
sub load_module_dynamically
{
    my ($str) = (@_);

    my $ret = undef;

    ## no critic (Eval)
    eval($str);
    ## use critic

    if ( !$@ )
    {
        $ret = 1;
    }
    return ($ret);
}


#
#  Read a file, and return a string of the contents.
#
#  Warn if the file isn't found.
#
sub file_contents
{
    my ($name) = (@_);

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


1;
