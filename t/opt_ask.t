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

plan tests => 6 + 4;

use App::Fed;



system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/yes-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/no-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/quit-} . $PID . q{.txt};

system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/all1-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/all2-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/all3-} . $PID . q{.txt};

close STDIN;
open STDIN, q{<}, $Bin . q{/../t_data/stdin_ynq.txt};

output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, q{/tmp/yes-} . $PID . q{.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - Y.'
);
output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, q{/tmp/no-} . $PID . q{.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - N.'
);
output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, q{/tmp/quit-} . $PID . q{.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - Q.'
);

is(
    read_file(q{/tmp/yes-} . $PID . q{.txt}),
    qq{Hello universe!\n},
    q{Ask - Y - check},
);
is(
    read_file(q{/tmp/no-} . $PID . q{.txt}),
    qq{Hello world!\n},
    q{Ask - N - check},
);
is(
    read_file(q{/tmp/quit-} . $PID . q{.txt}),
    qq{Hello world!\n},
    q{Ask - Q - check},
);



close STDIN;
open STDIN, q{<}, $Bin . q{/../t_data/stdin_na.txt};

output_like(
    sub {
        App::Fed::main(q{--ask}, q{s/world/universe/}, q{/tmp/all1-} . $PID . q{.txt}, q{/tmp/all2-} . $PID . q{.txt}, q{/tmp/all3-} . $PID . q{.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - N + A.'
);

is(
    read_file(q{/tmp/all1-} . $PID . q{.txt}),
    qq{Hello world!\n},
    q{Ask - A 1 - check},
);
is(
    read_file(q{/tmp/all2-} . $PID . q{.txt}),
    qq{Hello universe!\n},
    q{Ask - A 2 - check},
);
is(
    read_file(q{/tmp/all3-} . $PID . q{.txt}),
    qq{Hello universe!\n},
    q{Ask - A 3 - check},
);

# vim: fdm=marker
