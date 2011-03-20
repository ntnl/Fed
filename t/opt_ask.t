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

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}



system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/yes.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/no.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/quit.txt};

system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/all1.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/all2.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/all3.txt};

close STDIN;
open STDIN, q{<}, $Bin . q{/../t_data/stdin_ynq.txt};

output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/yes.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - Y.'
);
output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/no.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - N.'
);
output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/quit.txt});
    },
    qr{Write changes\?},
    undef,
    'Ask - Q.'
);

is(
    read_file($Bin . q{/_tmp_}. $PID .q{/yes.txt}),
    qq{Hello universe!\n},
    q{Ask - Y - check},
);
is(
    read_file($Bin . q{/_tmp_}. $PID .q{/no.txt}),
    qq{Hello world!\n},
    q{Ask - N - check},
);
is(
    read_file($Bin . q{/_tmp_}. $PID .q{/quit.txt}),
    qq{Hello world!\n},
    q{Ask - Q - check},
);



close STDIN;
open STDIN, q{<}, $Bin . q{/../t_data/stdin_na.txt};

output_like(
    sub {
        App::Fed::main(q{--ask}, q{-p}, q{s/world/universe/}, $Bin . q{/_tmp_}. $PID .q{/all1.txt}, $Bin . q{/_tmp_}. $PID .q{/all2.txt}, $Bin . q{/_tmp_}. $PID .q{/all3.txt});
    },
    qr{Write changes\?}s,
    qr{'ask' overwrites 'pretend'}s,
    'Ask - N + A. (and it overwrites pretend too)'
);

is(
    read_file($Bin . q{/_tmp_}. $PID .q{/all1.txt}),
    qq{Hello world!\n},
    q{Ask - A 1 - check},
);
is(
    read_file($Bin . q{/_tmp_}. $PID .q{/all2.txt}),
    qq{Hello universe!\n},
    q{Ask - A 2 - check},
);
is(
    read_file($Bin . q{/_tmp_}. $PID .q{/all3.txt}),
    qq{Hello universe!\n},
    q{Ask - A 3 - check},
);

# vim: fdm=marker
