#!/usr/bin/fake
#
# This is some sample source code.

use Foo;
use Foo::Bar qw(
    foo_one
    foo_two
);

sub initialize {
    foo_one(
        a => 'A',
    );
    foo_one(
        b => 'B',
    );
    foo_one(
        a => 'A',
        B => 'B',
    );

    return;
}

sub complete { # {{{
    my ( $text ) = @_;

    return foo_two($text);
} # }}}

sub main
{

    initialize();

    complete();

    return 0;
}

exit main();

