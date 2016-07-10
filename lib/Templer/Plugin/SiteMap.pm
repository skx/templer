
=head1 NAME

Templer::Plugin::SiteMap - Generate a SiteMap automatically.

=cut

=head1 SYNOPSIS

This plugin must be enabled by adding two settings in the
global configuration file; the name of the file to generate
and the prefix of the output URLs.

The following is a good example:

=for example begin

  sitemap_file = /sitemap.xml
  sitemap_base = http://example.com/

=for example end

=cut

=head1 DESCRIPTION

This plugin will generate a simple C<sitemap.xml> file including
references to all pages which C<templer> knows about.

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

Copyright (C) 2016 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut



use strict;
use warnings;

use POSIX qw(strftime);

package Templer::Plugin::SiteMap;


=head2 new

Constructor.  No arguments are required/supported.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;
}


=head2 init

Initialisation function, which merely saves a reference to the
L<Templer::Site> object.

=cut


sub init
{
    my( $self, $site ) = ( @_);

    $self->{ 'site' } ||= $site;
}


=head2 cleanup

This method is invoked when site-generation is complete, and this
is where we generate the sitemap, if our two required configuration
values are present in the configuration file.

If configuration-variables are not setup then we do nothing.

=cut

sub cleanup
{
    my ($self) = (@_);

    #
    #  Gain access to our expected configuration values.
    #
    my $file = $self->{'site'}->{'sitemap_file'};
    my $base = $self->{'site'}->{'sitemap_base'};
    my $path = $self->{'site'}->{'output'};

    return unless ($file && $base && $path );

    #
    #  The pages we know about.
    #
    my $pages = $self->{ 'site' }->{ 'output-files' };

    #
    #  Open the sitemap file
    #
    open( my $map, ">", $path . $file );
    print $map <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<urlset
  xmlns="http://www.google.com/schemas/sitemap/0.84"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.google.com/schemas/sitemap/0.84
                      http://www.google.com/schemas/sitemap/0.84/sitemap.xsd">
<url>
 <loc>$base</loc>
 <priority>0.75</priority>
 <changefreq>daily</changefreq>
</url>
EOF


    #
    #  For each page
    #
    foreach my $page (@$pages)
    {
        my $url = substr( $page, length($path) );
        print $map <<EOF;
<url>
  <loc>$base$url</loc>
  <priority>0.50</priority>
  <changefreq>weekly</changefreq>
</url>
EOF
    }

    print $map <<EOF;
</urlset>
EOF
    close($map);
}

#
#  Register the plugin.
#
Templer::Plugin::Factory->new()->register_plugin("Templer::Plugin::SiteMap");
