Templer
=======

Templer is yet another static site generator, written in Perl.

It makes use of the [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module for performing template and variable expansion.

The tool has evolved for my own personal usage over time, but I believe
it is sufficently generic it could be useful to others.

My motivation for putting it together came from the desire to change
several hand-made, HTML-coded, sites to something more maintainable such
that I could change the layout in one place.  This explains why there is
no shortcut to writing the content; Markdown, Textile, etc are not supported
because it is assumed your content is written in HTML.

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


Concepts
--------

A templer site comprises of three things:

* A global configuration file.
     * This defines the paths to search for inputs, templates, etc.
* A layout.
    * This is used to build the output pages, and defines the common layout.
* A series of pages & assets.
    * Pages have their content processed and inserted into the layout to produce output HTML.
    * Assets are not processed, but are copied into the output directory untouched.

In general we assume there is a tree like so:

    ├── input
    │   ├── index.skx
    │   ├── ...
    │   ├── ...
    │   ├── favicon.ico
    │   └── robots.txt
    ├── layouts
    │   └── default.layout
    ├── output
    └── templer.cfg

Every file in the input directory is either processed, and converted into a HTML file,
or copied literally to the output directory.

In the example above `input/index.skx` would become `output/index.html`.  (Note that the `.skx` suffix is an example, via the global configuration file you can specify any suffix you wish).

There is _also_ an "in-place" mode.  When working in-place there is no distinct output directory, instead output is written to the same directory in which is encountered.  Given an input directory you might see this kind of transformation:

     index.skx           -> index.html
     about.skx           -> about.html
     favicon.ico         [Ignored and left un-modified.]
     robots.txt          [Ignored and left un-modified.]
     ..




Installation
------------

The code is modular and neat, but it is deliberately contained in a single
script.  This means installation is limited to copying the script to a
directory on your PATH.

The two dependencies are:

* Perl
* The [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module.
   *  This may be installed, on a Debian system, with `apt-get install libhtml-template-perl`.

It is possible in the future that Markdown, Textile, or similar will be supported.
If that is the case they will be 100% optional.  I have no wish to increase the
dependencies.


Creating a new site
-------------------

Simply create a directory and copy the [`templer.cfg.sample`](https://raw.github.com/skx/templer/master/templer.cfg.sample) into it, renaming
it to `templer.cfg`.  This file should then be editted to define where your
input tree is.

The input-tree is the collection of files that will be template-expanded
into a layout.  So you'll also want to create a layout directory and place
at least one layout into it.

There are two examples provided with the distribution, to illustrate the
software.  These example sites are built automatically every evening and
uploaded online - so you may easily compare the input and the generated
output:

* [simple example source](https://github.com/skx/templer/tree/master/examples/simple)
   * The online [generated output](http://www.steve.org.uk/Software/templer/examples/simple/output/).
* [complex example source](https://github.com/skx/templer/tree/master/examples/complex)
   * The online [generated output](http://www.steve.org.uk/Software/templer/examples/complex/output/).


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
