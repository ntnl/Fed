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

plan tests => 4;

use App::Fed;

my ($t_fh, $t_path, $t_new_path);


($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;

$t_new_path = $t_path;
$t_new_path =~ s{/([^/]+)$}{/new-$1}; # FIXME: This is SO lame, but I'm not aiming at supporting Windows at the moment (this will change, hence this note exists)

is(
    App::Fed::main(q{-c}, q{-P}, q{new-}, q{r/ world/}, $t_path),
    0,
    'Changes-only - matched.'
);
is(
    scalar ( -f $t_new_path ),
    1,
    'Changes-only - matched - check.'
);



($t_fh, $t_path) = tempfile();
print $t_fh read_file($Bin . q{/../t_data/text_H.txt}); close $t_fh;

$t_new_path = $t_path;
$t_new_path =~ s{/([^/]+)$}{/new-$1}; # FIXME: This is SO lame, but I'm not aiming at supporting Windows at the moment (this will change, hence this note exists)

is(
    App::Fed::main(q{-c}, q{-P}, q{new-}, q{r/ universe/}, $t_path),
    0,
    'Changes-only - missed.'
);
is(
    scalar ( -f $t_new_path ),
    undef,
    'Changes-only - missed - check.'
);

# vim: fdm=marker
