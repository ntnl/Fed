#!/usr/bin/perl
################################################################################
# 
# fed - File editor.
#
# Copyright (C) 2011 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
################################################################################
use strict; use warnings; # {{{

use FindBin qw( $Bin );

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Test::More;
use Test::Output;
# }}}

# Debug:
use lib $Bin . q{/../lib};

plan tests => 2;

use App::Fed;


system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/yes-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/no-} . $PID . q{.txt};


output_is(
    sub {
        App::Fed::main(q{-d}, q{s/world/universe/}, q{/tmp/yes-} . $PID . q{.txt});
    },
    q{/tmp/yes-} . $PID . q{.txt :

  Diff:
    1c1
    < Hello world!
    ---
    > Hello universe!

},
    undef,
    'Diff - with changes'
);

stdout_is(
    sub {
        App::Fed::main(q{-d}, q{s/universe/world/}, q{/tmp/no-} . $PID . q{.txt});
    },
    q{/tmp/no-} . $PID . q{.txt :

  Diff:
    (no changes)

},
    'Diff - without changes'
);

# vim: fdm=marker
