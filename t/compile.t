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

use Test::More;
# }}}

# Debug:
use FindBin qw( $Bin );
use lib $Bin . q{/../lib};

plan tests => 2;

use_ok('App::Fed');
use_ok('App::Fed::Cookbook');

# vim: fdm=marker
