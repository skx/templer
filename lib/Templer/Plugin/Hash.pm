
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

Copyright (C) 2014-2014 Steve Kemp <steve@steve.org.uk>.

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
            #  If the file is unqualified then make it refer to the
            # path of the source file.
            #
            my $dirName = $page->source();
            if ( $dirName =~ /^(.*)\/(.*)$/ )
            {
                $dirName = $1;
            }
            my $pwd = Cwd::cwd();
            chdir( $dirName . "/" );

            #
            #
            #  Setup the two new variables.
            #
            $hash{ $key . "_src" } = $file;

            my $sha1 = $self->hash_file($file);
            $hash{ $key . "_hash" } = $sha1;

            if ( $site->{ 'verbose' } )
            {
                print "Hash of $file is $sha1\n";
            }


            #
            #  Delete the original one.
            #
            delete $hash{ $key };


            #
            #  Restore the PWD.
            #
            chdir($pwd);

        }
    }

    return ( \%hash );
}

#
#  Return the SHA1 hash of the file contents.
#
sub hash_file
{
    my ( $self, $file ) = (@_);

    my $hash = undef;

    foreach my $module (qw! Digest::SHA Digest::SHA1 !)
    {

        # If we succeeded in calculating the hash we're done.
        next if ( defined($hash) );

        # Attempt to load the module
        my $eval = "use $module;";

        ## no critic (Eval)
        eval($eval);
        ## use critic

        #
        #  Loaded module, with no errors.
        #
        if ( !$@ )
        {
            my $object = $module->new;

            open my $handle, "<", $file or
              die "Failed to read $file to hash contents with $module - $!";
            $object->addfile($handle);
            close($handle);

            $hash = $object->hexdigest();
        }
    }

    unless ( defined $hash )
    {
        die "Failed to calculate hash of $file - internal error.";
    }

    return ($hash);
}


#
#  Register the plugin.
#
Templer::Plugin::Factory->new()->register_plugin("Templer::Plugin::Hash");
