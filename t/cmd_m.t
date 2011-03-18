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
# }}}

# Debug:
use lib $Bin . q{/../lib};

plan tests =>
    + 4 # Normal tests
    + 2 # No-match test.
;

use App::Fed;



system q{cp}, $Bin . q{/../t_data/text_B.txt}, q{/tmp/} . $PID . q{.txt};
is(
    App::Fed::main("m/foo ...\\s/is", q{/tmp/} . $PID . q{.txt}),
    0,
    'Simple match'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{foo bar },
    q{Simple match - check},
);
system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};



system q{cp}, $Bin . q{/../t_data/text_B.txt}, q{/tmp/} . $PID . q{.txt};
is(
    App::Fed::main("m/foo ...\\s/igs", q{/tmp/} . $PID . q{.txt}),
    0,
    'Simple match'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{foo bar foo bar
foo bar foo bar foo bar foo bar
foo bar foo bar foo bar foo baz
foo baz },
    q{Simple match - check},
);

is(
    App::Fed::main("m/zxcvghjkop/igs", q{/tmp/} . $PID . q{.txt}),
    0,
    'No-match test'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{foo bar foo bar
foo bar foo bar foo bar foo bar
foo bar foo bar foo bar foo baz
foo baz },
    q{No-match test - check},
);

system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};



# vim: fdm=marker
