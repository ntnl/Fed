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
use File::Slurp qw( read_file write_file );
use File::Temp qw( tempdir );
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

my ($t_fh, $t_path);


my $t_dir = tempdir( CLEANUP => 1 );

mkdir $t_dir . q{/A};

mkdir $t_dir . q{/B};
mkdir $t_dir . q{/B/b};

mkdir $t_dir . q{/C};
mkdir $t_dir . q{/C/c};
mkdir $t_dir . q{/C/c/tse};



write_file($t_dir . q{/A/sample.txt}, read_file($Bin . q{/../t_data/text_H.txt}));

write_file($t_dir . q{/B/sample.txt},   read_file($Bin . q{/../t_data/text_H.txt}));
write_file($t_dir . q{/B/b/sample.txt}, read_file($Bin . q{/../t_data/text_H.txt}));

write_file($t_dir . q{/C/sample.txt},       read_file($Bin . q{/../t_data/text_H.txt}));
write_file($t_dir . q{/C/c/sample.txt},     read_file($Bin . q{/../t_data/text_H.txt}));
write_file($t_dir . q{/C/c/tse/sample.txt}, read_file($Bin . q{/../t_data/text_H.txt}));



is (
    App::Fed::main(q{-r}, q{s/world/universe/}, $t_dir . q{/}),
    0,
    q{Recursive - short version}
);


is (
    scalar read_file($t_dir . q{/A/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (1/6)}
);

is (
    scalar read_file($t_dir . q{/B/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (2/6)}
);
is (
    scalar read_file($t_dir . q{/B/b/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (3/6)}
);

is (
    scalar read_file($t_dir . q{/C/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (4/6)}
);
is (
    scalar read_file($t_dir . q{/C/c/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (5/6)}
);
is (
    scalar read_file($t_dir . q{/C/c/tse/sample.txt}),
    qq{Hello universe!\n},
    q{Recursive - short version - check (6/6)}
);



is (
    App::Fed::main(q{-R}, q{s/universe/known space/}, $t_dir . q{/B}),
    0,
    q{Recursive - short R}
);


is (
    scalar read_file($t_dir . q{/B/sample.txt}),
    qq{Hello known space!\n},
    q{Recursive - short R - check (1/2)}
);

is (
    scalar read_file($t_dir . q{/B/sample.txt}),
    qq{Hello known space!\n},
    q{Recursive - short R - check (2/2)}
);



is (
    App::Fed::main(q{--recursive}, q{s/universe/galaxy/}, $t_dir . q{/C}),
    0,
    q{Recursive - long version}
);


is (
    scalar read_file($t_dir . q{/C/sample.txt}),
    qq{Hello galaxy!\n},
    q{Recursive - long version - check (1/3)}
);

is (
    scalar read_file($t_dir . q{/C/c/sample.txt}),
    qq{Hello galaxy!\n},
    q{Recursive - long version - check (2/3)}
);

is (
    scalar read_file($t_dir . q{/C/c/tse/sample.txt}),
    qq{Hello galaxy!\n},
    q{Recursive - long version - check (3/3)}
);

# vim: fdm=marker
