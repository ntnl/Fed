package App::Fed::Cookbook;
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

my $VERSION = '0.01_90';

=encoding UTF-8

=head1 NAME

App::Fed::Cookbook - recipes for B<fed>.

=head1 RECIPES

=head2 Merge white spaces (spaces and tabs).

 fed 's/\s+/ /g' file

=head2 Change $VERSION in all modules of a package

 fed -r "s/VERSION\s*=\s*'0.01_50'/VERSION = '0.01_90'/" lib

=head1 SEE ALSO

L<fed>, L<App::Fed>

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

=cut

# vim: fdm=marker
1;
