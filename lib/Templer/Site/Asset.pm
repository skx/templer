#
# This object holds data about each asset which was found.
#
# An asset is anything in the input directory which is *not* a page.
#
# Assuming we're not running in "in-place" mode then assets are copied
# over to a suitable filename in the output tree.
#
package Templer::Site::Asset;



#
# Constructor
#
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
    return $self;
}


#
# The source of the asset.
#
sub source
{
    my ($self) = (@_);
    $self->{ "file" };
}



1;
