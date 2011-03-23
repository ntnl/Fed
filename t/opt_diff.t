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

plan tests => 2;

use App::Fed;

my ($t_fh, $t_path);


($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;


output_is(
    sub {
        App::Fed::main(q{-d}, q{s/world/universe/}, $t_path);
    },
    $t_path . q{ :

  Diff:
    1c1
    < Hello world!
    ---
    > Hello universe!

},
    undef,
    'Diff - with changes'
);

($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;

stdout_is(
    sub {
        App::Fed::main(q{-d}, q{s/universe/world/}, $t_path);
    },
    $t_path . q{ :

  Diff:
    (no changes)

},
    'Diff - without changes'
);

# vim: fdm=marker
