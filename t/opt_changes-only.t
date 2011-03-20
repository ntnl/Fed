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

plan tests => 4;

use App::Fed;

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}



system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/yes.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin . q{/_tmp_}. $PID .q{/no.txt};

is(
    App::Fed::main(q{-c}, q{-P}, q{new-}, q{r/ world/}, $Bin . q{/_tmp_}. $PID .q{/yes.txt}),
    0,
    'Changes-only - matched.'
);
is(
    scalar ( -f $Bin . q{/_tmp_}. $PID .q{/new-yes.txt} ),
    1,
    'Changes-only - matched - check.'
);



is(
    App::Fed::main(q{-c}, q{-P}, q{new-}, q{r/ universe/}, $Bin . q{/_tmp_}. $PID .q{/no.txt}),
    0,
    'Changes-only - missed.'
);
is(
    scalar ( -f $Bin . q{/_tmp_}. $PID .q{/new-no.txt} ),
    undef,
    'Changes-only - missed - check.'
);

# vim: fdm=marker
