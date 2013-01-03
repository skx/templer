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
# Register a new formatter object.
#
sub register_formatter
{
    my ( $self, $name, $obj ) = (@_);

    die "No name" unless( $name );
    $name = lc( $name );
    $self->{'formatters'}{ $name } = $obj;
}

#
#  Gain access to a previously registered formatter object.
#
sub formatter
{
    my ( $self, $name ) = (@_);

    die "No name" unless( $name );
    $name = lc( $name );

    #
    #  Lookup the formatter by name, if it is found
    # then instantiate the clsee.
    #
    my $obj =  $self->{'formatters'}{ $name } || undef;
    $obj = $obj->new() if ( $obj );

    return( $obj );
}

#
#  For the test-suite only
#
sub formatters
{
    my( $self ) = ( @_ );

    keys (%{$self->{'formatters'}});
}


sub load_plugin
{
    my ( $self, $name ) = (@_);

    my $o = $self->{ $name };
    return $o->new();
}


1;
