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



system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/yes-} . $PID . q{.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/no-} . $PID . q{.txt};

is(
    App::Fed::main(q{-c}, q{-P}, q{new-}, q{r/ world/}, q{/tmp/yes-} . $PID . q{.txt}),
    0,
    'Changes-only - matched.'
);
is(
    scalar ( -f q{/tmp/new-yes-} . $PID . q{.txt} ),
    1,
    'Changes-only - matched - check.'
);



is(
    App::Fed::main(q{-c}, q{-P}, q{new-}, q{r/ universe/}, q{/tmp/no-} . $PID . q{.txt}),
    0,
    'Changes-only - missed.'
);
is(
    scalar ( -f q{/tmp/new-no-} . $PID . q{.txt} ),
    undef,
    'Changes-only - missed - check.'
);

# vim: fdm=marker
