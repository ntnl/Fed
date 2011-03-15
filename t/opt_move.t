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


system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/moved_short-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/moved_long-} . $PID . q{.txt};

my @stat_before_short = stat q{/tmp/moved_short-} . $PID . q{.txt};
my @stat_before_long  = stat q{/tmp/moved_long-}  . $PID . q{.txt};


is (
    App::Fed::main(q{-m}, q{-P}, q{now_}, q{s/world/universe/}, q{/tmp/moved_short-} . $PID . q{.txt}),
    0,
    q{Move - short version}
);
is (
    App::Fed::main(q{--move}, q{-P}, q{now_}, q{s/world/universe/}, q{/tmp/moved_long-} . $PID . q{.txt}),
    0,
    q{Move - long version}
);


my @stat_after_short = stat q{/tmp/now_moved_short-} . $PID . q{.txt};
my @stat_after_long  = stat q{/tmp/now_moved_long-}  . $PID . q{.txt};

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
    scalar read_file(q{/tmp/now_moved_short-} . $PID . q{.txt}),
    qq{Hello universe!\n},
    q{Move - short version - check content - new}
);
is (
    scalar read_file(q{/tmp/now_moved_long-} . $PID . q{.txt}),
    qq{Hello universe!\n},
    q{Move - long version - check content - new}
);

is (
    scalar read_file(q{/tmp/moved_short-} . $PID . q{.txt}),
    qq{Hello world!\n},
    q{Move - short version - check content - old}
);
is (
    scalar read_file(q{/tmp/moved_long-} . $PID . q{.txt}),
    qq{Hello world!\n},
    q{Move - long version - check content - old}
);


# vim: fdm=marker
