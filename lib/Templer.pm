
=head1 NAME

Templer - A holder for our version

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Templer;

    print $Templer::VERSION;

=cut

=head1 DESCRIPTION

This package is a simple holder for the VERSION number of our release.

It exists specifically so that the installation process will succeed,
and we can usefully track versioned releases.

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


package Templer;


our $VERSION = "0.9.8";


1;
