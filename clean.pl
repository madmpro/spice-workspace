#!/usr/bin/perl

### clean.pl
### Cleans the models from various vendors to make them more consistent and to
### remove undesired parameters that generate warnings in ngspice.
###
### Author: Nathan Campos <nathan@innoveworkshop.com>
### Date: 08 Mar 2018

use strict;
use warnings;
use IO::Handle;
use Term::ANSIColor;
use FindBin;

my $models_dir = "$FindBin::Bin/models";  # Location of the model library.

# Check the command-line arguments.
if (scalar(@ARGV) != 2) {
	print colored("Usage: $0 vendor model\n\n", "bold");
	print "This script cleans models from various vendors to make them more consistent and to remove undesired parameters that generate warnings in ngspice.\n";

	print "  vendor\tModel vendor (example: ltspice, nxp, onsemi)\n";
	print "  model\tModel file\n";
	exit 0;
}

my ($vendor, $filename) = @ARGV;

# TODO: Make sure to make the model name is uppercase.
# Remember that this script should only take a single model file.
# TODO: Use simple regex substitution to remove a parameter, no need to go splitting.

