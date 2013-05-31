
=head1 NAME

Templer::Plugin::Hash - Create SHA1 hashes from file contents.

=cut

=head1 SYNOPSIS

The following is a good example use of this plugin

  title: About my site
  hash: hash_file( "slaughter-2.7.tar.gz" )
  ----
  <p><!-- tmpl_var name='hash_src' --> has hash <!-- tmpl_var name='hash_val' --></p>


=cut

=head1 DESCRIPTION

Given a use of hash_file two variables will be populated, one containing the
path to the file, and one containing the hash.

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

Copyright (C) 2013 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut


use strict;
use warnings;


package Templer::Plugin::Hash;


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

This method will expand any variable that has a value of 'hash_file(.*)'
into two variables accessible from your template.

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
        if ( $hash{ $key } =~ /^hash_file\((.*)\)/ )
        {

            #
            #  Get the filename specified.
            #
            my $file = $1;

            #
            #  Strip leading/trailing quotes and whitespace.
            #
            $file =~ s/['"]//g;
            $file =~ s/^\s+|\s+$//g;

            #
            #  Setup the two new variables.
            #
            $hash{ $key . "_src" }  = $file;
            $hash{ $key . "_hash" } = $self->hash_file($file);

            #
            #  Delete the original one.
            #
            delete $hash{ $key };

        }
    }

    return ( \%hash );
}

#
#  Return the hash of the file.
#
sub hash_file
{
    my ( $self, $file ) = (@_);

    my $str = "use Digest::SHA1;";

    ## no critic (Eval)
    eval($str);
    ## use critic

    return ("Digest::SHA1 not installed") if ($@);

    #
    #  Open the file.
    #
    open( my $handle, "<", $file ) or
      return "Failed to open $file - $!";


    #
    #  Get the hash.
    #
    my $sha1 = Digest::SHA1->new();
    $sha1->addfile($handle);
    my $result = $sha1->hexdigest();

    #
    #  Close the file
    #
    close($handle);

    #
    #  Return the result.
    #
    return ($result);
}


#
#  Register the plugin.
#
Templer::Plugin::Factory->new()->register_plugin("Templer::Plugin::Hash");
