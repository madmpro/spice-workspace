#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use Term::ANSIColor;

my $filename = "models/testing/bjt.txt";
open(my $fh, "<:encoding(UTF-8)", $filename)
	or die "Could not open file '$filename': $!";

while (my $line = <$fh>) {
	if ($line =~ /^\.model/i) {
		print "[" . colored("ADD", "green") . "] $line";
	} else {
		print "[" . colored("IGNORE", "red") . "] Line " . $fh->input_line_number() . ": " . $line;
	}
}

