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

mkdir q{/tmp/} . $PID;

mkdir q{/tmp/} . $PID . q{/V};
mkdir q{/tmp/} . $PID . q{/V/v};

system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/V/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_H.txt}, q{/tmp/} . $PID . q{/V/v/sample.txt};
system q{cp}, $Bin . q{/../t_data/text_B.txt}, q{/tmp/} . $PID . q{/V/elpmas.txt};



my $expected_output = qq{Reading /tmp/$PID/V
Reading /tmp/$PID/V/v
File 1 of 3 (33%)
/tmp/$PID/V/elpmas.txt :
  No changes.

File 2 of 3 (66%)
/tmp/$PID/V/sample.txt :
  Target: /tmp/$PID/V/x-sample.txt
  Updated.

File 3 of 3 (100%)
/tmp/$PID/V/v/sample.txt :
  Target: /tmp/$PID/V/v/x-sample.txt
  Updated.

Done.
};

stdout_is (
    sub {
        App::Fed::main(q{-v}, q{-r}, q{-P}, q{x-}, q{-c}, q{s/world/galaxy/}, q{/tmp/} . $PID . q{/V});
    },
    $expected_output,
    q{Verbose - short version}
);

unlink q{/tmp/} . $PID . q{/V/x-sample.txt};
unlink q{/tmp/} . $PID . q{/V/v/x-sample.txt};

stdout_is (
    sub {
        App::Fed::main(q{--verbose}, q{-r}, q{-P}, q{x-}, q{-c}, q{s/world/known space/}, q{/tmp/} . $PID . q{/V});
    },
    $expected_output,
    q{Verbose - long version}
);

# vim: fdm=marker
