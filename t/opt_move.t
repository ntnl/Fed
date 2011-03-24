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
use Test::Output;
# }}}

# Debug:
use lib $Bin . q{/../lib};

plan tests => 
    + 4
    + 4
;

use App::Fed;

my ($t_fh, $t_path, $t_new_path);


($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;

$t_new_path = $t_path;
$t_new_path =~ s{/([^/]+)$}{/new_$1}; # FIXME: This is SO lame, but I'm not aiming at supporting Windows at the moment (this will change, hence this note exists)

my @stat_before_short = stat $t_path;
is (
    App::Fed::main(q{-m}, q{-P}, q{new_}, q{s/world/universe/}, $t_path),
    0,
    q{Move - short version}
);
my @stat_after_short = stat $t_new_path;

is(
    $stat_before_short[1],
    $stat_after_short[1],
    q{Move - short version - check inode - new}
);

is (
    scalar read_file($t_new_path),
    qq{Hello universe!\n},
    q{Move - short version - check content - new}
);

is (
    scalar read_file($t_path),
    qq{Hello world!\n},
    q{Move - short version - check content - old}
);



($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;

$t_new_path = $t_path;
$t_new_path =~ s{/([^/]+)$}{/new_$1}; # FIXME: This is SO lame, but I'm not aiming at supporting Windows at the moment (this will change, hence this note exists)

my @stat_before_long  = stat $t_path;
is (
    App::Fed::main(q{--move}, q{-P}, q{new_}, q{s/world/universe/}, $t_path),
    0,
    q{Move - long version}
);
my @stat_after_long  = stat $t_new_path;

is(
    $stat_before_long[1],
    $stat_after_long[1],
    q{Move - long version - check inode - new}
);
is (
    scalar read_file($t_new_path),
    qq{Hello universe!\n},
    q{Move - long version - check content - new}
);
is (
    scalar read_file($t_path),
    qq{Hello world!\n},
    q{Move - long version - check content - old}
);

# vim: fdm=marker
