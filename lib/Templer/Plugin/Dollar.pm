
=head1 NAME

Templer::Plugin::Dollar - A simple shell-like syntax for template variables.

=cut

=head1 DESCRIPTION

This class implements a layout template filter plugin for C<templer> which
allows template variables to be included using a dollar sign followed by an
open brace, the variable name and a closing brace.

This allows template such as this to be used

=for example begin

    <html>
      <head>
        <title>${title escape="html"}</title>
        <meta name='author' content='${author} ${email escape=url}'/>
      </head>
      <body>
      </body>
    </html>

=for example end

Everything between the variable name and the closing brace is used B<as is> in
the transformation. The third line of the example is for instance transformed
as

=for example begin

        <title><tmpl_var name="title" escape="html"></title>

=for example end

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

Copyright (C) 2014 Bruno Beaufils <bruno@boulgour.com>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::Dollar;


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

    $str =~ s/\$\{(\w+)([^}]*)\}/<tmpl_var name="$1"$2>/g;

    return $str;
}

Templer::Plugin::Factory->new()
  ->register_filter( "dollar", "Templer::Plugin::Dollar" );
