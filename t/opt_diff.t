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

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}


system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/yes.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/no.txt};


output_is(
    sub {
        App::Fed::main(q{-d}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/yes.txt});
    },
    $Bin . q{/_tmp_}. $PID .q{/yes.txt :

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
        App::Fed::main(q{-d}, q{s/universe/world/}, $Bin . q{/_tmp_}. $PID .q{/no.txt});
    },
    $Bin . q{/_tmp_}. $PID .q{/no.txt :

  Diff:
    (no changes)

},
    'Diff - without changes'
);

# vim: fdm=marker
