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

plan tests => 3;

use App::Fed;

my ($t_fh, $t_path, $t_new_path);

($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;

$t_new_path = $t_path;
$t_new_path =~ s{/([^/]+)$}{/new-$1}; # FIXME: This is SO lame, but I'm not aiming at supporting Windows at the moment (this will change, hence this note exists)

is(
    App::Fed::main(q{-P}, q{new-}, q{s/world/universe/}, $t_path),
    0,
    'Save to file with prefix added to the name.'
);
is(
    read_file($t_path),
    qq{Hello world!\n},
    q{Prefix - check original},
);
is(
    read_file($t_new_path),
    qq{Hello universe!\n},
    q{Prefix - check result},
);

# vim: fdm=marker
