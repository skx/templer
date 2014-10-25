
=head1 NAME

Templer::Site::Page - An interface to a site page.

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Templer::Site::Page;

    my $page = Templer::Site::Page->new( file => "./input/foo.wgn" );

=cut

=head1 DESCRIPTION

A page is any non-directory beneath the input-directory which matches the
pattern specified by the user (defaults to "*.skx").

Pages are processed via the L<HTML::Template> module to create the suitable
output.

In C<templer> the page objects are created by the L<Templer::Site> module.

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

Copyright (C) 2012-2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Site::Page;



=head2 new

The constructor.

The single appropriate argument is the hash-key "file", pointing to the
page-file on-disk.

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
    $self->_parse_page( $self->{ 'file' } ) if ( $self->{ 'file' } );
    return $self;
}


=head2 _parse_page

Read the file, and parse the header/content.

This is an internal method.

=cut

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




=head2 content

Return the body of the page.

Here we perform the textile/markdown expansion if possible via the use
plugins loaded by L<Templer::Plugin::Factory>.

=cut

sub content
{
    my ( $self, $data ) = (@_);

    #
    #  The content we read from the page.
    #
    my $content = $self->{ 'content' };
    my $format = $self->{ 'format' } || $data->{ 'format' } || undef;

    #
    #  Do we have a formatter plugin for this type?
    #
    #  Many formatters might be specified
    #
    if ($format)
    {

        #
        #  The plugin-factory.
        #
        my $factory = Templer::Plugin::Factory->new();

        #
        #  For each formatter.
        #
        foreach my $fmt ( split( /,/, $format ) )
        {
            $fmt =~ s/^\s+|\s+$//g;
            next unless ($fmt);

            my $helper = $factory->formatter($fmt);
            $content = $helper->format( $content, $data ) if ($helper);
        }
    }
    return $content;
}


=head2 field

Retrieve a field from the header of the page.

In the following example file "foo", "bar" and "title" are fields:

    Foo: Testing ..
    Bar: file_glob( "*.gif" )
    Title: This is my page title.
    -----
    <p>This is my page content ..</p>

=cut

sub field
{
    my ( $self, $field ) = (@_);
    return ( $self->{ $field } );
}



=head2 fields

Return all known fields/values from the page.

=cut

sub fields
{
    my ($self) = (@_);

    return (%$self);
}


=head2 source

Return the filename we were built from.  This is the value passed
in the constructor.

=cut

sub source
{
    my ($self) = (@_);
    $self->field("file");
}



=head2 layout

Return the layout-template to use for this page, if one has been set.

=cut

sub layout
{
    my ($self) = (@_);
    $self->field("layout");
}


=head2 dependencies

Return the dependencies of the current page.

=cut

sub dependencies
{
    my ($self) = (@_);

    $self->{ 'dependencies' } ? @{ $self->{ 'dependencies' } } : ();
}


=head2 add_dependency

Add a dependency to the current page.  This is used so that the file-inclusion
plugin can add such a thing.

=cut

sub add_dependency
{
    my ( $self, $file ) = (@_);
    push( @{ $self->{ 'dependencies' } }, $file );
}


1;
