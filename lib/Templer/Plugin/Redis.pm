
=head1 NAME

Templer::Plugin::Redis - A plugin to retrieve values from Redis

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  count: redis_get( "total_count" )
  ----
  <p>There are <!-- tmpl_var name='count' --> ponies.</p>

=cut

=head1 DESCRIPTION

This plugin allows template variables to be values retrieved from
a redis store.

It is assumed that redis will be running on the localhost, if it is
not you may set the environmental variable C<REDIS_SERVER> to point
to your IP:port pair.

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

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::Redis;


=head2

Constructor.  No arguments are required/supported.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};


    bless( $self, $class );

    my $module = "use Redis;";

    ## no critic (Eval)
    eval($module);
    ## use critic

    if ( !$@ )
    {

        #
        #  OK the module was loaded, but Redis might not be
        # running locally, or accessible remotely so in those
        # cases we'll be disabled.
        #
        #  NOTE: Redis will use $ENV{'REDIS_SERVER'} if that is
        # set, otherwise defaulting to 127.0.0.1:6379.
        #
        eval {$self->{ 'redis' } = new Redis()};
    }

    return $self;
}


=head2 expand_variables

This is the method which is called by the L<Templer::Plugin::Factory>
to expand the variables contained in a L<Templer::Site::Page> object.

Variables are written in the file in the form "key: value", and are
internally stored within the Page object as a hash.

This method iterates over each key & value and updates any that
seem to refer to redis-fetches.

=cut

sub expand_variables
{
    my ( $self, $site, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "redis_get" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^redis_get\((.*)\)/ )
        {

            #
            # The lookup value.
            #
            my $rkey = $1;

            #
            #  Strip leading/trailing whitespace and quotes
            #
            $rkey =~ s/^\s+|\s+$//g;
            $rkey =~ s/^["']|['"]$//g;

            #
            #  If we have redis, and it is alive/connected, then use it.
            #
            if ( $self->{ 'redis' } &&
                 $self->{ 'redis' }->ping() )
            {
                $hash{ $key } = $self->{ 'redis' }->get($rkey);
            }
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
Templer::Plugin::Factory->new()->register_plugin("Templer::Plugin::Redis");
