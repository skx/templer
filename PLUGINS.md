Plugins
--------

Templer allows itself to be extended via the addition of plugins.

The following formatting plugins are distributed as part of the project:

* `Templer::Plugin::Markdown`
    * Allows input files to be written in Markdown.
* `Templer::Plugin::Perl`
    * Allows dynamic Perl to be included in your input pages.
* `Templer::Plugin::Textile`
    * Allows input files to be written in Textile.

The following variable plugins are distributed as part of the project:

* `Templer::Plugin::Breadcrumbs`
    * Setup "breadcrumb" trails in your templates easily.
    * [Read the documentation](https://raw.github.com/skx/templer/master/lib/Templer/Plugin/Breadcrumbs.pm).
    * This was added partly as a demo, and partly for [use on my site](http://steve.org.uk/Software/templer/).
* `Templer::Plugin::FileContents`
    * Set variable values to the contents of files.
* `Templer::Plugin::FileGlob`
    * Set variable values to lists of files, based on a globbing pattern.
    * dirname, basename and file extension are made available.
    * If the glob matches images then heights and widths will be available to your HTML.
    * If the glob doesn't match images then the contents of the files will also be made available.
    * If the glob matches templer input files then templer input variables will be available to your HTML.
* `Templer::Plugin::ShellCommand`
    * Set variable values to the output of shell commands.
* `Templer::Plugin::RootPath`
    * Allow access to your site prefix, without hardcoding it.
* `Templer::Plugin::RSS`
    * Allow pages to include remote RSS feed data.
* `Templer::Plugin::Redis`
    * Allow variables to be retrieved from a Redis store running on the local system.
* `Templer::Plugin::Timestamp`
    * Allow pages to contain their own modification timestamp.

The following template filter plugins are distributed as part of the project:

* `Templer::Plugin::Dollar`
    * Allow template variables to be written using simple a shell-like syntax
* `Templer::Plugin::Strict`
    * Allow template tags to be written as empty-element tags conforming to XML syntax

If you wish you may contain write your own plugins, contained beneath your
templer-site.  The default [templer.cfg](templer.cfg.sample) documents the
`plugin-path` setting.


Plugin Types
------------

There are three types of plugins which are supported:

* Plugins which are used for formatting.
    * These convert your input files from Textile, Markdown, etc, into HTML.

* Plugins which present variables for use in your template(s).
    * Creating variables that refer to file contents, file globs, etc.
    
* Plugins which filter content of your template(s).
    * Simplify the way template can be written (escaping `HTML::Template` syntax which is too rigid for some text-editors facility, namely `nxml-mode` in Emacs for instance).

Although similar there is a different API for the three plugin-families.


### Formatter Plugins

The formatting plugins are intentionally simple because they are explicitly
enabled on a per-page basis. There is no need to dynamically try them all in
turn, executing whichever matches a particular condition, for example.

A standard input page-file might look like this:

    Title: My page title.
    Format: textile
    ----
    This is a textile page.  It has **bold** text!

When this page is rendered the Textile plugin is created and it is then called
like so:

    if ( $plugin->available() )
    {
        $html = $plugin->format(  $input );
    }

If the named formatter is not present, or does not report itself as "enabled"
then the markup will be returned without any expansion.  To be explicit
any formatter plugin must implement only the following two methods:

* `available`
    * To determine whether this plugin is available.
    * i.e. It might only be enabled if the modules it relies upon are present.
* `format`
    * Given some input text return the rendered content.
    * This method receives all the per-page and global variables.


### Filter Plugins

The template filter plugin is similar in use as the formatter one. The only
difference is at the level it operates. While a formatter plugin operates on
the content of the page, a filter one operates directly on the core template
engine allowing one to escape `HTML::Template` rigid syntax.

A standard input page-file might look like this:

    Title: My page title.
    template-filter: dollar
    ----
    This is a html page with a ${title}.

A standard template layout might look like this:

    <title>${title escape=html}</title>

When this page is rendered the Dollar plugin is created and is used to add a
filter to the `HTML::Template` object creation (through the `filter` property
of the `HTML::Template->new` method).

If the named filter is not present, or does not report itself as "enabled"
then the filter is just not used.  To be explicit any filter plugin must
implement only the following two methods:

* `available`
    * To determine whether this plugin is available.
    * i.e. It might only be enabled if the modules it relies upon are present.
* `filter`
    * Given some input text (read template) return the filtered template.


### Variable Expansion Plugins

For the variable-expansion plugins the approach is similar, but an arbitrary
number of plugins may be registered and each one is executed in turn - so
return values are chained.

Each site page is loaded and the variable names & values are stored in a hash.
Each plugin is free to modify that hash of known variables and their values.

Generally we expect that plugins will look for variable values having a
particular pattern and ignoring those that don't match.  But there is
certainly no reason why you couldn't write a plugin to convert each
variable-value to uppercase, or perform other global operations.

In pseudo-code the processing looks like this:

    $data = ( "foo" => "bar",
              title => "This is my page title .." );

    foreach my $plugin ( $plugins )
    {
         $data = $plugin->expand_variables( $page, $data );
    }

Each plugin will be called once, and once only, for each page.  The
`expand_variables` method is given a reference to the page from which the
variable(s) were loaded, which may be useful in some situations.

It should be noted for completeness that the same expansion happens on global
variables defined within your `templer.cfg` file.


Help?
-----

If you need help writing a plugin, or whish me to supply one for you and your
needs, please do get in touch.
