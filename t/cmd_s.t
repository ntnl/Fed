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

plan tests => 6;

use App::Fed;

system q{cp}, $Bin . q{/../t_data/text_A.txt}, q{/tmp/} . $PID . q{.txt};
is(
    App::Fed::main("s{[ \t]+}{ }g", q{/tmp/} . $PID . q{.txt}),
    0,
    'Remove extra spaces'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras laoreet dignissim
libero varius mollis. Suspendisse non leo a risus gravida tristique. Cras
consectetur est at nisl pulvinar a lobortis dolor mollis. Donec id facilisis
tellus. Class aptent taciti sociosqu ad litora torquent per conubia
nostra, per inceptos himenaeos.

Donec placerat tristique nisl eu ultricies. Pellentesque consequat pretium
tortor, non cursus tortor suscipit in.

Vivamus convallis interdum velit, rhoncus dapibus purus lobortis sit amet.
Donec bibendum nisi lacinia enim facilisis ut tristique ligula iaculis.



 This is an example.
 http://www.lipsum.com/
},
    q{Remove extra spaces - check},
);
system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};



system q{cp}, $Bin . q{/../t_data/text_B.txt}, q{/tmp/} . $PID . q{.txt};
is(
    App::Fed::main("s/foo bar baz/foo rab baz/g", q{/tmp/} . $PID . q{.txt}),
    0,
    'Replace "bar" with "rab", but only between "foo" and "baz"'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{foo rab baz
baz foo bar
bar baz foo

foo rab baz foo rab baz
baz foo rab baz foo bar
bar baz foo rab baz foo

foo rab baz bar foo
baz foo bar foo baz
bar baz foo baz bar
},
    q{Replace "bar" with "rab", but only between "foo" and "baz" - check},
);
system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};



system q{cp}, $Bin . q{/../t_data/html_A.html}, q{/tmp/} . $PID . q{.txt};
is(
    App::Fed::main(q{s[\<[^\<\>]+\>][]g}, q{s/[ \\t]+/ /g}, q{s/^ +//mg}, q{s/ +$//mg}, q{s/\n\n+/\n\n/g}, q{s/^\n+//}, q{s/\n+$//}, q{/tmp/} . $PID . q{.txt}),
    0,
    'Strip html'
);
is(
    read_file(q{/tmp/} . $PID . q{.txt}),
    q{This is HTML sample A

Lorem
Ipsum

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras laoreet dignissim libero varius mollis.
Suspendisse non leo a risus gravida tristique. Cras consectetur est at nisl pulvinar a lobortis dolor mollis.
Donec id facilisis tellus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
Donec placerat tristique nisl eu ultricies. Pellentesque consequat pretium tortor, non cursus tortor suscipit in.
Vivamus convallis interdum yelit, rhoncus dapibus purus lobortis sit amet.

Donec bibendum nisi lacinia enim facilisis ut tristique ligula iaculis. Cras faucibus tempus metus, eu vehicula enim egestas id.
Nunc sit amet tortor lorem, ut porttitor nulla. Integer egestas lobortis tortor, vel accumsan quam facilisis non.

Ut quis lectus lectus, in eleifend velit. Aenean et arcu a massa eleifend commodo vel vel elit.},
    q{Strip html - check},
);
system q{rm}, q{-f}, q{/tmp/} . $PID . q{.txt};

# vim: fdm=marker
