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

plan tests => 3;

use App::Fed;



output_like(
    sub {
        App::Fed::main(),
    },
    qr{Usage},
    undef,
    q{No options - trigger help}
);
output_like(
    sub {
        App::Fed::main(q{-h}),
    },
    qr{Usage},
    undef,
    q{Short version}
);
output_like(
    sub {
        App::Fed::main(q{--help}),
    },
    qr{Usage},
    undef,
    q{Long version}
);


# vim: fdm=marker
