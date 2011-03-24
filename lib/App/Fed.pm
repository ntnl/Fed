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
use warnings; use strict;

my $VERSION = '0.01_99'; # {{{

use English qw( -no_match_vars );
use File::Slurp qw( read_file write_file read_dir );
use File::Temp qw( tempfile );
use Getopt::Long 2.36 qw( GetOptionsFromArray );
# }}}

=encoding UTF-8

=head1 NAME

fed - file editor for filtering and transforming text, file-wide.

=head1 SYNOPSIS

 fed [OPTION]... [COMMAND]... [input-file]...
 
 # Replace first occurance of 'foo' and 'bar' (and all between) with space.
 fed 's/foo.+?baz/foo baz/' text_*.txt
 
 # Strip comments from config files, each time show diff and ask:
 fed -a -d 'r/\s*#.+?$/m' *.conf
 
 # Remove HTML links.
 fed -c 's{<a.+?>(.+?)<\\\/a>}{$1}sg' page*.html

=head1 DISCLAIMER

This is an Alpha release. It may be unstable. It may corrupt your files.

Use with caution, for evaluation purposes only.

=head1 DESCRIPTION

Fed is a replace/filter utility, working on per-line or per-file basis, across multiple files,
even going recursively into directories.

It aims to provide easy access to some functionality of I<sed>, I<awk> and I<Perl>.

By default it will replace files in-place, so you do not have to pipe/move anything.

You can control the edit process either by having changed files written under different name,
or by inspecting changes (with F<diff>) and accepting them manually.

=head1 COMMANDS

Following commands are supported: B<s> (substitute), B<tr> (transcode), B<p> (pipe),
B<r> (remove), and B<m> (match). Following separators are supported: B<//>, B<{}>, B<[]>.

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

=cut

my %command_spec = (
    s  => {
        groupping   => 1, # Groups are allowed.
        replacement => 1, # Replacement is required

        callback => \&_handle_s,
    },
    tr => {
        groupping   => 0,
        replacement => 1,

        callback => \&_handle_tr,
    },
    p  => {
        groupping   => 1,
        replacement => 1,

        callback => \&_handle_p,
    },
    r  => {
        groupping   => 0,
        replacement => 0,

        callback => \&_handle_r,
    },
    m  => {
        groupping   => 0,
        replacement => 0,

        callback => \&_handle_m,
    },
);

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

Ask, before writing anything.

=cut

$options_def{ 'a|ask' } = \$options{'ask'};

=item -c --changed-only

Write anything only, if any changes ware made.

=cut

$options_def{ 'c|changed-only' } = \$options{'changed-only'};

=item -d --diff

Show I<diff> between original and modified content, before writing changes.

By default, program will not ask or wait for confirmation, just describe the changes and continue.
If you want to be able to inspect and confirm changes, use with combination with I<-a>.

This is useful to be able to quickly inspect - post-mortem - what has been done.

=cut

$options_def{ 'd|diff' } = \$options{'diff'};

=item --diff-command=COMMAND

What comparison command to run, defaults to: F<diff>.

=cut

$options_def{ 'diff-command' } = \$options{'diff-command'};

=item -h --help

Output a short help and exit.

=cut

$options_def{ 'h|help' } = \$options{'help'};

=item -m --move

When used with I<-P> or I<-S>, F<fed> will move the file first, then copy it to the old name,
and finally modify moved file.

This preserves hard links, ownership and other attributes.

If file is changed in-place, the option is silently ignored.

=cut

$options_def{ 'm|move' } = \$options{'move'};

=item -p --pretend

Do not do anything, just pretend and describe what would be done.

This option overwrites I<-a> (with a warning).

=cut

$options_def{ 'p|pretend' } = \$options{'pretend'};

=item -q --quiet --silent

Output nothing, and if, then only to STDERR.

=item -r -R --recursive

Process directories recursively. If this option is not enabled, those will be ignored (silently, unless in verbose mode).

=cut

$options_def{ 'r|R|recursive' } = \$options{'recursive'};

=item -P --prefix[=PREFIX]

Instead of doing the change in-place, save changed file to a copy with PREFIX added to the name.

=cut

$options_def{ 'P|prefix=s' } = \$options{'prefix'};

=item -S --suffix[=SUFFIX]

Instead of doing the change in-place, save changed file to a copy with SUFFIX added to the name.

=cut

$options_def{ 'S|suffix=s' } = \$options{'suffix'};

=item -v --verbose

Explain what is being done.

=cut

$options_def{ 'v|verbose' } = \$options{'verbose'};

=item -V --version

Display version info and exit.

=cut

$options_def{ 'V|version' } = \$options{'version'};

=back

=head1 REGULAR EXPRESSIONS

This command uses Perl Regular Expressions. It will understand everything,
that the version of Perl on which it runs will accept.

=cut

sub main { # {{{
    my ( @params ) = @_;

    # Display help, if run without parameters.
    if (not scalar @params) {
        @params = q{--help};
    }

    Getopt::Long::Configure("bundling");
    GetOptionsFromArray(
        \@params,
        %options_def,
    );

#    use Data::Dumper; warn Dumper \%options, @params;

    if ($options{'version'}) {
        print "File EDitor v" . $VERSION . "\n";

        return 0;
    }
    elsif ($options{'help'}) {
        print "File EDitor v" . $VERSION ."\n";

        print qq{\n};
        print qq{Usage:\n};
        print qq{    \$ fed [OPTIONS] COMMANDS FILES\n};
        print qq{\n};
        print qq{Commands:\n};
        print qq{\n};
        print qq{    s/Pattern/String/eigms  Substitute - replace 'Pattern' with 'String'\n};
        print qq{    p/Pattern/Command/igms  Pipe - replace 'Pattern' with output from 'Command'\n};
        print qq{    tr/From/To/             Transcode - Replace letters from 'From' to their pairs from 'To'\n};
        print qq{    m/Pattern/irms          Match - Remove everything, that does not match the 'Pattern'\n};
        print qq{    r/Pattern/igms          Remove - Remove every occurance of 'Pattern'\n};
        print qq{\n};
        print qq{Options:\n};
        print qq{\n};
        print qq{    -p --pretend           Do not do anything, just describe what would be done.\n};
        print qq{    -a --ask               Ask, before writing anything.\n};
        print qq{    -d --diff              Show 'diff' between original and modified content.\n};
        print qq{    --diff-command=COMMAND What comparison command to run, defaults to: 'diff'.\n};
        print qq{    -q --quiet --silent    Output nothing.\n};
        print qq{    -v --verbose           Explain what is being done.\n};
        print qq{\n};
        print qq{    -c --changed-only      Write anything only, if any changes ware made.\n};
        print qq{    -m --move              Move, then backut, then rename. Preserves attributes.\n};
        print qq{    -P --prefix[=PREFIX]   Append PREFIX to filename and write there.\n};
        print qq{    -S --suffix[=SUFFIX]   Append SUFFIX to filename and write there.\n};
        print qq{    -r -R --recursive      Process directories recursively.\n};
        print qq{\n};
        print qq{    -h --help              Display this usage summary.\n};
        print qq{    -V --version           Display version info and exit.\n};
        print qq{    \n};
        print qq{Example:\n};
        print qq{    \n};
        print qq{    \$ fed -a -d -r -S .new 's/br0k3n/broken/g' my_text_files/\n};
        print qq{           |  |  |  |       |                  |\n};
        print qq{           |  |  |  |       |                  '-- all files from 'my_text_files'.\n};
        print qq{           |  |  |  |       '-- Substitute all occurances of 'br0k3n' with 'broken'.\n};
        print qq{           |  |  |  '-- Write to new files, with '.new' appended to the name\n};
        print qq{           |  |  '-- Dive into subdirectories.\n};
        print qq{           |  '-- Display differences after processing each file.\n};
        print qq{           '-- Ask for confirmation, before writing changes.\n};
        print qq{\n};

        return 0;
    }

    if ($options{'ask'} and $options{'pretend'}) {
        print STDERR "Note: 'ask' overwrites 'pretend'!\n";

        delete $options{'pretend'};
    }

    # Isolate commands from files.
    my @commands;
    my @files;

    foreach my $param (@params) {
        if ($param =~ m{^([stprm]r?)(.+?)([egims]+)?$}s) {
            # This looks as a command :)
            my ( $command, $guts, $modifiers ) = ( $1, $2, $3 );

#            warn qq{ $command, $guts, $modifiers };

            my ( $is_regexp, $pattern, $expression );
            if ($guts =~ m{^/(.+?)(?<!\\)/((.*?)/)?$}) {
                ( $is_regexp, $pattern, $expression ) = ( 1, $1, $3 );
            }
            elsif ($guts =~ m{^\{(.+?)\}(\{(.*?)\})??$}) {
                ( $is_regexp, $pattern, $expression ) = ( 1, $1, $3 );
            }
            elsif ($guts =~ m{^\[(.+?)\](\[(.*?)\])?$}) {
                ( $is_regexp, $pattern, $expression ) = ( 1, $1, $3 );
            }

            if ($command_spec{$command} and $is_regexp) {
                # This IS a command :)
                # Do sanity-quoting to avoid 'variable injection'
                $pattern =~ s{(?<!\\)\$([^0-9])}{\\\$$1}gs;

                # Quote '/' as well...
                $pattern =~ s{(?<!\\)\/}{\\\/}gs;

                if ($expression) {
                    $expression =~ s{(?<!\\)\$([^0-9])}{\\\$$1}gs;
                    $expression =~ s{(?<!\\)\/}{\\\/}gs;
                }
                push @commands, {
                    command   => $command,
                    pattern   => $pattern,
                    replace   => $expression,
                    modifiers => $modifiers,
                };

                # Head to next parameter.
                next;
            }
        }

        # It was not recognised as regular expression, therefore it must be a file.
        if (-f $param) {
            push @files, $param;
        }
        elsif ($options{'recursive'} and -d $param) {
            push @files, _recure_into_dir($param);
        }
    }

#    use Data::Dumper; warn Dumper \@files, \@commands;

    my $failures = _check_regs(\@commands);
    if ($failures) {
        return 4;
    }

    my $i = 1;
    my $count = scalar @files;
    foreach my $file (@files) {
        my $percent = int 100 * $i / $count;
        _verbose("File $i of $count ($percent%)\n");
        $i++;

        my $continue = _process_file($file, \@commands);

        if (not $continue) {
            last;
        }
    }

    _verbose("Done.\n");

    return 0;
} # }}}

sub _check_regs { # {{{
    my ( $commands ) = @_;

    my $failures = 0;

    foreach my $command (@{ $commands }) {
        my $ok = eval {
            my $regexp = $command->{'pattern'};

            my $re = qr{$regexp};

            return $re;
        };

        if ($EVAL_ERROR or not $ok) {
            print STDERR "Invalid REGEXP: (please correct)\n   ". $command->{'pattern'} ."\n\n";
            if ($EVAL_ERROR) {
                print STDERR $EVAL_ERROR;
                print STDERR "\n";
            }

            $failures++;
        }
    }

    return $failures;
} # }}}

sub _recure_into_dir { # {{{
    my ( $dir ) = @_;
    
    _verbose("Reading " . $dir . "\n");

    my @files;

    my @fs_items = read_dir($dir);
    foreach my $item (sort @fs_items) {
        if (-f $dir . q{/} . $item) {
            push @files, $dir . q{/} . $item;

            next;
        }
        
        if (-d $dir . q{/} . $item) {
            push @files, _recure_into_dir($dir . q{/} . $item);
        }
    }

    return @files;
} # }}}

sub _process_file { # {{{
    my ( $file, $commands ) = @_;

    # If We have printed something, while working with this file,
    # rise this flag - it will add a separator (newline) in case there will be some
    # stuff printed later.
    my $push_newline = 0;

    if ($options{'verbose'}) {
        $push_newline = _print_file_name($file, $push_newline);
    }

    # Read in the file.
    my $contents = read_file($file);

    my $something_was_done = 0;

    foreach my $command (@{ $commands }) {
        my $something_was_done_here;

        my $callback = $command_spec{ $command->{'command'} }->{'callback'};

        ( $contents, $something_was_done_here ) = $callback->($contents, $command);

        if ($something_was_done_here) {
            $something_was_done++;
        }
    }

    # If We are to write only in case there ware any changes...
    if ($options{'changed-only'} and not $something_was_done) {
        # ... then bail out, if there ware none.
        
        _verbose("  No changes.\n\n");

        return 1;
    }

    # Decide, where We will output.
    my $file_out = $file;
    if ($options{'prefix'} or $options{'suffix'}) {
        $file_out = _rename_file($file, $options{'prefix'}, $options{'suffix'});
    }
    
    if ($file ne $file_out) {
        _verbose("  Target: $file_out\n");
    }

    # Assumption is, that if regexp returns true, then there ware changes.
    # If running with --diff, this can actually be verified :)
    my $has_changes = $something_was_done;

    # This is a good place to show differences, if they ware requested.
    if ($options{'diff'}) {
        $push_newline = _print_file_name($file, $push_newline);

        print "\n  Diff:\n";

        my $diff_command = ( $options{'diff-command'} or 'diff' );

        my ($tmp_fh, $tmp_file) = tempfile();

        write_file($tmp_fh, $contents);
        my $fh;
        $has_changes = 0;
        open $fh, q{-|}, $diff_command, $file, $tmp_file;
        while (my $line = <$fh>) {
            print q{    } . $line;

            $has_changes = 1;
        }
        close $fh;

        unlink $tmp_file;
        
        if (not $has_changes) {
            print "    (no changes)\n";
        }
    }

    # If User wants to confirm - ask Him politely :)
    if ($has_changes and $options{'ask'}) {
        my $char = 1;

        $push_newline = _print_file_name($file, $push_newline);

        while ($char) {
            print "\n";
            print q{  Write changes? (n = no, q = quit, y = yes, a = all) : };

            $char = <STDIN>;
            chomp $char;
            print "\n";

            $char = lc $char;

            if ($char eq 'n') { 
                return 1;
            }

            if ($char eq 'q') { 
                return;
            }

            if ($char eq 'a') {
                $options{'ask'} = 0;

                last;
            }

            if ($char eq 'y') {
                last;
            }
        }
    }

    # If running in 'pretend' mode - bail out just before writing anything...
    if ($options{'pretend'} and not $has_changes) {
        $push_newline = _print_file_name($file, $push_newline);

        print "\n  Would be skipped.\n";
    }
    elsif ($options{'pretend'}) {
        $push_newline = _print_file_name($file, $push_newline);

        print "\n  Would be updated.\n";
    }
    else {
        # Write out modified content.
        if ($file ne $file_out and $options{'move'}) {
            rename $file, $file_out;

            # Copy contents to the old name...
            write_file($file, read_file($file_out));

            # Write into new location.
            write_file($file_out, $contents);
        }
        else {
            # Write out.
            write_file($file_out, $contents);
        }

        _verbose("  Updated.\n");
    }

    if ($push_newline) {
        print "\n";
    }
    
    return 1;
} # }}}

sub _rename_file { # {{{
    my ( $path, $prefix, $suffix ) = @_;

#    warn "( $path, $prefix, $suffix )";

    if ($prefix) {
        $path =~ s{/([^/]+)$}{/$prefix$1}si;
    }

    if ($suffix) {
        return $path . $suffix;
    }

    return $path;
} # }}}

sub _print_file_name { # {{{
    my ($file_name, $omit) = @_;

    if (not $omit) {
        print $file_name . qq{ :\n};
    }

    return 1;
} # }}}

sub _handle_s { # {{{
    my ( $contents, $command ) = @_;

    my ( $match, $replace, $modifiers ) = ( $command->{'pattern'}, ($command->{'replace'} or q{}), ($command->{'modifiers'} or q{}) );

    # Eval is not the best option, but I have no better solution for now.
    my $replaced = eval q{ $contents =~ s/} . $match . q{/} . $replace . q{/} . $modifiers;

    return ($contents, $replaced);
} # }}}

sub _handle_tr { # {{{
    my ( $contents, $command ) = @_;

    my ( $tr_from, $tr_to, $modifiers ) = ( $command->{'pattern'}, ($command->{'replace'} or q{}), ($command->{'modifiers'} or q{}) );

    # Eval is not the best option, but I have no better solution for now.
    my $replaced = eval q{ $contents =~ tr/} . $tr_from . q{/} . $tr_to . q{/} . $modifiers;

    return ($contents, $replaced);
} # }}}

sub _handle_p { # {{{
    my ( $contents, $command ) = @_;

    my ( $match, $pipe_command, $modifiers ) = ( $command->{'pattern'}, ($command->{'replace'} or q{}), ($command->{'modifiers'} or q{}) );

    # FIXME: additional 'e' will probably NOT do what the User expects!

    # Eval is not the best option, but I have no better solution for now.
    my $replaced = eval q{ $contents =~ s/(} . $match . q{)/_p_pipe($pipe_command, $1)/e} . $modifiers;

    return ($contents, $replaced);
} # }}}

sub _p_pipe { # {{{
    my ( $command, $input ) = @_;
    
    # FIXME: Replace with two-way open.
    write_file(q{/tmp/fed_} . $PID, $input);

    my $fh;
    open $fh, q{-|}, q{cat /tmp/fed_} . $PID . q{ | } . $command;
    my $output = read_file($fh);
    close $fh;

    unlink q{/tmp/fed_} . $PID;

    return $output;
} # }}}

sub _handle_m { # {{{
    my ( $contents, $command ) = @_;

    my ( $match, $modifiers ) = ( $command->{'pattern'}, ($command->{'modifiers'} or q{}) );

    my @matches = eval q{ return ( $contents =~ m/(} . $match . q{)/} . $modifiers .q{ ) };

    if (scalar @matches) {
        return ( (join q{}, @matches), 1);
    }

    return ($contents, 0);
} # }}}

sub _handle_r { # {{{
    my ( $contents, $command ) = @_;

    my ( $match, $modifiers ) = ( $command->{'pattern'}, ($command->{'modifiers'} or q{}) );

    # Eval is not the best option, but I have no better solution for now.
    my $replaced = eval q{ $contents =~ s/} . $match . q{//} . $modifiers;

    return ($contents, $replaced);
} # }}}

sub _verbose { # {{{
    my ( $msg ) = @_;

    if (not $options{'verbose'}) {
        return;
    }
    
    print $msg;

    return;
} # }}}

=head1 BUGS

Probably. None known at the moment.

Please report using CPAN RT or email to the author.

=head1 TODO

Those are some interesting potential features, that may be implemented in future version.
If you need them, please notify the author.

=over

=item -x --one-file-system

Do not cross file system boundaries.

=item --color --no-color

Enable (or disable) use of color in the output.

Requires L<Term::ANSIColor>.

=item --recipe=RECIPY

Use recipe named I<RECIPY> from the APP::Fed::Coocbook.

=item --check=Command

Run 'C<Command file>' after applying changes.

If F<Command> returns non-zero exit status, changes will be cancelled.

F<fed> will create a tmp file containing modified content,
and use it for test, before changing the original.

=item -s --stats --summary

On completion, dump summary of what was done.

=back

=head1 SEE ALSO

ack(1), awk(1), ed(1), grep(1), tr(1), perlre(1), sed(1)

=head1 COPYRIGHT

Copyright (C) 2011 Bartłomiej /Natanael/ Syguła

This is free software.
It is licensed, and can be distributed under the same terms as Perl itself.

=cut

# Internal notes:
#
#   o Consider using Regexp::Parser - but it supports up to 5.8.x only :(

# vim: fdm=marker
1;
