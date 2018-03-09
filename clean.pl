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
use Data::Dumper;
use FindBin;

my $models_dir = "$FindBin::Bin/models";  # Location of the model library.

# Check the command-line arguments.
if (scalar(@ARGV) < 1) {
	print colored("Usage: $0 model [vendor]\n\n", "bold");
	print "This script cleans models from various vendors to make them more consistent and to remove undesired parameters that generate warnings in ngspice.\n";

	print "  model\tModel file\n";
	print "  vendor\tModel vendor (example: ltspice, nxp, onsemi)\n";
	exit 0;
}

my ($filename, $vendor) = @ARGV;
my $content = "";
my $ignored_params = "";

open(my $fh, "<:encoding(UTF-8)", $filename)
	or die "[" . colored("ERROR", "red") . "] Could not open file '$filename': $!\n";

print colored("Original:\n", "bold");

while (my $line = <$fh>) {
	if ($line =~ m/^\.model/i) {
		# TODO: This is probably better done in the content later.
		# TODO: Ignore if this is matched when the line begins with a comment.
		my @params = ($line =~ /(nk|vceo|icrating|mfg|iave|vpk|type)\=([A-Za-z0-9\.\-\+]*)/gmi);
		print Dumper(\@params);

		for (my $i = 0; $i < int(scalar(@params) / 2); $i++) {
			my $key = @params[$i * 2];
			my $value = @params[($i * 2) + 1];
			
			$ignored_params .= "* $key = $value\n";
		}
	}

	print $line;
	$content .= $line;
}

# Clean the model.
$content =~ s/\s((nk\=([A-Za-z0-9\.\-\+]*))|(vceo\=([A-Za-z0-9\.\-\+]*))|(icrating\=([A-Za-z0-9\.\-\+]*))|(mfg\=([A-Za-z0-9\.\-\+]*))|(iave\=([A-Za-z0-9\.\-\+]*))|(vpk\=([A-Za-z0-9\.\-\+]*))|(type\=([A-Za-z0-9\.\-\+]*)))//gmi;

print colored("New:\n", "bold");
print "$content\n\n$ignored_params";

# TODO: Make sure to make the model name is uppercase.
# Remember that this script should only take a single model file.
# TODO: Use simple regex substitution to remove a parameter, no need to go splitting.

