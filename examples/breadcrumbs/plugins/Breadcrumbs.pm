
=head1 NAME

Templer::Plugin::Breadcrumbs - A plugin to create breadcrumbs

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  crumbs: Home,Software
  ----
  <p>This is my password file:</p>
  <!-- tmpl_var name='passwd' -->

=cut

=head1 DESCRIPTION

This plugin expands the values of "crumbs", as written in a template, to
the HTML-variable "breadcrumbs".

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


package Templer::Plugin::Breadcrumbs;


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
seem to refer to file-inclusion.

=cut

sub expand_variables
{
    my ( $self, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "read_file" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if (  $key =~ /^crumbs$/i )
        {
            my $val = $hash{$key};
            print $page->source() . "\n";

            my $link = "/";

            my $tmp = "";

            $tmp .= "<ul class=\"breadcrumbs\">\n";
            foreach my $path ( split( /,/, $val ) )
            {
                $path =~ s/^\s+|\s+$//g;

                if ( $path =~ /Home/i )
                {
                }
                else
                {
                    $link .= "/" . $path;
                }

                $link =~ s/\/\//\//g;
                $tmp .= "<li><a href=\"$link\">" . ucfirst($path) . "</a></li>\n";
            }
            $tmp .= "</ul>\n";

            $hash{ 'breadcrumbs' } = $tmp;
            delete $hash{$key} ;
        }
    }

    return ( \%hash );
}


#
#  Register the plugin.
#
Templer::Plugin::Factory->new()
  ->register_plugin("Templer::Plugin::Breadcrumbs");
