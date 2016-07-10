
=head1 NAME

Templer::Plugin::RSS - A plugin to include RSS feeds in pages.

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  feed: rss(4, http://blog.steve.org.uk/index.rss )
  ----
  <p>This is my page content.</p>
  <ul>
  <!-- tmpl_loop name='feed' -->
    <li><a href="<!-- tmpl_var name='link' -->"><!-- tmpl_var name='title' --></a></li>
  <!-- /tmpl_loop -->
  </ul>


Here the variable 'feed' will contain the first four elements of the
RSS feed my blog produces.

The feed entries will contain the following three attributes

=over 8

=item author
The author of the post.

=item link
The link to the post.

=item title
The title of the popst

=back

=cut

=head1 DESCRIPTION

This plugin uses L<XML::Feed> to extract remote RSS feeds and allow
them to be included in your site bodies - if that module is not
available then the plugin will disable itself.

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


package Templer::Plugin::RSS;


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

This method will expand any variable that has a defintion of the
form "rss( NN, http... )" and replace the variable definition
with the result of fetching that RSS feed.

=cut

sub expand_variables
{
    my ( $self, $site, $page, $data ) = (@_);


    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;


    #
    #  Load XML::Feed if we can
    #
    my $module = "use XML::Feed";

    ## no critic (Eval)
    eval($module);
    ## use critic

    #
    #  If there were errors loading the module then we're done.
    #
    return ( \%hash ) if ($@);

    #
    #  Look for a value of "read_file" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^rss\(\s?([0-9]+)\s?,\s?(https?:\/\/.*)\s?\)/ )
        {
            my $count = $1;
            my $link  = $2;

            $link =~ s/^\s+|\s+$//g;
            $count =~ s/^\s+|\s+$//g;

            # remove the variable.
            delete( $hash{ $key } );

            # try to parse the feed.
            my $feed = XML::Feed->parse( URI->new($link) );

            if ($feed)
            {
                my $tmp;

                # loop over entries.
                for my $entry ( $feed->entries )
                {
                    if ( $count > 0 )
                    {
                        push( @$tmp,
                              {  link   => $entry->link,
                                 author => $entry->author,
                                 title  => $entry->title
                              } );
                    }
                    $count = $count - 1;
                }

                # store the expanded feed.
                $hash{ $key } = $tmp;
            }
            else
            {
                print "WARNING: Failed to fetch $link\n";
            }
        }
    }

    return ( \%hash );
}


#
#  Register the plugin.
#
Templer::Plugin::Factory->new()->register_plugin("Templer::Plugin::RSS");
