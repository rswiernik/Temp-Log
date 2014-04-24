#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(sum);
use Getopt::Long;

use Socket;

# Define variables for the runtime of the program
my $VERSION = "1.0";
my $DEBUG;
my $VER_CHK;
my $MASTER_NODE = "localhost";
my $SERVER;

# Check program arguments
GetOptions ('debug' => \$DEBUG,
			'version' => \$VER_CHK,
			'master=i' => \$MASTER_NODE,
			'server' => \$SERVER);

if( $VER_CHK ){

	print "Temps.pl version: $VERSION\n",
		"Author: Reed Swiernik\n\n",
		"This project works to report temperature data to a master node\n",
		"enabling use in restful API's and other data collection uses.\n";
	exit 0;

}

my $PORT = 55693;
my $PROTOCOL = getprotobyname('tcp');

if(!$SERVER){
	my $hostname = `hostname`; chomp($hostname);
	my @info = `sensors`;
	my @data;
	# Iterate through the output of sensors looking
	# for the ISA adapter and core temps
	for( my $i=0; $i<@info; $i++ ){

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
				$line = $info[$i]; chomp($line);
				push(@data, $line);
				if($DEBUG){print "Adding line: $line\n";}
				$i = $i + 1;
			}

			# Quit out of checking
			if($DEBUG){
				print "Final arranged data:\n";
				foreach (@data) {
					print "$_\n";
				}
			}
			last;
		}
	}

	my @temps;
	foreach my $entry (@data) {
		if($DEBUG){print "Parsing Line: $entry\n";}

		if( $entry =~ m/^Core\ [0-9]:.+?\+([0-1]?[0-9]{2}\.0)\xc2\xb0[CF]/ ){
			push(@temps, $1);
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
			# 
			# Then:
			# Set the matched portion that is the temp equal to the temps array
			
			if($DEBUG){print "Temp: $1\n";}
			if($DEBUG){print "$hostname,$1\n\n";}
		} else {
			if($DEBUG){print "No core temp found\n";}
		}
	} #end foreach for each sensors entry
	
	my $avg = 0;
	$avg = sum(@temps)/@temps;
	if($DEBUG){print "Average temp: $avg\n";}

} #end if for in client (!$SERVER)
 
if( $SERVER ){

	
	

} #end if for server ($SERVER)

exit 0;
