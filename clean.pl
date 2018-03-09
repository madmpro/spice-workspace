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

my $content = "";
my $ignored_params = "";

# Check the command-line arguments.
if (scalar(@ARGV) < 1) {
	print colored("Usage: $0 model [vendor]\n\n", "bold");
	print "This script cleans models from various vendors to make them more consistent and to remove undesired parameters that generate warnings in ngspice.\n";

	print "  model\tModel file\n";
	print "  vendor\tModel vendor (example: ltspice, nxp, onsemi)\n";
	exit 0;
}

my ($filename, $vendor) = @ARGV;

# Open the model file and read all of its contents, then seek it all back for writing.
print "[" . colored("OPEN", "bright_blue") . "] Opening model: $filename\n";
open(my $fh, "<:encoding(UTF-8)", $filename)
	or die "[" . colored("ERROR", "red") . "] Could not open file '$filename': $!\n";

print "[" . colored("READ", "bright_yellow") . "] Reading contents of the model file.\n";
while (my $line = <$fh>) {
	$content .= $line;
}

close($fh);

# Grab the ignored parameters in a array.
my @params = ($content =~ /(nk|vceo|icrating|mfg|iave|vpk|type)\=([A-Za-z0-9\.\-\+]*)/gmi);

# Generate the ignored parameter comments.
for (my $i = 0; $i < int(scalar(@params) / 2); $i++) {
	my $key = @params[$i * 2];
	my $value = @params[($i * 2) + 1];
	
	$ignored_params .= "* $key: $value\n";
}

# Clean the model.
print "[" . colored("CLEAN", "bright_yellow") . "] Cleaning the model.\n";
$content =~ s/\s(nk|vceo|icrating|mfg|iave|vpk|type)\=([A-Za-z0-9\.\-\+]*)//gmi;

# Write the new model file.
print "[" . colored("WRITE", "bright_yellow") . "] Writing the new contents of the model file.\n";
open($fh, ">:encoding(UTF-8)", $filename)
	or die "[" . colored("ERROR", "red") . "] Could not open file '$filename': $!\n";

print $fh "$content";
if (length($ignored_params) > 0) {
	print $fh "\n$ignored_params";
}

close($fh);
print "[" . colored("OK", "green") . "] Wrote clean model to $filename\n";

