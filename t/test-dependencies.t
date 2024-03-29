#!/usr/bin/perl -w -I..
#
#  Test that all the Perl modules we require are available.
#
#  This list is automatically generated by modules.sh
#
# Steve
# --
#

use strict;
use warnings;


use Test::More qw( no_plan );



BEGIN {use_ok('Cwd');}
require_ok('Cwd');

BEGIN {use_ok('File::Find');}
require_ok('File::Find');

BEGIN {use_ok('File::Path');}
require_ok('File::Path');

BEGIN {use_ok('Getopt::Long');}
require_ok('Getopt::Long');

BEGIN {use_ok('HTML::Template');}
require_ok('HTML::Template');

BEGIN {use_ok('Pod::Find');}
require_ok('Pod::Find');

BEGIN {use_ok('Pod::Usage');}
require_ok('Pod::Usage');

BEGIN {use_ok('Test::More');}
require_ok('Test::More');

BEGIN {use_ok('Test::Exception');}
require_ok('Test::Exception');

BEGIN {use_ok('strict');}
require_ok('strict');

BEGIN {use_ok('warnings');}
require_ok('warnings');
