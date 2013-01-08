
=head1 NAME

Templer::Plugin::FileContents - A plugin to read file contents.

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  passwd: read_file( /etc/passwd )
  ----
  <p>This is my password file:</p>
  <!-- tmpl_var name='passwd' -->

=cut

=head1 DESCRIPTION

This plugin reads the contents of files from the local system,
and allows files to be included inline in templates.

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


package Templer::Plugin::FileContents;


=head2

Constructor.  No arguments are required/supported.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}



=head2 expand_variables

This is the method which is called by the L<Templer::Plugin::Factory>
to expand the variables contained in a L<Templer::Site::Page> object.

Variables are written in the file in the form "key: value", and are
internally stored within the Page object as a hash.

This method iterates over each key & value and updates any that
seem to refer to file-inclusion.

=cut

sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "read_file" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^read_file\((.*)\)/ )
        {

            #
            #  Get the filename specified.
            #
            my $file = $1;

            #
            #  Strip leading/trailing quotes and whitespace.
            #
            $file =~ s/['"]//g;
            $file =~ s/^\s+|\s+$//g;


            #
            #  Are we reading the input page itself?
            #
            if ( $file eq "SELF" )
            {
                $file = $page->source();
            }
            else
            {

                #
                #  Otherwise we need to make the file
                # specified relative to the location
                # of the input-page.
                #
                my $dirName = $page->source();
                if ( $dirName =~ /^(.*)\/(.*)$/ )
                {
                    $dirName = $1;
                }

                #
                #  Unless the file is specified with an absolute path.
                #
                $file = $dirName . "/" . $file unless ( $file =~ /^\// );
            }

            $hash{ $key } = $self->file_contents($file);
        }
    }

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
Templer::Plugin::Factory->new()
  ->register_plugin("Templer::Plugin::FileContents");
