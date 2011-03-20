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

plan tests =>
    + 1 # short version
    + 1 # long version
;

use App::Fed;

mkdir $Bin .q{/_tmp_} . $PID;

mkdir $Bin .q{/_tmp_} . $PID . q{/V};
mkdir $Bin .q{/_tmp_} . $PID . q{/V/v};

system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin .q{/_tmp_} . $PID . q{/V/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, $Bin .q{/_tmp_} . $PID . q{/V/v/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_B.txt}, $Bin .q{/_tmp_} . $PID . q{/V/elpmas.txt};



my $expected_output = qq{Reading $Bin/_tmp_$PID/V
Reading $Bin/_tmp_$PID/V/v
File 1 of 3 (33%)
$Bin/_tmp_$PID/V/elpmas.txt :
  No changes.

File 2 of 3 (66%)
$Bin/_tmp_$PID/V/sample.txt :
  Target: $Bin/_tmp_$PID/V/x-sample.txt
  Updated.

File 3 of 3 (100%)
$Bin/_tmp_$PID/V/v/sample.txt :
  Target: $Bin/_tmp_$PID/V/v/x-sample.txt
  Updated.

Done.
};

stdout_is (
    sub {
        App::Fed::main(q{-v}, q{-r}, q{-P}, q{x-}, q{-c}, q{s/world/galaxy/}, $Bin .q{/_tmp_} . $PID . q{/V});
    },
    $expected_output,
    q{Verbose - short version}
);

unlink $Bin .q{/_tmp_} . $PID . q{/V/x-sample.txt};
unlink $Bin .q{/_tmp_} . $PID . q{/V/v/x-sample.txt};

stdout_is (
    sub {
        App::Fed::main(q{--verbose}, q{-r}, q{-P}, q{x-}, q{-c}, q{s/world/known space/}, $Bin .q{/_tmp_} . $PID . q{/V});
    },
    $expected_output,
    q{Verbose - long version}
);

# vim: fdm=marker
