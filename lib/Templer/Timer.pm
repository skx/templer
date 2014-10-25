
=head1 NAME

Templer::Timer - A utility class for recording build-time.

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Templer::Timer;

    my $obj = Templer::Timer->new();
    sleep( 3 );

    print $obj->elapsed();

=cut

=head1 DESCRIPTION

This class is a simple utility for reporting the time elapsed since
the object was created.

It is used to report on the build-time of a templer site.

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

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


use strict;
use warnings;


package Templer::Timer;



=begin doc

Constructor.

Record the creation time of this object.

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
