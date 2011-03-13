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

plan tests => 2;

use App::Fed;



output_like(
    sub {
        App::Fed::main(q{-V}),
    },
    qr{File EDitor.+?$},
    undef,
    q{Short version}
);
output_like(
    sub {
        App::Fed::main(q{--version}),
    },
    qr{File EDitor.+?$},
    undef,
    q{Long version}
);


# vim: fdm=marker
