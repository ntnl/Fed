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
use File::Temp qw( tempfile );
use Test::More;
use Test::Output;
# }}}

# Debug:
use lib $Bin . q{/../lib};

plan tests => 6 + 4;

use App::Fed;

my ($t_fh, $t_path);



my ($t_fh_1, $t_path_1) = tempfile();
print $t_fh_1 read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh_1;
my ($t_fh_2, $t_path_2) = tempfile();
print $t_fh_2 read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh_2;
my ($t_fh_3, $t_path_3) = tempfile();
print $t_fh_3 read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh_3;

close STDIN;
open STDIN, q{<}, $Bin . q{/../t_data/stdin_ynq.txt};

output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, $t_path_1);
    },
    qr{Write changes\?},
    undef,
    'Ask - Y.'
);
output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, $t_path_2);
    },
    qr{Write changes\?},
    undef,
    'Ask - N.'
);
output_like(
    sub {
        App::Fed::main(q{-a}, q{s/world/universe/}, $t_path_3);
    },
    qr{Write changes\?},
    undef,
    'Ask - Q.'
);

is(
    read_file($t_path_1),
    qq{Hello universe!\n},
    q{Ask - Y - check},
);
is(
    read_file($t_path_2),
    qq{Hello world!\n},
    q{Ask - N - check},
);
is(
    read_file($t_path_3),
    qq{Hello world!\n},
    q{Ask - Q - check},
);



my ($t_fh_4, $t_path_4) = tempfile();
print $t_fh_4 read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh_4;
my ($t_fh_5, $t_path_5) = tempfile();
print $t_fh_5 read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh_5;
my ($t_fh_6, $t_path_6) = tempfile();
print $t_fh_6 read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh_6;

close STDIN;
open STDIN, q{<}, $Bin . q{/../t_data/stdin_na.txt};

output_like(
    sub {
        App::Fed::main(q{--ask}, q{-p}, q{s/world/universe/}, $t_path_4, $t_path_5, $t_path_6);
    },
    qr{Write changes\?}s,
    qr{'ask' overwrites 'pretend'}s,
    'Ask - N + A. (and it overwrites pretend too)'
);

is(
    read_file($t_path_4),
    qq{Hello world!\n},
    q{Ask - A 1 - check},
);
is(
    read_file($t_path_5),
    qq{Hello universe!\n},
    q{Ask - A 2 - check},
);
is(
    read_file($t_path_6),
    qq{Hello universe!\n},
    q{Ask - A 3 - check},
);

# vim: fdm=marker
