Templer
=======

Templer is yet another static site generator, written in Perl.

It makes use of the
[HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module for
performing variable expansion within pages and layouts, along with looping and
conditional-statement handling.

Templer has evolved over time for my own personal use, but I believe
it is sufficiently generic it could be useful to others.

My motivation for putting it together came from the desire to change
several hand-made, HTML-coded, sites to something more maintainable such
that I could easily change the layout in one place.

The design evolved over time but the key reason for keeping it around
is that it differs from many other simple static-generators in several
ways:

* You may define global variables for use in your pages/layouts.
* A page may define and use page-specific variables.
* You may change the layout on a per-page basis if you so wish.
    * This was something that is missing from a lot of competing tools.
* Conditional variable expansion is supported, via `HTML::Template`.
* File contents, shell commands, and file-globs may be used in the templates
    * This allows the trivial creation of galleries, for example.
    * These are implemented via plugins.
    * Plugins are documented in the file [PLUGINS.md](PLUGINS.md).
* You may also embed perl code in your pages.

Another key point is that the layouts allow for more than a single
simple "content" block to be placed into them - you can add arbitrary
numbers of optional side-menus, for example.

Although this tool was written and used with the intent you'd write your
site-content in HTML you can write your input pages in Textile or Markdown
if you prefer (these inputs are supported via [plugins](PLUGINS.md)).


Concepts
--------

A templer site comprises of three things:

* A global configuration file.
    * This defines the paths to search for input pages, layout templates, plugins, etc.
    * This may contain global variable declarations.
    * Please see the example configuration file:
      [`templer.cfg`](https://raw.github.com/skx/templer/master/templer.cfg.sample).
* A layout.
    * This is used to format the output pages, defining the common look and feel.
* A series of pages & assets.
    * Pages have their content processed and inserted into the layout to produce output HTML.
    * Assets are not processed, but are copied into the output directory literally.

In general we assume there is a tree like so:

    ├── input
    │   ├── index.wgn
    │   ├── ...
    │   ├── ...
    │   ├── favicon.ico
    │   └── robots.txt
    ├── layouts
    │   └── default.layout
    ├── output
    └── templer.cfg

Every file in the input directory is either considered to be a page which is converted
into HTML, or an asset which is copied into the output-tree with no changes made.

In the example above `input/index.wgn` would become `output/index.html`.

> **NOTE** The `.wgn` suffix is an example. You can define which suffix is considered a page via the configuration file.

There is _also_ an "in-place" mode.  When working in-place there is no
distinct output directory, instead output is written to the same directory in
which is encountered.  Given an input directory you might see this kind of
transformation:

    index.wgn           -> index.html
    about.wgn           -> about.html
    favicon.ico         [Ignored and left un-modified.]
    robots.txt          [Ignored and left un-modified.]
    ..

There is _also_ a *synchronized* mode. When working synchronized any file in
the output directory which do not have a source file in input directory (page
or asset) is removed each time the site is rebuild.


Pages
-----

Your site will be made of pages, which are snippets of HTML you write.  These
snippets will be processed and inserted into the layout file before being output
to disk.

A page is a simple file which contains a header and some content.  This is
a sample page:

    Title:  This is the title page.
    ----
    <p>This is the body of the page</p>


The header of the page is delimited from the body by four dashes (`----`) and
can contain an arbitrary number of variable definitions.


Special Page Variables
-----------------------

In your page you can define, and refer to, an arbitrary number of variables
but some names are reserved - and any variable with one of those names will
be treated specially:

The special variable `layout` may be used to specify a different layout
template for the current page. If there is no per-page layout specified then
the global layout declared in the `templer.cfg` file will be used.

The special variable `template-filter` may be used to specify some filters to
apply on the used layout in order to transform it into valid `HTML::Template`
file. If there is no per-page layout filter specified then the global layout
declared in the `templer.cfg` file will be used.

The special variable `output` may be used to specify an alternative output
file.  For example the input file `index.wgn` would normally become
`index.html`, but you could make it become something else.

The special variable `format` may be given a value of `textile`, `markdown`, or
`perl` to enable processing the page body with the appropriate filter.   These
formatters are implemented as [plugins](PLUGINS.md), and will be available
assuming their [dependencies are installed](#installation).

Textile and markdown are well-known, and allow you to write your page content naturally.  The perl-formatter is used to allow you to write dynamic content in Perl in your page-body, via the [Text::Template](http://search.cpan.org/perldoc?Text%3A%3ATemplate) module.   Perl code to be executed is wrapped in `{` and `}` characters.  Here is a sample page:

    Title: This page has code in it
    format: perl
    ----

    <p>This page has some code in it.</p>
    <p>I am running on { `hostname` }...</p>
    <p>I am {
           my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                               localtime(time);
           $year += 1900;
           $year - 1976;
       } years old.</p>

> **NOTE**:  Formatters may be chained.  For example "`format: perl, markdown`".


Variable Definitions
--------------------

Within the header of each page you may declare an arbitrary number of per-page
variables.  These variable declarations are then available for use within the
page-body, using the standard  [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) expansion facilities:


    Title:  Page title
    Name: Steve Kemp
    ----
    <p>Hello, my name is <!-- tmpl_var name='name' -->.</p>

> **NOTE**: All variable-names are transformed to lower-case for consistency, which is why we refer to the variable `name` rather than the defined `Name`.

As well as simple "name: value" pairs there are also additional options implemented in [plugins](PLUGINS.md);

* A variable may refer to the contents of a given file.
    * Using `read_file`.
* A variable may refer to a list of filenames, matching a pattern.
    * Using `file_glob`.
* A variable may contain the output of running a command.
    * Using `run_command`.
* A variable may be based on the timestamp of the input page.
    * Using `timestamp`.
* A variable may contain the contents of a remote RSS feed.
    * Using `rss(count, URL)`.
* A variable may contain the result of a key-lookup from a Redis server.
    * Using `redis_get('foo')`.

In addition to declaring variables in a page-header you may also declare
__global__ variables in your `templer.cfg` file, or upon the command-line
via `--define foo=bar`.

Defining global variables is demonstrated in the sample [`templer.cfg`](https://raw.github.com/skx/templer/master/templer.cfg.sample) file.


File Globbing Variables
-----------------------

We've already seen simple variables declared by `key: value` in the page header,
in addition to this you may define a variable that refers to a number of files
by pattern.

Here is a simple example of creating a gallery which will include files matching
the pattern `img/*.jpg`:

    Title: My gallery
    Images: file_glob( "img/*.jpg" )
    ---
    <!-- tmpl_if name='images' -->
      <!-- tmpl_loop name='images' -->
       <p><img src="<!-- tmpl_var name='file' -->"
               height="<!-- tmpl_var name='height' -->"
               width="<!-- tmpl_var name='width' -->" /> </p>
      <!-- /tmpl_loop -->
    <!-- tmpl_else -->
      <p>No images were found.</p>
    <!-- /tmpl_if -->

> **TIP**:  If your images are numbered numerically you can ensure their correct order by doing this:

    Title:  This is my title
    images: file_glob( img/[0-9].jpg img/1[0-9].jpg )
    ----
    <p>My gallery is now included in ascending numerical order:</p>


This facility is implemented in the `Templer::Plugin::FileGlob` [plugin](PLUGINS.md).

The file glob is primarily designed for handling image-galleries, which is why it will set the `height` and `width` attributes if your glob matches `*.jpg`, `*.png`, etc.  However it can also be used for non-images.

If your glob matches files which are not images it will populate the member `content`, being the text-content of the matching files.  This allows you to include files easily.  For example:


    Title: This is my news-page
    news: file_glob( news-*.txt )
    ----
    <p>Here are the recent events:</p>
    <!-- tmpl_loop name='news' -->
    <p><!-- tmpl_var name='content' --></p>
    <!-- /tmpl_loop -->

This assumes you have files such as `news-20130912.txt`, etc, and will show the contents of each file in (glob)order.</p>

If matching files are templer input files then all templer variables are populated instead of the text-content of the matching files.

In all cases it will populate `dirname`, `basename` and `extension`, being parts of each matching files name.


File Inclusion
--------------

The [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module supports file inclusion natively, via the following construct:

    <p>This is some text.</p>
    <!-- tmpl_include name='/etc/passwd' -->
    <p>That was my password file.</p>

In addition to this you may define a variable to contain the contents of a specified file.  For example:

    Title: This file has my passwords!
    Passwd: read_file( "/etc/passwd" )
    ----
    <p>Please see my passwords:</p>
    <pre><!-- tmpl_var name='passwd' -->
    </pre>

This facility is implemented in the `Templer::Plugin::FileContents` [plugin](PLUGINS.md).

Include files, whether included via the `read_file` method, or via the native HTML::Template faclity, are searched for in the same fashion:

* If the filename is fully-qualified, then the absolute path-name will be used.
* Otherwise the include-path will be searched.
* After the include-path has been searched the file will be looked for in the location relative to the input page location.

This allows you to place all your include-files in a single directory which is outside your web-root.

> **TIP**: The advantage of choosing to use `read_file` over the native HTML::Template support is that with the former the output page will be automatically rebuilt if you modify the include file.


Shell Command Execution
-----------------------

Pages may also define variables which receive the value of the output of shell commands.  This is done via definitions like this:


    Title: This file is dynamic
    Host: run_command( "hostname" )
    ----
    <p>This page was built upon <!-- tmpl_var name='host' -->.</p>

This facility is implemented in the `Templer::Plugin::ShellCommand` [plugin](PLUGINS.md).


Remote RSS Feeds
----------------

Pages may use snippets of RSS feeds, limiting them to the given
number of entries.  For example:

    title: About my site
    feed: rss(4, http://blog.steve.org.uk/index.rss )
    ----
    <p>This page is about my site, here are my recent blog posts:</p>
    <ul>
    <!-- tmpl_loop name='feed' -->
        <li><a href="<!-- tmpl_var name='link' -->"><!-- tmpl_var name='title' --></a></li>
    <!-- /tmpl_loop -->
    </ul>


Redis Lookups
-------------

If you have a redis-server running upon the local system you may
configure page-variables to retrieve their values via lookups against it.

For example:

    title: Site Statistics
    count: redis_get( "global_count" )
    ----
    <p>There are <!-- tmpL-var name='count' --> entries.</p>


Installation
------------

The code is currently only available from github, but should shortly be
available from CPAN.

Installation should be as simple as any other CPAN-based module:

    $ git clone https://github.com/skx/templer.git
    $ cd templer
    $ perl Makefile.PL
    $ make test
    $ sudo make install

(If you ever wish to remove the software you may run `sudo make uninstall`.)

The code makes use of a reasonably large number of modules for its
implementation, and you can see a brief overview of [the logical structure](#object-hierarchy) later.)

The dependencies are minimal, to ease installation:

* Perl
* The [Module::Pluggable](http://search.cpan.org/perldoc?Module%3A%3APluggable) module for loading plugins.
* The [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module.
    *  This may be installed, on a Debian system, with `apt-get install libhtml-template-perl`.
* The following are optional modules:
    * The [Image::Size](http://search.cpan.org/perldoc?Image%3A%3ASize) module is used if available whenever you create `file_glob`-using loops of image files.
        * This will set the attributes `width` and `height` any images added via `file_glob`.
    * The [Text::Markdown](http://search.cpan.org/perldoc?Text%3A%3AMarkdown) module is required if you wish to write your page bodies in Markdown.
        *  This may be installed, on a Debian system, with `apt-get install libtext-markdown-perl`.
    * The [Text::Textile](http://search.cpan.org/perldoc?Text%3A%3ATextile) module is required if you wish to write your page bodies in Textile.
        *  This may be installed, on a Debian system, with `apt-get install libtext-textile-perl`.
    * The [Text::Template](http://search.cpan.org/perldoc?Text%3A%3ATemplate) module is required if you wish to include dynamic perl in your input pages.
        *  This may be installed, on a Debian system, with `apt-get install libtext-template-perl`.
    * The [Redis](http://search.cpan.org/perldoc?Redis) module is required if you wish to use the Redis plugin.
        *  This may be installed, on a Debian system, with `apt-get install libredis-perl`.
    * The [XML::Feed](http://search.cpan.org/perldoc?XML%3A%3AFeed) module is required if you wish to use the RSS plugin.
        *  This may be installed, on a Debian system, with `apt-get install libxml-feed-perl`.


Creating a new site
-------------------

There is a supplied script `templer-generate` which will create a new site-structure
if you give in the name of a directory to create & write to:

    ~$ templer-generate my-site
    ~$ tree my-site/
    my-site/
    ├── include
    ├── input
    │   ├── about.wgn
    │   ├── index.wgn
    │   └── robots.txt
    ├── layouts
    │   └── default.layout
    ├── output
    └── templer.cfg

If you prefer you may go through the process manually creating a directory,
adding the [`templer.cfg`](https://raw.github.com/skx/templer/master/templer.cfg.sample)
to it, and then creating the input tree and layout directory.

There are several [examples](examples/) provided with the distribution to illustrate the
software.  These example sites are built automatically every evening and
uploaded online - so you may easily compare the input and the generated
output:

* [simple example source](https://github.com/skx/templer/tree/master/examples/simple)
    * The online [generated output](http://www.steve.org.uk/Software/templer/examples/simple/output/).
* [complex example source](https://github.com/skx/templer/tree/master/examples/complex)
    * The online [generated output](http://www.steve.org.uk/Software/templer/examples/complex/output/).
    * The generated "complex" example is designed to be a standalone introduction to templer.


Rebuilding a site
-----------------

If you're beneath the directory containing your `templer.cfg` file simply
run `templer` with no arguments.  You may optionally add flags to control
what happens:

* `templer --verbose`
    * To see more details of what is happening.
* `templer --force`
    * To force a rebuild of the site.
* `templer --define foo=bar`
    * Define the variable `foo` for use in your templates.  This will over-ride any setting of foo in the configuration file you've loaded.

In the general case `templer` should rebuild only the files which are needed
to be built.  A page will be rebuilt if:

* The page source is edited.
* The layout the page uses is edited.
* Any include-file the page includes is edited.
    * This applies to those includes read via [read_file](#file-inclusion) rather than via `HTML::Template` includes

> Previously it was required that you run `templer` from the top-level of your site, this has now changed.  `templer` will walk upwards from the current working directory and attempt to find the site-root by itself.


Object Hierarchy
----------------

Although `templer` is distributed and used as a single script it is written
using a series of objects.  Bundling into a single binary allows for easier
distribution, installation and usage.

In brief the control flow goes like this:

* `templer` runs, parses the command line, etc.
* A `Templer::Global` object is created to read the `templer.cfg` file, or the file passed via `--config=foo`.
* The options from the command-line and the config file are merged.
* From this point onwards `Templer::Global` is ignored.
* A `Templer::Site` object is created, using the merged config values.
* A `Templer::Timer` object is created to record the build-time.
* The build process is contained in `Templer::Site::build()`:
    * A `Templer::Plugin::Factory` object is created to load plugins.
    * A `Templer::Site::Page` object is created for each appropriate input.
    * Each page is output.
    * The plugins are unloaded.
* The assets are copied via `Templer::Site::copyAssets()`.
* The output directory is cleaned via `Templer::Site::sync()`.
* The build-time/build-count is reported and the process is complete.

Each of the modules has a simple test-case associated with it.  To test functionality, especially after making changes, please run the test-suite:

    $ make test
    prove --shuffle t/
    t/style-no-tabs.t ........................... ok
    t/test-dependencies.t ....................... ok
    ..
    ..
    t/test-templer-plugin-filecontents.t ........ ok
    t/test-templer-site.t ....................... ok
    t/test-templer-plugin-timestamp.t ........... ok
    All tests successful.
    Files=15, Tests=286,  1 wallclock secs ( 0.11 usr  0.01 sys +  0.88 cusr  0.14 csys =  1.14 CPU)
    Result: PASS

Any test-case failure is a bug, and should be reported as such.


Problems
--------

Please report any issue via the github repository:

* https://github.com/skx/templer


Author
------

Steve Kemp <steve@steve.org.uk>
