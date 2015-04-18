
=head1 NAME

Templer::Plugin::Breadcrumbs - A plugin to create breadcrumbs

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  crumbs: Home,Software
  ----
  <p>This is my page content...</p>


Here the variable 'crumbs' will be converted into a loop variable called
'breadcrumbs'.  THe links and titls will be set automatically, but if you
need to override them you can do so via:

  title: About my site
  crumbs: Home,Software[Soft],Testing[Test]
  ----
  <p>This is my page content...</p>


That will result in links to /, /Soft, and /Soft/Test, respectively.  With
display names of "Home", "Software" and "Testing".

=cut

=head1 DESCRIPTION

This plugin expands the values of "crumbs", as written in a template, to
a loop-variable with the name "breadcrumbs".

This can be used in a template like so:

=for example begin

   <!-- tmpl_if name='breadcrumbs' -->
   <ul>
   <!-- tmpl_loop name='breadcrumbs' -->
    <li><a href="<!-- tmpl_var name='link' -->"><!-- tmpl_var name='title' --></a></li>
   <!-- /tmpl_loop -->
   </ul>
   <!-- /tmpl_if -->

=for example end

This template is an example.

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

Copyright (C) 2015 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::Breadcrumbs;


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



=head2 expand_variables

This is the method which is called by the L<Templer::Plugin::Factory>
to expand the variables contained in a L<Templer::Site::Page> object.

This method will expand any variable that is called 'crumbs' into a HTML::Template
loop, suitable for the display of breadcrumbs.

=cut

sub expand_variables
{
    my ( $self, $site, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "read_file" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $key =~ /^crumbs$/i )
        {
            my $loop;

            my $val  = $hash{ $key };
            my $link = "/";

            foreach my $path ( split( /,/, $val ) )
            {
                $path =~ s/^\s+|\s+$//g;

                if ( $path =~ /Home/i )
                {
                }
                else
                {
                    if ( $path =~ /(.*)\[(.*)\]/ )
                    {
                        $link .= "/" . $1;
                    }
                    else
                    {
                        $link .= "/" . $path;
                    }
                }

                $link =~ s/\/\//\//g;

                if ( $path =~ /\[(.*)\]/ )
                {
                    $path = $1;
                }
                else
                {
                    $path = ucfirst($path);
                }
                push( @$loop,
                      {  title => $path,
                         link  => $link
                      } );
            }


            $hash{ 'breadcrumbs' } = $loop if ($loop);
            delete $hash{ $key };
        }
    }

    return ( \%hash );
}


#
#  Register the plugin.
#
Templer::Plugin::Factory->new()
  ->register_plugin("Templer::Plugin::Breadcrumbs");
