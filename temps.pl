#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

use Socket;

# Define variables for the runtime of the program
my $VERSION = "1.0";
my $DEBUG;
my $VER_CHK;
my $MASTER_NODE = "localhost";
my $PORT = 55693;
my $PROTOCOL = getprotobyname('tcp');
my @data;

# Check program arguments
GetOptions ('debug' => \$DEBUG,
			'version' => \$VER_CHK,
			'master=i' => \$MASTER_NODE);

if( $VER_CHK ){

	print "TempsClient.pl version: $VERSION\n";
	print "Author: Reed Swiernik\n";
	exit 0;

}

my $hostname = `hostname`; chomp($hostname);
my @info = `sensors`;
my $temp_line;

# Iterate through the output of sensors looking
# for the ISA adapter and core temps
foreach( my $i=0; $i<@info; $i++ ){

	# Grab and chomp the line
	my $line = $info[$i]; chomp($line);
	
	# Check for coretemp in line
	if( $line =~ m/coretemp/i ){
		$i = $i + 1;
		if($DEBUG){print "\t$line\n";}
		# once weve found the ISA adapter, grab the next line,
		# as that is where the adapter temperature is
		# $temp_line = $info[$i+1]; chomp($temp_line);
		while($info[$i] !~ m/^\n$/){
			if($DEBUG){print "Adding line: $line\n";}
			$line = $info[$i]; chomp($line);
			push(@data, $line);
			$i = $i + 1;
		}

		# Quit out of checking
		if($DEBUG){print @data;}
		last;
	}
}

if($DEBUG){print "Parsing Line: $temp_line\n";}

my $temps = 0;
if( $temp_line =~ m/\+([0-1]?[0-9]{2}\.0)\xc2\xb0[CF]/ ){
	# Regex for matching the sensors output
	# -----
	# m/\+([0-9]?{2}[0-9]\.0)\xc2\xb0[CF]/ ){
	# 
	# Here are some example ouputs that the regex matches:
	# +100.0°C +35.0°F +23.0°C
	#
	# Written out:
	# Plus sign followed by a number from 0 to 999 followed by a period, a 0,
	# the degree sign (\xc2\xb0 is the hex value), and either a C or and F
	# for the scale - returning the matched 235.0 value in the $1 variable
	

	# Set the matched portion that is the temp equal to the temps variable
	$temps = $1;
	
	if($DEBUG){print "Temp: $temps\n";}
	if($DEBUG){print "$hostname,$temps\n";}

} else {

	if($DEBUG){print "No temp found\n";}
	exit 0;

}


exit 0;
