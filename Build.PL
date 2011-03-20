#!/usr/bin/perl

use strict; use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'App::Fed',
    license     => 'perl',

    create_readme  => 1,
    create_license => 1,

    configure_requires => {
        'Module::Build' => q{0.34},
        'Test::Output'  => q{0.16},
    },
    requires => {
        'perl' => '5.10.0',

        'Carp::Assert::More' => q{1.10},
        'File::Slurp'        => q{9999.13},
        'Getopt::Long'       => q{2.36},
    },

    recursive_test_files => 1,
);
$build->create_build_script();

# vim: fdm=marker
