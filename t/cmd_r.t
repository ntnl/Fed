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
    App::Fed::main("r/foo ... baz/g", q{/tmp/} . $PID . q{.txt}),
    0,
    'Simple remove'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{
baz foo bar
bar baz foo

 
baz  foo bar
bar baz  foo

 bar foo
baz foo bar foo baz
bar baz foo baz bar
},
    q{Simple remove - check},
);
system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};




# vim: fdm=marker
