#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use Term::ANSIColor;
use FindBin;

my $ignore_log = 1;  # Enable logging ignored lines.
my $models_dir = "$FindBin::Bin/models";  # Location of the model library.

# Check the command-line arguments.
if (scalar(@ARGV) != 2) {
	print colored("Usage: $0 family library\n\n", "bold");
	print "This script grabs a SPICE model library file and splits it into multiple model files to make your SPICE workspace a lot more organized.\n\n";

	print "  family\tDevice family (example: bjt, mosfet, diode)\n";
	print "  library\tModel library downloaded from the internet\n";
	exit 0;
}

my ($family, $library_file) = @ARGV;
$family = lc($family);

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

	if ($ignore_log) {
		open(my $log_fh, ">>:encoding(UTF-8)", "$models_dir/ignored.log")
			or die "[" . colored("ERROR", "red") . "] Could not open file '$models_dir/ignored.log': $!\n";

		print $log_fh "$library_file:" . $file->input_line_number() . ": $line\n";
	}
}


# Testing grounds.
open(my $fh, "<:encoding(UTF-8)", $library_file)
	or die "[" . colored("ERROR", "red") . "] Could not open file '$library_file': $!\n";

# Check if the family directory exists.
if (!-d "$models_dir/$family") {
	unless(-e "$models_dir/$family" or mkdir "$models_dir/$family") {
		die "[" . colored("ERROR", "red") . "] Unable to create $models_dir/$family\n";
	}

	print "[" . colored("MKDIR", "bright_yellow") . "] New family " . uc($family) . ": $models_dir/$family created.\n";
}

# Read the model library, create model files and populate them.
while (my $line = <$fh>) {
	chomp $line;

	if ($line =~ m/^\.model/i) {
		if (is_valid $line) {
			my ($mpn, $type) = (split(/\s/, $line))[1, 2];
			
			# Standardizing and cleaning our main variables.
			$type =~ s/\(.*//;
			$type = lc($type);
			$mpn =~ s/\//-/g;
			$mpn = uc($mpn);

			# Special type only for diodes.
			if ($type eq "d") {
				if ($line =~ m/type\=([A-Za-z0-9]*)/i) {
					$type = lc($1);
				} else {
					$type = "undefined";
				}
			}

			# Generate the locations.
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
			open(my $model_fh, ">:encoding(UTF-8)", "$loc/$model_file")
				or die "[" . colored("ERROR", "red") . "] Could not open file '$loc/$model_file': $!\n";

			# Populate the model file.
			print $model_fh "* $mpn\n";
			print $model_fh "* $family/$type/$model_file\n\n";
			print $model_fh "$line\n";

			# Close and call it a success.
			close $model_fh;
			print "[" . colored("CREATED", "green") . "] $mpn model under $family/$type\n";
		} else {
			# Invalid model.
			ignore_model($fh, $line);
		}
	} else {
		# Random, non-model line.
		ignore_model($fh, $line);
	}
}

