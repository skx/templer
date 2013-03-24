
=head1 NAME

Templer::Plugin::Timestamp - A plugin to get timestamp of source files

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  mtime: timestamp(%Y-%m-%d %H:M:%S)
  ----
  <p>This file has been last modified on <!-- tmpl_var name='mtime' -->.

=cut

=head1 DESCRIPTION

This plugin allows template variables to be set to the source file
modification time. The parameter passed to the function are passed as is to
strftime with leading and trailing spaces removed.

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


package Templer::Plugin::Timestamp;


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
seem to refer to shell commands.

=cut

sub expand_variables
{
    my ( $self, $global_cfg, $page, $data ) = (@_);

    #
    # Get properties of the source file
    #
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks)
      = stat($page->source());
    my @mtime = localtime($mtime);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "timestamp" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^timestamp\((.*)\)/ )
        {
            my $ts = $1;

            #
            #  Strip leading/trailing whitespace.
            #
            $ts =~ s/^\s+|\s+$//g;

            #
            # Store formatted modification time
            #
            use POSIX qw{strftime};
            $hash{ $key } = strftime $ts, @mtime;
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
Templer::Plugin::Factory->new()
  ->register_plugin("Templer::Plugin::Timestamp");
