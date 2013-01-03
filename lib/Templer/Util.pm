#
# A collection of static utility methods.
#
package Templer::Util;




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
