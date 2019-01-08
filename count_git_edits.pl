#!/usr/bin/perl -w

use Date::Parse;

use strict;

my $time = str2time($ARGV[0]);
print "$time\n";
