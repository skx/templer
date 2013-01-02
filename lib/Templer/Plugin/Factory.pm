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

sub register_plugin
{
    my ( $self, $name, $obj ) = (@_);

    $self->{ $name } = $obj;
}

sub load_plugin
{
    my ( $self, $name ) = (@_);

    my $o = $self->{ $name };
    return $o->new();
}


1;
