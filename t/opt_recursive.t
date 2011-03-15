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
    + 1 + 6 # Short (-r) version
    + 1 + 2 # Short (-R) version;
    + 1 + 3 # Long version;
;

use App::Fed;

mkdir q{/tmp/} . $PID;

mkdir q{/tmp/} . $PID . q{/A};

mkdir q{/tmp/} . $PID . q{/B};
mkdir q{/tmp/} . $PID . q{/B/b};

mkdir q{/tmp/} . $PID . q{/C};
mkdir q{/tmp/} . $PID . q{/C/c};
mkdir q{/tmp/} . $PID . q{/C/c/tse};



system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/A/sample.txt};

system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/B/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/B/b/sample.txt};

system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/C/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/C/c/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/C/c/tse/sample.txt};



is (
    App::Fed::main(q{-r}, q{s/world/universe/}, q{/tmp/} . $PID . q{/}),
    0,
    q{Recursive - short version}
);


is (
    scalar read_file(q{/tmp/} . $PID . q{/A/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (1/6)}
);

is (
    scalar read_file(q{/tmp/} . $PID . q{/B/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (2/6)}
);
is (
    scalar read_file(q{/tmp/} . $PID . q{/B/b/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (3/6)}
);

is (
    scalar read_file(q{/tmp/} . $PID . q{/C/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (4/6)}
);
is (
    scalar read_file(q{/tmp/} . $PID . q{/C/c/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (5/6)}
);
is (
    scalar read_file(q{/tmp/} . $PID . q{/C/c/tse/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (6/6)}
);



is (
    App::Fed::main(q{-R}, q{s/universe/known space/}, q{/tmp/} . $PID . q{/B}),
    0,
    q{Recursive - short R}
);


is (
    scalar read_file(q{/tmp/} . $PID . q{/B/sample.txt}),
    qq{Hello known space!\n},
    q{Recursive - short R - check (1/2)}
);

is (
    scalar read_file(q{/tmp/} . $PID . q{/B/sample.txt}),
    qq{Hello known space!\n},
    q{Recursive - short R - check (2/2)}
);



is (
    App::Fed::main(q{--recursive}, q{s/universe/galaxy/}, q{/tmp/} . $PID . q{/C}),
    0,
    q{Recursive - long version}
);


is (
    scalar read_file(q{/tmp/} . $PID . q{/C/sample.txt}),
    qq{Hello galaxy!\n},
    q{Recursive - long version - check (1/3)}
);

is (
    scalar read_file(q{/tmp/} . $PID . q{/C/c/sample.txt}),
    qq{Hello galaxy!\n},
    q{Recursive - long version - check (2/3)}
);

is (
    scalar read_file(q{/tmp/} . $PID . q{/C/c/tse/sample.txt}),
    qq{Hello galaxy!\n},
    q{Recursive - long version - check (3/3)}
);

# vim: fdm=marker
