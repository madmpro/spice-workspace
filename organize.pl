#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use Term::ANSIColor;
use FindBin;

my $ignore_log = 1;  # Enable logging ignored lines.
my $models_dir = "$FindBin::Bin/models/testing";  # Location of the model library.

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


# Testing grounds.
my $filename = "models/testing/bjt.txt";
my $family = "bjt";

open(my $fh, "<:encoding(UTF-8)", $filename)
	or die "[" . colored("ERROR", "red") . "] Could not open file '$filename': $!\n";

# Check if the family directory exists.
if (!-d "$models_dir/$family") {
	unless(-e "$models_dir/$family" or mkdir "$models_dir/$family") {
		die "[" . colored("ERROR", "red") . "] Unable to create $models_dir/$family\n";
	}

	print "[" . colored("MKDIR", "bright_yellow") . "] New family " . uc($family) . ": $models_dir/$family created.\n";
}

while (my $line = <$fh>) {
	chomp $line;

	if ($line =~ m/^\.model/i) {
		if (is_valid $line) {
			my ($mpn, $type) = (split(/\s/, $line))[1, 2];
			
			# Standardizing and cleaning our main variables.
			$type =~ s/\(.*//;
			$type = lc($type);
			$mpn = uc($mpn);
			my $loc = "$models_dir/$family/$type";
			my $model_file = lc("$mpn.mod");

			# Check if the directory exists.
			if (!-d $loc) {
				unless(-e $loc or mkdir $loc) {
					die "[" . colored("ERROR", "red") . "] Unable to create $loc\n";
				}

				print "[" . colored("MKDIR", "bright_yellow") . "] New model type " . uc($type) . ": $loc created.\n";
			}

			# Create the model file.
			print "[" . colored("ADD", "green") . "] $type - $mpn\n";
		} else {
			ignore_model($fh, $line);
		}
	} else {
		ignore_model($fh, $line);
	}
}

