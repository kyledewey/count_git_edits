#!/usr/bin/perl -w

use File::chdir;
use strict;

# Params:
# -Directory
# -Command to run
# Returns array of results
sub command_with_directory($$) {
    my ($directory, $command) = @_;
    my @retval;
    {
        local $CWD = $directory;
        # print "$command\n";
        @retval = `$command`;
    }
    if ($? == -1) {
        die "failed to execute $command";
    } elsif ($? & 127) {
        my $signal_result = $? & 127;
        die "$command died with signal $signal_result";
    } elsif ($? >> 8 != 0) {
        my $exit_value = $? >> 8;
        die "$command died with exit value $exit_value";
    }
    return @retval;
}

# Params:
# -Directory
# returns an array of branches
sub list_branches($) {
    my $directory = shift();
    my @output = command_with_directory($directory,
                                        "git ls-remote --heads origin");
    my @branches;
    foreach my $line (@output) {
        if ($line =~ /^[0-9a-f]+\s*refs\/heads\/(.*)$/) {
            push(@branches, $1);
        }
    }
    return @branches;
}

# Params:
# -Directory
# -Branch
# -Start time
# -End time
# -Reference to hash of contributor -> counts
# Updates the hash in place to reflect this branch
sub contributor_count_branch($$$$$) {
    my ($directory,
        $branch,
        $start_time,
        $end_time,
        $counts_ref) = @_;
    command_with_directory($directory,
                           "git checkout $branch");
    my $author = undef;
    my @output = command_with_directory($directory,
                                        "git log $branch --since '$start_time' --until '$end_time' --format='COMMIT,%cn,%ce' --numstat");
    foreach my $line (@output) {
        chomp($line);
        if ($line =~ /^COMMIT,([^,]*),([^,]*)$/) {
            $author = "$1; $2";
        } elsif ($line =~ /^\s*(\d+)\s*(\d+).*$/) {
            my $added = $1;
            my $deleted = $2;
            defined($author) or die "Author not defined for line $line";
            if (!exists($counts_ref->{$author})) {
                $counts_ref->{$author} = 0;
            }
            $counts_ref->{$author} += $added + $deleted;
        }
    }
}

# Params:
# -Directory
# -Start time
# -End time
# returns a reference to a hash mapping usernames to
# the number of edits since this start across all branches
sub count_edits($$$) {
    my ($directory,
        $start_time,
        $end_time) = @_;
    my %retval;
    
    # make sure we're up to date
    command_with_directory($directory, "git pull");

    # see all the available branches
    my @branches = list_branches($directory);
    
    foreach my $branch (@branches) {
        contributor_count_branch($directory,
                                 $branch,
                                 $start_time,
                                 $end_time,
                                 \%retval);
    }

    return \%retval;
}

sub usage() {
    print "Takes the following params:\n";
    print "-Directory containing repository\n";
    print "-When to start looking at commits, as interpreted by git log's --since\n";
    print "-When to stop looking at commits, as interpreted by git log's --until\n";
}

# ---BEGIN MAIN CODE---
if (scalar(@ARGV) != 3) {
    usage();
} else {
    my $counts_ref = count_edits($ARGV[0], $ARGV[1], $ARGV[2]);
    foreach my $author (sort(keys(%{$counts_ref}))) {
        my $edits = $counts_ref->{$author};
        print "$author: $edits\n";
    }
}
