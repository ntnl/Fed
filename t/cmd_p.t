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

mkdir $Bin .q{/_tmp_}. $PID;
END {
    system q{rm}, q{-Rf}, $Bin .q{/_tmp_}. $PID;
}



system q{cp}, $Bin . q{/../t_data/text_B.txt}, $Bin . q{/_tmp_} . $PID . q{/test.txt};
is(
    App::Fed::main("p/^foo.+?foo\$/sort/gsim", $Bin . q{/_tmp_} . $PID . q{/test.txt}),
    0,
    'Sort using pipe'
);
is(
    read_file($Bin . q{/_tmp_} . $PID . q{/test.txt}),
    q{bar baz foo
baz foo bar
foo bar baz


bar baz foo bar baz foo
baz foo bar baz foo bar
foo bar baz foo bar baz


foo bar baz bar foo

baz foo bar foo baz
bar baz foo baz bar
},
    q{Sort using pipe - check},
);
system q{rm}, q{-f}, $Bin . q{/_tmp_} . $PID . q{/test.txt};



# vim: fdm=marker
