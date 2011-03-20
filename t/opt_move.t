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

plan tests => 8;

use App::Fed;

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}


system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/moved_short.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/moved_long.txt};

my @stat_before_short = stat $Bin . q{/_tmp_}. $PID .q{/moved_short.txt};
my @stat_before_long  = stat $Bin . q{/_tmp_}. $PID .q{/moved_long.txt};


is (
    App::Fed::main(q{-m}, q{-P}, q{now_}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/moved_short.txt}),
    0,
    q{Move - short version}
);
is (
    App::Fed::main(q{--move}, q{-P}, q{now_}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/moved_long.txt}),
    0,
    q{Move - long version}
);


my @stat_after_short = stat $Bin . q{/_tmp_}. $PID .q{/now_moved_short.txt};
my @stat_after_long  = stat $Bin . q{/_tmp_}. $PID .q{/now_moved_long.txt};

is(
    $stat_before_short[1],
    $stat_after_short[1],
    q{Move - short version - check inode - new}
);

is(
    $stat_before_long[1],
    $stat_after_long[1],
    q{Move - long version - check inode - new}
);

is (
    scalar read_file($Bin . q{/_tmp_}. $PID .q{/now_moved_short.txt}),
    qq{Hello universe!\n},
    q{Move - short version - check content - new}
);
is (
    scalar read_file($Bin . q{/_tmp_}. $PID .q{/now_moved_long.txt}),
    qq{Hello universe!\n},
    q{Move - long version - check content - new}
);

is (
    scalar read_file($Bin . q{/_tmp_}. $PID .q{/moved_short.txt}),
    qq{Hello world!\n},
    q{Move - short version - check content - old}
);
is (
    scalar read_file($Bin . q{/_tmp_}. $PID .q{/moved_long.txt}),
    qq{Hello world!\n},
    q{Move - long version - check content - old}
);


# vim: fdm=marker
