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

plan tests => 3;

use App::Fed;

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}



system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_} . $PID . q{/test.txt};
is(
    App::Fed::main(q{-P}, q{new-}, q{s/world/universe/}, $Bin . q{/_tmp_} . $PID . q{/test.txt}),
    0,
    'Save to file with prefix added to the name.'
);
is(
    read_file($Bin . q{/_tmp_} . $PID . q{/test.txt}),
    qq{Hello world!\n},
    q{Prefix - check original},
);
is(
    read_file($Bin . q{/_tmp_} . $PID . q{/new-test.txt}),
    qq{Hello universe!\n},
    q{Prefix - check result},
);

# vim: fdm=marker
