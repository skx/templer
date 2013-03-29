#!/usr/bin/perl -w
#
#  Test that none of our scripts contain any literal TAB characters.
#
# Steve
# --


use strict;
use File::Find;
use Test::More qw( no_plan );


#
#  Find all the files beneath the current directory,
# and call 'checkFile' with the name.
#
find( { wanted => \&checkFile, no_chdir => 1 }, '.' );



#
#  Check a file.
#
#
sub checkFile
{

    # The file.
    my $file = $File::Find::name;

    # We don't care about directories
    return if ( !-f $file );

    # Nor about backup files.
    return if ( $file =~ /~$/ );

    # or Makefiles
    return if ( $file =~ /Makefile$/ );

    # Nor about files which start with ./debian/
    return if ( $file =~ /^\.\/debian\// );

    # Nor about files in ./.git/
    return if ( $file =~ /^.\/\.git\// );

    # See if it is a shell/perl file.
    my $isShell = 0;
    my $isPerl  = 0;

    # Read the file.
    open( my $handle, "<", $file );
    foreach my $line (<$handle>)
    {
        if ( ( $line =~ /\/bin\/sh/ ) ||
             ( $line =~ /\/bin\/bash/ ) )
        {
            $isShell = 1;
        }
        if ( $line =~ /\/usr\/bin\/perl/ )
        {
            $isPerl = 1;
        }
    }
    close($handle);

    #
    #  We don't care about files which are neither perl nor shell.
    #
    if ( $isShell || $isPerl )
    {

        #
        #  Count TAB characters
        #
        my $count = countTabCharacters($file);

        is( $count, 0, "Script has no tab characters: $file" );
    }
}



#
#  Count and return the number of literal TAB characters contained
# in the specified file.
#
sub countTabCharacters
{
    my ($file) = (@_);
    my $count = 0;

    open( my $handle, "<", $file ) or
      die "Cannot open $file - $!";
    foreach my $line (<$handle>)
    {

        # We will count multiple tab characters in a single line.
        while ( $line =~ /(.*)\t(.*)/ )
        {
            $count += 1;
            $line = $1 . $2;
        }
    }
    close($handle);

    return ($count);
}
