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

plan tests => 2;

use App::Fed;

my ($t_fh, $t_path);



($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_B.txt}); close $t_fh;
is(
    App::Fed::main("tr/fbao/FBec/", $t_path),
    0,
    'Simple translate'
);
is(
    read_file($t_path),
    q{Fcc Ber Bez
Bez Fcc Ber
Ber Bez Fcc

Fcc Ber Bez Fcc Ber Bez
Bez Fcc Ber Bez Fcc Ber
Ber Bez Fcc Ber Bez Fcc

Fcc Ber Bez Ber Fcc
Bez Fcc Ber Fcc Bez
Ber Bez Fcc Bez Ber
},
    q{Simple translate - check},
);



# vim: fdm=marker
