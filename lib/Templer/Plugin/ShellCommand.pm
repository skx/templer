
=head1 NAME

Templer::Plugin::ShellCommand - A plugin to execute commands.

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  hostname: run_command( hostname )
  uptime: run_command( uptime )
  ----
  <p>This is <!-- tmpl_var name='hostname' -->, with uptime of
  <!-- tmpl_var name='uptime' -->.</p>

=cut

=head1 DESCRIPTION

This plugin allows template variables to be set to the output of
executing shell-commands.

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


package Templer::Plugin::ShellCommand;


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
    my ( $self, $page, $data ) = (@_);

    #
    #  Get the page-variables in the template.
    #
    my %hash = %$data;

    #
    #  Look for a value of "run_command" in each key.
    #
    foreach my $key ( keys %hash )
    {
        if ( $hash{ $key } =~ /^run_command\((.*)\)/ )
        {

            #
            # Run a system command, and capture the output.
            #
            my $cmd = $1;

            #
            #  Strip leading/trailing whitespace.
            #
            $cmd =~ s/^\s+|\s+$//g;

            $hash{ $key } = `$cmd`;
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
  ->register_plugin("Templer::Plugin::ShellCommand");
