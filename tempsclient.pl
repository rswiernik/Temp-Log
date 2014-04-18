#!/usr/bin/perl

use strict;
use warnings;

use Socket;

my $VERSION = "1.0";
my $DEBUG = 0;
foreach my $arg (@ARGV) {
	# If executed as '~$ temps debug' it will ouput debug information
	if( ($arg =~ m/\-\-version/i) || ($arg =~ m/\-v/) ){
		print "Temps for Cylone Eye version: $VERSION\n";
		print "Author: Reed Swiernik\n";
	} elsif( ($arg =~ m/\-\-debug/i) || ($arg =~ m/\-d/) ){
		$DEBUG = 1;
	}
}

my $hostname = `hostname`; chomp($hostname);
my @info = `sensors`;
my $temp_line;

# Iterate through the output of sensors looking
# for the ISA adapter
foreach( my $i=0; $i<@info; $i++ ){
	# Grab and chomp the line
	my $line = $info[$i]; chomp($line);
	
	# Check for ISA Adapter in line
	if( $line =~ m/ISA adapter/ ){
		if($DEBUG){print "\t$line\n";}
		# once weve found the ISA adapter, grab the next line,
		# as that is where the adapter temperature is
		$temp_line = $info[$i+1]; chomp($temp_line);
		# Quit out of checking
		last;
	}
}
if($DEBUG){print "Parsing Line: $temp_line\n";}

my $temps = 0;
if( $temp_line =~ m/(\+[0-1]?[0-9]{2}\.0\xc2\xb0C)/ ){
	$temps = $1;
	if($DEBUG){print "Temp: $temps\n";}

	$temps =~ s/[^\d]//;
	if($DEBUG){print "$hostname,$temps\n";}
} else {
	if($DEBUG){print "No temp found\n";}
	exit 0;
}


# ;lasdf;ljkasdf;ljkafds
#my $port = 55693;
#my $protocol = getprotobyname(' 

exit 0;
