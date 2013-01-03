package Templer::Plugin::ShellCommand;


#
# Constructor
#
sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}


#
#  Given an input hash, of key:value pairs, we update any that match.
#
sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "run_command" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^run_command\((.*)\)/ )
        {

            #
            # Run a system command, and capture the output.
            #
            my $cmd = $1;
            $cmd =~ s/['"]//g;
            $cmd =~ s/^\s+|\s+$//g;
            $hash{ $key } = `$cmd`;
        }

    }

    #
    #  Return.
    #
    return ( \%hash );
}


#
#  Name is largely irrelevant.  Do we need to set it?
#
Templer::Plugin::Factory->new()
  ->register_plugin( "run_command", "Templer::Plugin::ShellCommand" );
