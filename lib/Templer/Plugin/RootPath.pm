
=head1 NAME

Templer::Plugin::RootPath - A plugin to add path to web-root to variables.

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  css: path_to(css)
  ----
  <p>CSS files are stored in <!-- tmpl_var name='css' -->.

This is mainly useful as global variables used in the default layout.

=cut

=head1 DESCRIPTION

This plugin allows template variables (considered as absolute path from the
web-root) to be set to a correct relative path from any page of the website.

An empty call to C<path_to> may be used to compute the relative path to the
web-root.

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

Bruno BEAUFILS <bruno@boulgour.com>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 Bruno BEAUFILS <bruno@boulgour.com>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::RootPath;


=head2

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


=head2 expand_variables

This is the method which is called by the L<Templer::Plugin::Factory>
to expand the variables contained in a L<Templer::Site::Page> object.

Variables are written in the file in the form "key: value", and are
internally stored within the Page object as a hash.

This method iterates over each key & value and updates any that
seem to refer to file-paths.

=cut

sub expand_variables
{
    my ( $self, $site, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    # Compute the path to the web-root
    #
    return ( \%hash ) if ( ! $page );

    my $root_path = $page->source()     || "";
    my $input     = $site->get("input") || "";
    $root_path =~ s{^$input}{./};     # Change leading input path
    $root_path =~ s{[^/]+$}{};        # Remove trailing pagename
    $root_path =~ s{/[^/]+}{/..}g;    # Replace directories by ..
    $root_path =~ s{/$}{};            # Remove trailing /
    $root_path =~ s{^./}{};           # Remove leading ./ if still there


    #
    #  Look for a value of "path_to" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^path_to\((.*)\)/ )
        {
            my $path = $1;

            #
            #  Strip leading/trailing whitespace.
            #
            $path =~ s/^\s+|\s+$//g;

            #
            # Ensure path is absolute
            #
            if ( $path )
            {
                $path = "/$path";
                $path =~ s{^/+}{/};
            }

            #
            #  Store specified path starting from web-root.
            #
            $hash{ $key } = "$root_path$path";
        }
    }

    #
    #  Return.
    #
    return ( \%hash );
}


#
#  Register the plugin.
#
Templer::Plugin::Factory->new()->register_plugin("Templer::Plugin::RootPath");
