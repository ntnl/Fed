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
    App::Fed::main("p/^foo.+?foo\$/sort/gsim", $t_path),
    0,
    'Sort using pipe'
);
is(
    read_file($t_path),
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



# vim: fdm=marker
