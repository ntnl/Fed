#!/usr/bin/perl

use FindBin qw( $Bin );
use lib $Bin .q{/../lib/};

use App::Fed;

App::Fed::main(@ARGV);

