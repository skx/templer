package Templer::Plugin::Textile;


sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}


sub available
{
    my $str = "use Text::Textile;";

    ## no critic (Eval)
    eval($str);
    ## use critic

    return( $@ ? undef : 1 );
}

sub format
{
    my( $self, $str ) = ( @_ );

    if ( $self->available() )
    {
        Text::Textile::textile($str);
    }
    else
    {
        $str;
    }
}

Templer::Plugin::Factory->new()->register_formatter( "textile", "Templer::Plugin::Textile" );
