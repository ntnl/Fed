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

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}


system q{cp}, $Bin . q{/../t_data/text_B.txt}, $Bin . q{/_tmp_} . $PID . q{/test.txt};
is(
    App::Fed::main("m/foo ...\\s/is", $Bin .q{/_tmp_} . $PID . q{/test.txt}),
    0,
    'Simple match'
);
is(
    read_file($Bin . q{/_tmp_} . $PID . q{/test.txt}),
    q{foo bar },
    q{Simple match - check},
);
system q{rm}, q{-f}, $Bin . q{/_tmp_} . $PID . q{/test_.txt};



system q{cp}, $Bin . q{/../t_data/text_B.txt}, $Bin . q{/_tmp_} . $PID . q{/test.txt};
is(
    App::Fed::main("m/foo ...\\s/igs", $Bin . q{/_tmp_} . $PID . q{/test.txt}),
    0,
    'Simple match'
);
is(
    read_file($Bin . q{/_tmp_} . $PID . q{/test.txt}),
    q{foo bar foo bar
foo bar foo bar foo bar foo bar
foo bar foo bar foo bar foo baz
foo baz },
    q{Simple match - check},
);

is(
    App::Fed::main("m/zxcvghjkop/igs", $Bin . q{/_tmp_} . $PID . q{/test.txt}),
    0,
    'No-match test'
);
is(
    read_file($Bin . q{/_tmp_} . $PID . q{/test.txt}),
    q{foo bar foo bar
foo bar foo bar foo bar foo bar
foo bar foo bar foo bar foo baz
foo baz },
    q{No-match test - check},
);

system q{rm}, q{-f}, $Bin . q{/_tmp_} . $PID . q{/test.txt};



# vim: fdm=marker
