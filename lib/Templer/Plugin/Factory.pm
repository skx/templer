
=head1 NAME

Templer::Plugin::Factory - A simple plugin class

=cut

=head1 DESCRIPTION

=cut


=head1 DESCRIPTION

This class implements a singleton within which plugin classes may
be registered and retrieved.

The plugins used by C<templer> are of two forms:

=over 8

=item formatters

These plugins operate upon the text contained in L<Templer::Site::Page> objects
and transform the input into HTML.

=item variable expanders

These plugins, also operating on L<Templer::Site::Page> objects, are allowed
the opportunity to modify, update, replace, or delete the various per-page
variables.

=back

Plugins of each type register themselves by calling the appropriate methods
in this class.

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



package Templer::Plugin::Factory;

my $singleton;




=head2 new

Constructor.

This class is a singleton, so this method will either construct
an instance of this class or return the global instance.

=cut

sub new
{
    my $class = shift;
    $singleton ||= bless {}, $class;
}



=head2 load_plugins

This method loads "*.pm" from the given directory.

=cut

sub load_plugins
{
    my ( $self, $directory ) = (@_);
    return unless ( -d $directory );

    foreach my $file ( sort( glob( $directory . "/*.pm" ) ) )
    {
        require $file;
    }
}



=head2 register_formatter

This method should be called by all formatting plugins to register
themselves.  The two arguments are the name of the input-format,
and the class-name which may be instantiated to process that kind
of input.

L<Templer::Plugin::Textile> and L<Templer::Plugin::Markdown> are
example classes.

=cut

sub register_formatter
{
    my ( $self, $name, $obj ) = (@_);

    die "No name" unless ($name);
    $name = lc($name);
    $self->{ 'formatters' }{ $name } = $obj;
}


=head2 register_formatter

This method should be called by all variable-expanding plugins to register
themselves.  The expected argument is the class-name which may be instantiated
to expand variables.

L<Templer::Plugin::ShellCommand>, L<Templer::Plugin::FileGlob>, and
L<Templer::Plugin::FileContents> are examples of such plugins.

=cut

sub register_plugin
{
    my ( $self, $obj ) = (@_);

    push( @{$self->{ 'plugins' }}, $obj );
}



=head2 expand_variables

Expand variables via all loaded plugins.

=cut

sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    my $out;

    foreach my $plugin ( @{ $self->{ 'plugins' } } )
    {
        my %in     = %$data;

        #
        # Create & invoke the plugin.
        #
        my $object = $plugin->new();
        $out = $object->expand_variables( $page, \%in );

        $data = \%$out;
    }
    return ($data);
}

#
#  Gain access to a previously registered formatter object, by name.
#
sub formatter
{
    my ( $self, $name ) = (@_);

    die "No name" unless ($name);
    $name = lc($name);

    #
    #  Lookup the formatter by name, if it is found
    # then instantiate the clsee.
    #
    my $obj = $self->{ 'formatters' }{ $name } || undef;
    $obj = $obj->new() if ($obj);

    return ($obj);
}


#
#  Return the names of each known formatter-plugin.
#
#  Used by the test-suite only.
#
sub formatters
{
    my ($self) = (@_);

    keys( %{ $self->{ 'formatters' } } );
}



1;
