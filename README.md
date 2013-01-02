Templer
=======

Templer is yet another static site generator, written in Perl.

It makes use of the [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module for performing variable expansion within pages and layouts, along with looping and conditional-statement handling.

Templer has evolved over time for my own personal use, but I believe
it is sufficently generic it could be useful to others.

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
* File contents, and file-globs may be used in the templates
    * This allows the trivial creation of galleries, for example.

Another key point is that the layouts allow for more than a single
simple "content" block to be placed into them - you can add arbitrary
numbers of optional side-menus, for example.

Although this tool was written and used with the intent you'd write your
site-content in HTML you can use Textile or Markdown if you prefer.


Concepts
--------

A templer site comprises of three things:

* A global configuration file.
     * This defines the paths to search for inputs, etc.
     * This may contain global variable declerations.
     * Please see the example configuration file: [`templer.cfg`](https://raw.github.com/skx/templer/master/templer.cfg.sample).
* A layout.
    * This is used to format the output pages, defining the common look and feel.
* A series of pages & assets.
    * Pages have their content processed and inserted into the layout to produce output HTML.
    * Assets are not processed, but are copied into the output directory literally.

In general we assume there is a tree like so:

    ├── input
    │   ├── index.wgn
    │   ├── ...
    │   ├── ...
    │   ├── favicon.ico
    │   └── robots.txt
    ├── layouts
    │   └── default.layout
    ├── output
    └── templer.cfg

Every file in the input directory is either considered to be a page which is converted
into HTML, or an asset which is copied into the output-tree with no changes made.

In the example above `input/index.wgn` would become `output/index.html`.

> **NOTE** The `.wgn` suffix is an example. You can define which suffix is considered a page via the configuration file.

There is _also_ an "in-place" mode.  When working in-place there is no distinct output directory, instead output is written to the same directory in which is encountered.  Given an input directory you might see this kind of transformation:

     index.wgn           -> index.html
     about.wgn           -> about.html
     favicon.ico         [Ignored and left un-modified.]
     robots.txt          [Ignored and left un-modified.]
     ..



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


The header of the page is deliminated from the body by four dashes (`----`) and can
contain an arbitrary number of variable definitions - although by default we'd only
expect to see the page title being set.

The special variable `layout` may be used to specify a different layout for
the current page.  If there is no per-page layout then the global layout declared
in the `templer.cfg` file will be used.

The special variable `format` may be given a value of `textile` or `markdown` to
enable processing the page body with the appropriate filter.  This will work providing you
have the [dependencies installed](#installation).



Variable Definitions
--------------------

Within the header of each page you may declare an arbitrary number of per-page
variables.  These variable declerations are then available for use within the
page-body, using the standard  [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) expansion facilities:


     Title:  Page title
     Name: Steve Kemp
     ----
     <p>Hello, my name is <!-- tmpl_var name='name' -->.</p>

> The only surprise here is that we referred to the variable called "Name" as "name".  All
variable-names are transformed to lower-case for consistancy.

As well as simple "name: value" pairs there are also additional options:

* A variable may refer to the contents of a given file.
    * Using `read_file`
* A variable may refer to a list of filenames, matching a pattern.
    * Using `file_glob`

In addition to declaring variables in a page-header you may also declare
__global__ variables in your `templer.cfg` file.  This is demonstrated in
the sample [`templer.cfg`](https://raw.github.com/skx/templer/master/templer.cfg.sample) file.



File Globbing
-------------

We've already seen simple variables declared by "key: value" in the page header,
in addition to this you may define a variable that refers to a number of files
by pattern.

Here is a simple example of creating a gallery which will include files matching
the pattern `img/*.jpg`:

     Title: My gallery
     Images: file_glob( "img/*.jpg" )
     ---
     <!-- tmpl_if name='images' -->
       <!-- tmpl_loop name='images' -->
        <p><img src="<!-- tmpl_var name='file' -->" /> </p>
       <!-- /tmpl_loop -->
     <!-- tmpl_else -->
       <p>No images were found.</p>
     <!-- /tmpl_if -->

> **TIP**:  If your images are numbered numerically you can ensure their correct order by doing this:

    Title:  This is my title
    images: file_glob( img/[0-9].jpg img/1[0-9].jpg )
    ----
    <p>My gallery is now included in ascending numerical order:</p>



File Inclusion
--------------

The [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module supports file inclusion natively, via the following construct:

      <p>This is some text.</p>
      <!-- tmpl_include name='/etc/passwd' -->
      <p>That was my password file.</p>

In addition to this you may define a variable to contain the contents of a specified
file.  For example:

      Title: This file has my passwords!
      Passwd: read_file( "/etc/passwd" )
      ----
      <p>Please see my passwords:</p>
      <pre><!-- tmpl_var name='passwd' -->
      </pre>


Installation
------------

The code is modular and neat and is currently contained in a single script, this
will be changing in the near future so with that in mind the preferred installation
routine must be:

The simplest possible installation method would be this:

        $ git clone https://github.com/skx/templer.git
        $ cd templer
        $ sudo make install


The dependencies are minimal, to ease installation:

* Perl
* The [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module.
   *  This may be installed, on a Debian system, with `apt-get install libhtml-template-perl`.
* The following are optional modules:
   * The [Text::Markdown](http://search.cpan.org/perldoc?Text%3A%3AMarkdown) module is required if you wish to write your page bodies in Markdown.
      *  This may be installed, on a Debian system, with `apt-get install libtext-markdown-perl`.
   * The [Text::Textile](http://search.cpan.org/perldoc?Text%3A%3ATextile) module is required if you wish to write your page bodies in Textile.
      *  This may be installed, on a Debian system, with `apt-get install libtext-textile-perl`.


Creating a new site
-------------------

There is a supplied script `templer-generate` which will create a new site-structure
if you give in the name of a directory to create & write to:

     ~$ ./templer-generate my-site
     ~$ tree my-site/
     my-site/
      ├── input
      │   ├── about.wgn
      │   ├── index.wgn
      │   └── robots.txt
      ├── layouts
      │   └── default.layout
      ├── output
      └── templer.cfg

If you prefer you may go through the process manually creating a directory,
adding the [`templer.cfg`](https://raw.github.com/skx/templer/master/templer.cfg.sample)
to it, and then creating the input tree and layout directory.

There are two examples provided with the distribution to illustrate the
software.  These example sites are built automatically every evening and
uploaded online - so you may easily compare the input and the generated
output:

* [simple example source](https://github.com/skx/templer/tree/master/examples/simple)
   * The online [generated output](http://www.steve.org.uk/Software/templer/examples/simple/output/).
* [complex example source](https://github.com/skx/templer/tree/master/examples/complex)
   * The online [generated output](http://www.steve.org.uk/Software/templer/examples/complex/output/).

The generated "complex" example is the single best reference to the facilities and usage of the software, as it is intended as an introduction in its own right:

  *  [The reference site](http://www.steve.org.uk/Software/templer/examples/complex/output/).


Rebuilding a site
-----------------

If you're inside the directory containing your `templer.cfg` file simply
run `templer` with no arguments.  You may optionally add flags to control
what happens:

* `templer --verbose`
     * To see more details of what is happening.
* `templer --force`
     * To force a rebuild of the site.

In the general case `templer` should rebuild only the files which are needed
to be built, if you teak an include-file, or similar, it is possible you will
need to explicitly force a rebuild.


Problems
--------

Plus report an issue via the github repository:

* https://github.com/skx/templer


Author
------

Steve Kemp <steve@steve.org.uk>
