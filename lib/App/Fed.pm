package App::Fed;
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
use warnings; use strict; # {{{

my $VERSION = '0.01_alpha';

use English qw( -no_match_vars );
use Getopt::Long 2.36 qw( GetOptionsFromArray );
# }}}

=head1 NAME

fed - file editor for filtering and transforming text, file-wide.

=head1 SYNOPSIS

 fed [OPTION]... [COMMAND]... [input-file]...
 
 # Replace anything between 'foo' and 'bar' with space, one time.
 fed 's/foo.+?baz/ /' text_*.txt
 
 # Strip comments from config files:
 fed 'x/\s*#.+?$/m' *.conf
 
 # Remove HTML links.
 fed -i -c 's{<a.+?>(.+?)<\\\/a>}{$1}sg' page*.html

=head1 DESCRIPTION

Fed is a replace/filter utility, working on per-line or per-file basis, across multiple files,
even going recursively into directories.

It aims to provide easy access to some functionality of I<sed>, I<awk> and I<Perl>.

By default it will replace files in-place, so you do not have to pipe/move anything.

You can control the edit process either by having changed files written under different name,
or by inspecting changes (with F<diff>) and accepting them manually.

=head1 COMMANDS

Following commands are supported:
B<s> (substitute),
B<tr> (transcode),
B<p> (pipe),
B<r> (remove),
and B<m> (match).
Following separators are supported: B<//>, B<{}>, B<[]>, B<()>.

Many commands can be provided in a row, they will all be applied one after another, each working on the output from previous one.

Please see App::Fed::Cookbook for how those can be applied to real-life situations.

=head2 s/PATTERN/EXPRESSION/MODIFIERS

Substitute, according to given expression.

=head2 tr/PATTERN/EXPRESSION/MODIFIERS

Transcode, according to given expression.

=head2 p/PATTERN/COMMAND/MODIFIERS

Pipe matched content into shell command, and use it's output as replacement.

=head2 r/PATTERN/MODIFIERS

Remove parts, that match the regular expression.

=head2 m/PATTERN/MODIFIERS

Match parts of the filename and remove anything else.

=head1 MODIFIERS

=over

=item e

Evaluate EXPRESSION as Perl code, before replacing.

=item g

Enable global matching.

=item i

Do case-insensitive pattern matching.

=item m

Enable matching in multi-line mode.

That is, change "^" and "$" from matching the start or end of file to matching the start or end of any line.

=item s

Change "." to match any character whatsoever, even a newline, which normally it would not match.

=back

Enabling 'm' and 's' as "/ms", they let the "." match any character whatsoever, while still allowing "^" and "$" to match, respectively, just after and just before newlines within the string.

=head1 COMMAND LINE OPTIONS

=over

=cut

my %options_def;
my %options;

=item -a --ask

Ask, before doing anything.

=cut

$options_def{ 'a|ask' } = \$options{'ask'};

=item -c --changed-only

Write anything only, if any changes ware made.

=item -d --diff

Show I<diff> between original and modified content and ask for confirmation.

=item --diff-command=COMMAND

What comparison command to run, defaults to: F<diff>.

=item -e script --exec=command

Add the script to the commands to be executed.

=item -f options-file --file=options-file

Parse contents of options-file, as if it was part of the command line.

=item -h --help

Output a short help and exit.

=item -m --move

When used with I<-P> or I<-P>, F<fed> will move the file first, then copy it to the old name,
and finally modify moved file.

This preserves hard links, ownership and other attributes.

If file is changed in-place, the option is silently ignored.

=item -p --pretend

Do not do anything, just pretend and describe what would be done.

This option overwrites I<-a> (with a warning).

=item -q --quiet --silent

Output nothing, or as little as possible.

=item -r -R --recursive

Process directories recursively. If this option is not enabled, those will be ignored (silently, unless in verbose mode).

=item -v --verbose

Explain what is being done.

=item -P --prefix[=PREFIX]

Instead of doing the change in-place, save changed file to a copy with PREFIX added to the name.

=item -S --suffix[=SUFFIX]

Instead of doing the change in-place, save changed file to a copy with SUFFIX added to the name.

=item -V --version

Display version info and exit.

=back

=head1 REGULAR EXPRESSIONS

This command uses Perl Regular Expressions. It will understand everything,
that the version of Perl on which it runs will accept.

=cut

sub main { # {{{
    my ( @params ) = @_;

    GetOptionsFromArray(
        \@params,
        %options_def,
    );

#    use Data::Dumper; warn Dumper \%options, @params;

    return 0;
} # }}}

=head1 BUGS

None known at the moment.

=head1 TODO

Those are some interesting potential features, that may be implemented in future version.
If you need them, please notify the author.

=over

=item -x --one-file-system

Do not cross file system boundaries.

=item --color --no-color

Enable (or disable) use of color in the output.

Requires L<Term::ANSIColor>.

=item --recipy=RECIPY

Use recipy named I<RECIPY> from the APP::Fed::Coocbook.

=back

=head1 SEE ALSO

ack(1), awk(1), ed(1), grep(1), tr(1), perlre(1), sed(1)

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

=cut

# vim: fdm=marker
1;
