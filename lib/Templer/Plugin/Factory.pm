#
#  This is a trivial plugin-factory, implemented as a singleton, which
# allows plugins to register themselves by name.
#
package Templer::Plugin::Factory;

my $singleton;

sub new
{
    my $class = shift;
    $singleton ||= bless {}, $class;
}

#
# Register a new formatter plugin.
#
sub register_formatter
{
    my ( $self, $name, $obj ) = (@_);

    die "No name" unless ($name);
    $name = lc($name);
    $self->{ 'formatters' }{ $name } = $obj;
}


#
# Register a new plugin for variable expansion.
#
sub register_plugin
{
    my ( $self, $name, $obj ) = (@_);

    die "No name" unless ($name);
    $name = lc($name);
    $self->{ 'plugins' }{ $name } = $obj;
}


#
#  Expand variables via all loaded plugins.
#
#  This is chained.
#
sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    my $out;

    foreach my $name ( keys( %{ $self->{ 'plugins' } } ) )
    {
        my %in     = %$data;
        my $object = $self->{ 'plugins' }{ $name }->new();
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
