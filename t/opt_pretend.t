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

plan tests =>
    + 2 # Would have updated...
    + 2 # Would be skipped...
;

use App::Fed;

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}



system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/hello.txt};



stdout_like(
    sub {
        App::Fed::main(q{-p}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/hello.txt});
    },
    qr{Would be updated},
    'Pretend - updated'
);

is(
    read_file($Bin . q{/_tmp_}. $PID .q{/hello.txt}),
    qq{Hello world!\n},
    q{Pretend - updated - check},
);

stdout_like(
    sub {
        App::Fed::main(q{-p}, q{s/galaxy/universe/}, $Bin . q{/_tmp_}. $PID .q{/hello.txt});
    },
    qr{Would be skipped},
    'Pretend - skipped'
);

is(
    read_file($Bin . q{/_tmp_}. $PID .q{/hello.txt}),
    qq{Hello world!\n},
    q{Pretend - skipped - check},
);

# vim: fdm=marker
