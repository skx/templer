
=head1 NAME

Templer::Plugin::Strict - A XML-like strict syntax for templates tags.

=cut

=head1 DESCRIPTION

This class implements a layout template filter plugin for C<templer> which
allows empty-element template tags to be written as in XML.

This allows the following syntax

=over

=item C<<TMPL_VAR NAME="PARAMETER_NAME"/>>

=item C<<TMPL_INCLUDE NAME="filename.tmpl"/>>

=item C<<TMPL_ELSE/>>

=back

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

Bruno Beaufils <bruno@boulgour.com>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 Bruno Beaufils <bruno@boulgour.com>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::Strict;


=head2 new

Constructor.  No arguments are supported/expected.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}


=head2 available

This plugin is always available.

=cut

sub available
{
    return 1;
}


=head2 filter

Filter the given template.

=cut

sub filter
{
    my ( $self, $str ) = (@_);

    $str =~ s{\<tmpl_var([^>/]*)/\>}{<tmpl_var$1>}ig;
    $str =~ s{\<tmpl_include([^>/]*)/\>}{<tmpl_include$1>}ig;
    $str =~ s{\<tmpl_else/\>}{<tmpl_else>}ig;

    return $str;
}

Templer::Plugin::Factory->new()
  ->register_filter( "strict", "Templer::Plugin::Strict" );
