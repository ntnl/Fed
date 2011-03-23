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
# }}}

# Debug:
use lib $Bin . q{/../lib};

plan tests =>
    + 4 # Normal tests
    + 2 # No-match test.
;

use App::Fed;

my ($t_fh, $t_path);


($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_B.txt}); close $t_fh;
is(
    App::Fed::main("m/foo ...\\s/is", $t_path),
    0,
    'Simple match'
);
is(
    read_file($t_path),
    q{foo bar },
    q{Simple match - check},
);



($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_B.txt}); close $t_fh;
is(
    App::Fed::main("m/foo ...\\s/igs", $t_path),
    0,
    'Simple match'
);
is(
    read_file($t_path),
    q{foo bar foo bar
foo bar foo bar foo bar foo bar
foo bar foo bar foo bar foo baz
foo baz },
    q{Simple match - check},
);

is(
    App::Fed::main("m/zxcvghjkop/igs", $t_path),
    0,
    'No-match test'
);
is(
    read_file($t_path),
    q{foo bar foo bar
foo bar foo bar foo bar foo bar
foo bar foo bar foo bar foo baz
foo baz },
    q{No-match test - check},
);



# vim: fdm=marker
