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
# }}}

# Debug:
use lib $Bin . q{/../lib};

plan tests => 2;

use App::Fed;



system q{cp}, $Bin . q{/../t_data/text_B.txt}, q{/tmp/} . $PID . q{.txt};
is(
    App::Fed::main("tr/fbao/FBec/", q{/tmp/} . $PID . q{.txt}),
    0,
    'Simple translate'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
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
system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};



# vim: fdm=marker
