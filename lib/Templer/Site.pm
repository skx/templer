
=head1 NAME

Templer::Site - An interface to a templer site.

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Templer::Site;

    # Create the helper.
    my $site   = Templer::Site->new( suffix => ".skx" );

    # Get the pages/assets.
    my @pages  = $site->pages();
    my @assets = $site->assets();

=cut

=head1 DESCRIPTION

This class encapsulates a site.  A site is comprised of "pages" and "assets".

=over 8

=item Pages

Pages are things which are template expanded.  These are represented
by instances of the C<Templer::Site::Page> class.

=item Assets

Assets are files that are merely copied from the input directory to
the output path.  If we're running in "in-place" mode then they are
ignored.

Assets are represented by instances of the C<Templer::Site::Assets> class.

=back

This class contains helpers for finding and returning arrays of
both such objects, and the code necessary to work with them and build
a site.

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


use strict;
use warnings;



package Templer::Site;


use Data::Dumper;
use File::Find;
use File::Path qw! mkpath !;
use HTML::Template;



=head2 new

Constructor, this should be given a hash of arguments for example:

=over 8

=item input

The input directory to process.

=item output

The output directory to write to.

=item suffix

The suffixe that will discover "Pages", for example '.skx', or '.tmplr'.

=cut

=back

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};

    #
    #  Allow user supplied values to override our defaults
    #
    foreach my $key ( keys %supplied )
    {
        $self->{ lc $key } = $supplied{ $key };
    }

    bless( $self, $class );
    return $self;
}



=head2 init

Ensure that the input directory exists.

Create the output directory if we're not running in-place.

=cut

sub init
{
    my ($self) = (@_);

    #
    #  Ensure we have an input directory.
    #
    my $input = $self->{ 'input' };
    if ( !-d $input )
    {
        print "The input directory doesn't exist: $input\n";
        exit;
    }

    #
    # Ensure input directory contains a unique trailing /
    #
    $self->{ 'input' } .= "/";
    $self->{ 'input' } =~ s{/+$}{/};

    #
    # Ensure output directory contains a unique trailing /
    #
    $self->{ 'output' } .= "/";
    $self->{ 'output' } =~ s{/+$}{/};

    #
    #  Create the output directory if missing, unless we're in-place
    #
    my $output  = $self->{ 'output' };
    my $inplace = $self->{ 'in-place' };

    File::Path::mkpath( $output, { verbose => 0, mode => oct(755) } )
      if ( !-d $output && ( !$inplace ) );

}


=head2 pages

A site comprises of a collection of pages and a collection of static resources
which aren't touched/modified - these are "assets".

Return a C<Templer::Site::Page> object for each page we've found.

B<NOTE> We don't process pages with a "." prefix, i.e. dotfiles.

=cut

sub pages
{
    my ( $self, %args ) = (@_);

    my $dir    = $args{ 'directory' } || $self->{ 'directory' };
    my $suffix = $args{ 'suffix' }    || $self->{ 'suffix' };

    return (
             $self->_findFiles( must_match    => $suffix . "\$",
                                object        => "Templer::Site::Page",
                                directory     => $dir,
                                hide_dotfiles => 1,
                              ) );
}


=head2 assets

A site comprises of a collection of pages and a collection of static resources
which aren't touched/modified - these are "assets".

Return a C<Templer::Site::Asset> object for each asset we find.

B<NOTE> We include files which have a "." prefix here - to correctly
copy files such as ".htpasswd", ".htaccess", etc.

=cut

sub assets
{
    my ( $self, %args ) = (@_);

    my $dir    = $args{ 'directory' } || $self->{ 'directory' };
    my $suffix = $args{ 'suffix' }    || $self->{ 'suffix' };

    return (
             $self->_findFiles( must_not_match => $suffix . "\$",
                                object         => "Templer::Site::Asset",
                                directory      => $dir,
                                hide_dotfiles  => 0,
                              ) );

}


=head2 _findFiles

Internal method to find files beneath the given directory and return a new object
for each one.

We assume that the object constructor receives a hash as its sole
argument with the key "file" containing the file path.

=cut

sub _findFiles
{
    my ( $self, %args ) = (@_);

    #
    # Remove the trailing "/" on the end of the directory to search.
    #
    $args{ 'directory' } =~ s/\/$//g;

    #
    # Should we hide dotfiles?
    #
    my $dotfiles = $args{ 'hide_dotfiles' };


    #
    #  Files we've found.  Ignoring the suffix just now.
    #
    my %files;

    File::Find::find( {
           wanted => sub {
               my $name = $File::Find::name;
               $files{ $name } += 1 unless ( $dotfiles && ( $name =~ /\/\./ ) );
           },
           follow   => 0,
           no_chdir => 1
        },
        $args{ 'directory' } );

    #
    # Remove the input
    #
    delete $files{ $args{ 'directory' } };

    #
    #  OK now we need to find the matches.
    #
    my @matches;

    #
    #  The class-object we're going to construct.
    #
    my $class = $args{ 'object' };

    if ( $args{ 'must_match' } )
    {
        foreach my $file ( sort keys %files )
        {
            next if ( -d $file );
            next unless ( $file =~ /$args{'must_match'}/ );
            push( @matches, $class->new( file => $file ) );
        }
    }
    elsif ( $args{ 'must_not_match' } )
    {
        foreach my $file ( sort keys %files )
        {
            next if ( $file =~ /$args{'must_not_match'}/ );
            push( @matches, $class->new( file => $file ) );
        }
    }

    @matches;
}



=head2 build

Build the site.

This is the method which does all the page-expansion, site-generation, etc.

The return value is the count of pages built.

=cut

sub build
{
    my ($self) = (@_);

    #
    #  If we have a plugin directory then load the plugins beneath it.
    #
    #  NOTE:  The bundled/built-in plugins will always be available.
    #
    my $PLUGINS = Templer::Plugin::Factory->new();
    if ( -d $self->{ 'plugin-path' } )
    {
        print "Loading plugins from :  $self->{ 'plugin-path' }\n"
          if ( $self->{ 'verbose' } );

        $PLUGINS->load_plugins( $self->{ 'plugin-path' } );
    }


    #
    #  Setup an array of include-paths.
    #
    my @INCLUDES;
    foreach my $path ( split( /:/, $self->{ 'include-path' } ) )
    {
        push( @INCLUDES, $path ) if ( -d $path );
    }
    $self->set( "include-path", \@INCLUDES );


    #
    #  Find all the pages we'll process.
    #
    #  (Assets are copied later.)
    #
    my @pages = $self->pages( directory => $self->{ 'input' } );


    #
    #  A count of the pages we've rebuilt.
    #
    my $rebuilt = 0;

    #
    #  For each page we've found.
    #
    foreach my $page (@pages)
    {

        #
        # The path of the page, on-disk.
        #
        my $src = $page->source();
        print "\nProcessing page: $src\n" if ( $self->{ 'verbose' } );


        #
        # Convert the input path to a suitable output path.
        #
        my $dst = $src;

        #
        #  The page might have its own idea of where it wants to
        # go - so set that if it is set.
        #
        if ( $page->field("output") )
        {
            $dst = $self->{ 'output' } . $page->field("output");
        }
        else
        {
            $dst =~ s/^$self->{'input'}/$self->{'output'}/g
              unless ( $self->{ 'in-place' } );

            $dst =~ s/$self->{'suffix'}/.html/g;
        }


        #
        # Show the transformation.
        #
        print "File: $src\n" if ( $self->{ 'verbose' } );
        print "Dest: $dst\n" if ( $self->{ 'verbose' } );


        #
        # The template to expand the content into will come from the page, or
        # the global configuration object.
        #
        my $template = $page->layout() ||
          $self->{ 'layout' };
        print "Layout file is: $self->{'layout-path'}/$template\n"
          if ( $self->{ 'verbose' } );

        #
        # Ensure the template exists.
        #
        if ( !-e $self->{ 'layout-path' } . "/" . $template )
        {
            print
              "WARNING: Layout file missing: $self->{'layout-path'}/$template\n";
            next;
        }


        #
        #  Load the HTML::Template module against the layout.
        #
        my $tmpl =
          HTML::Template->new(
                         filename => $self->{ 'layout-path' } . "/" . $template,
                         die_on_bad_params => 0,
                         path => [@INCLUDES, $self->{ 'layout-path' }],
                         search_path_on_include => 1,
                         global_vars            => 1,
                         loop_context_vars      => 1,
                         utf8                   => 1,
          );

        #
        #  The template-data we'll expand for the page/template.
        #
        #  (All fields from the page, and from the configuration file.)
        #
        my %data = ( $self->fields(), $page->fields() );

        #
        #  Use the plugin-factory to expand each of the variables.
        #
        my $ref = $PLUGINS->expand_variables( $self, $page, \%data );
        %data = %$ref;


        if ( $self->{ 'debug' } )
        {
            print "Post-expansion variables on : $src\n";
            print "\t" . Dumper( \%data );
        }


        #
        #  At this point we can tell if we need to rebuild the page.
        #
        #  We want to build the page if:
        #
        #    *  The output page is missing.
        #
        #    * The input page, or any dependancy is newer than the output.
        #
        my $rebuild = 0;
        $rebuild = 1 if ( !-e $dst );

        if ( !$rebuild )
        {

            #
            #  Get the dependencies of the page - add in the page source,
            # and the template path.
            #
            my @deps = ( $self->{ 'layout-path' } . "/" . $template,
                         $page->source(), $page->dependencies() );

            foreach my $d (@deps)
            {
                if ( -M $d < -M $dst )
                {
                    $self->{ 'verbose' } &&
                      print "Triggering rebuild: $d is more recent than $dst\n";
                    $rebuild = 1;
                }
            }
        }

        #
        #  Forced rebuild via the command-line.
        #
        $rebuild = 1 if ( $self->{ 'force' } );

        #
        #  OK skip if we're not rebuilding, otherwise increase the count.
        #
        next unless ($rebuild);
        $rebuilt += 1;


        #
        #  Load the HTML::Template module against the body of the page.
        #
        #  (Includes are relative to the path of the input.)
        #
        my $dirName = $page->source();
        if ( $dirName =~ /^(.*)\/(.*)$/ )
        {
            $dirName = $1;
        }
        my $body = HTML::Template->new( scalarref => \$page->content( \%data ),
                                        die_on_bad_params => 0,
                                        path => [@INCLUDES, $dirName],
                                        search_path_on_include => 1,
                                        global_vars            => 1,
                                        loop_context_vars      => 1,
                                        utf8                   => 1,
                                      );


        #
        #  Template-expand the body of the page.
        #
        $body->param( \%data );
        $data{ 'content' } = $body->output();


        #
        # Make the (updated) global and per-page data available
        # to the template object.
        #
        $tmpl->param( \%data );

        #
        # Make sure the output path exists.
        #
        my $path = $dst;
        if ( $path =~ /^(.*)\/(.*)$/ )
        {
            $path = $1;
            File::Path::mkpath( $path, { verbose => 0, mode => oct(755) } )
              if ( !-d $path );
        }

        #
        #  Output the expanded template to the destination file.
        #
        open my $handle, ">:utf8", $dst or die "Failed to write to '$dst' - $!";
        binmode( $handle, ":utf8" );
        print $handle $tmpl->output();
        close $handle;
    }

    #
    #  Cleanup any plugins.
    #
    $PLUGINS->cleanup();

    #
    #  Return count of rebuilt pages.
    #
    return ($rebuilt);
}


=head2 copyAssets

Copy all assets from the input directory to the output directory.

This method will use tar to do so semi-efficiently.

=cut

sub copyAssets
{
    my ($self) = (@_);


    #
    #  If we're running in-place then we don't need to copy assets.
    #
    return if ( $self->{ 'in-place' } );

    #
    #  The assets.
    #
    my @assets = $self->assets( directory => $self->{ 'input' } );

    #
    #  The files we're going to copy.
    #
    my @copy;


    #
    # We're going to build-up a command line to pass to tar
    #
    foreach my $asset (@assets)
    {

        #
        # Strip the input component of the filename(s).
        #
        my $src = $asset->source();
        $src =~ s/^$self->{'input'}//g;

        #
        # Filenames must be shell safe: we'll use it in a shell command
        #
        my $quoted_src;
        if ( $src =~ /\'/ )
        {
            ( $quoted_src = "$src" ) =~ s{\\}{\\\\}g;
            $quoted_src =~ s{\"}{\\\"}g;
            $quoted_src =~ s{\$}{\\\$}g;
            $quoted_src =~ s{\`}{\\\`}g;
            $quoted_src = "\"$quoted_src\"";
        }
        else
        {
            $quoted_src = "'$src'";
        }

        #
        # If we've got an asset which is a directory that
        # is already present, for example, we'll skip it.
        #
        push( @copy, $quoted_src ) unless ( -e "$self->{'output'}/$src" );
    }

    #
    # Run the copy, unless all files are present.
    #
    if ( scalar @copy ne 0 )
    {

        #
        # The horrible command we're going to execute.
        #
        my $cmd = "(cd $self->{'input'} && tar -cf - " .
          join( " ", @copy ) . ") | ( cd $self->{'output'} && tar xf -)";
        print "TAR: $cmd " if ( $self->{ 'verbose' } );
        system($cmd );
    }
}


=head2 set

Store/update a key/value pair in our internal store.

This allows the values passed in the constructor to be updated/added to.

=cut

sub set
{
    my ( $self, $key, $values ) = (@_);
    $self->{ $key } = $values;
}


=head2 fields

Get all known key + value pairs from our store.

This is called to get all global variables for template interpolation
as part of the build.  (The global variables and the per-page variables
are each fetched and expanded via plugins prior to getting sent to the
HTML::Template object.).

=cut

sub fields
{
    my ($self) = (@_);

    %$self;
}


=head2 get

Get a single value from our store of variables.

=cut

sub get
{
    my ( $self, $field ) = (@_);
    return ( $self->{ $field } );
}



1;
