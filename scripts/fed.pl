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

use warnings; use strict;

my $VERSION = '0.01_50';

use FindBin qw( $Bin );
use lib $Bin .q{/../lib/};

use App::Fed;

exit App::Fed::main(@ARGV);

# vim: fdm=marker
