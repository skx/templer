package Templer::Plugin::Markdown;


sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}


#
#  This plugin is available if we've got the markdown module.
#
sub available
{
    my $str = "use Text::Markdown;";

    ## no critic (Eval)
    eval($str);
    ## use critic

    return ( $@ ? undef : 1 );
}


#
# Format the given text.
#
sub format
{
    my ( $self, $str ) = (@_);

    if ( $self->available() )
    {
        Text::Markdown::markdown($str);
    }
    else
    {
        $str;
    }
}

Templer::Plugin::Factory->new()
  ->register_formatter( "markdown", "Templer::Plugin::Markdown" );
