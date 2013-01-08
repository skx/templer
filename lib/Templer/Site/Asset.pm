
=head1 NAME

Templer::Site::Asset - An interface to a site asset.

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Templer::Site::Asset;

    my $page = Templer::Site::Asset->new( file => "./input/robots.txt" );

=cut

=head1 DESCRIPTION

An asset is anything in the input directory which is *not* a page.

Assuming we're not running in "in-place" mode then assets are copied
over to a suitable filename in the output tree.

In C<templer> the page objects are created by the L<Templer::Site> module.

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

Copyright (C) 2012-2013 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut

package Templer::Site::Asset;



=head2 new

The constructor.

The single appropriate argument is the hash-key "file", pointing to the
page-file on-disk.

=cut

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


=head2 source

Return the filename we were built from.  This is the value passed
in the constructor.

=cut

sub source
{
    my ($self) = (@_);
    $self->{ "file" };
}



1;
