#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use Term::ANSIColor;

# Checks if a model is valid or is just a glorified comment or a reference to another model.
sub is_valid {
	my ($line) = @_;

	if ($line =~ m/ako:/) {
		# Looks like we have a reference model. Lazy bastards...
		return 0;
	} elsif (length($line) <= 65) {
		# This model is less than 65 characters, there is no way this is real.
		return 0;
	}
	
	return 1;
}

# Ignores the model and does everything that is needed to dispose of it.
sub ignore_model {
	my ($file, $line) = @_;

	print "[" . colored("IGNORE", "red") . "] Line " . $file->input_line_number() . ": $line\n";
}

my $filename = "models/testing/bjt.txt";
open(my $fh, "<:encoding(UTF-8)", $filename)
	or die "Could not open file '$filename': $!";

while (my $line = <$fh>) {
	chomp $line;

	if ($line =~ m/^\.model/i) {
		if (is_valid $line) {
			print "[" . colored("ADD", "green") . "] $line\n";
		} else {
			ignore_model($fh, $line);
		}
	} else {
		ignore_model($fh, $line);
	}
}

