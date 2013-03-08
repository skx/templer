use strict;
use warnings;

#
#  A utility class for recording a time-duration.
#
#
package Templer::Timer;


=begin doc

Constructor.  Record the creation time of this object.

=end doc

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    $self->{ 'start' } = time();

    bless( $self, $class );
    return $self;
}



=begin doc

Return the time elapsed since this object was created.

=end doc

=cut

sub elapsed
{
    my ($self) = (@_);

    my $now     = time;
    my $elapsed = $now - $self->{ 'start' };

    if ( $elapsed < 1 )
    {
        $elapsed = "less than 1 second";
    }
    elsif ( $elapsed == 1 )
    {
        $elapsed = "1 second";
    }
    else
    {
        $elapsed = $elapsed . " seconds";
    }
    $elapsed;
}

1;
