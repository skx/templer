Templer
=======

Templer is yet another static site generator, written in Perl.


Concepts
--------

**TODO** :

* A site comprises of a number of pages and assets.
    * A page is a piece of your content which is processed.
    * An asset is something which is copied into the output directory with no changes amade to t.


Creating a new site
-------------------

Simply create a directory and copy the `templer.cfg.sample` into it.  Update
that file as per your tastes.

At the very least you'll wish to specify the input directory to process, and
an output directory to which output will be generated.  (If you prefer you
may make use of the "in-place" mode.)


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
