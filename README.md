Templer
=======

Templer is yet another static site generator, written in Perl.

It makes use of the [HTML::Template](http://search.cpan.org/perldoc?HTML%3A%3ATemplate) module for performing template and variable expansion.

The tool has evolved for my own personal usage over time, but I believe
I've made it sufficently generic it would be useful to others.

My motivation for putting it together came from the desire to change
several hand-made, HTML-coded, sites to something more maintainable such
that I could change the layout in one place.  This explains why there is
no shortcut to writing the content, such as the use of Markdown, Textile,
or similar.

The design evolved over time but the key reason for keeping it around
is that it differs from other simple static-generators in a couple of
key regards:

* You may define global variables for use in your pages/layouts.
* A page may define and use page-specific variables.
* You may change the layout on a per-page basis if you so wish.
* Conditional variable expansion is supported, via `HTML::Template`.
* File contents, and file-globs may be used in the templates
    * This allows the trivial creation of galleries, for example.

Another key point is that the layouts allow for more than a single
simple "content" block to be placed into them - you can add arbitrary
numbers of optional side-menus, for example.


Concepts
--------

**TODO** :

* A site comprises of a number of pages and assets.
    * A page is a piece of your content which is processed.
    * An asset is something which is copied into the output directory with no changes amade to t.



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
