#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw(sum);
use Getopt::Long;
use IO::Socket::INET;

# Define the runtime version of this program
# (used in check_version sub)
my $VERSION = "1.0";
# $PORT is the port number that will be used for both server and client.
my $PORT = 55693;

my $DEBUG;
my $VER_CHK;
my $MASTER_NODE = "localhost";
my $SERVER;
my $HELP;

# Check program arguments
GetOptions ('debug' => \$DEBUG,
			'version' => \$VER_CHK,
			'master=s' => \$MASTER_NODE,
			'server' => \$SERVER,
			'help' => \$HELP);

if( $VER_CHK ){

	&check_version( $VERSION );

} elsif( $HELP ){

	&display_help();

} elsif( $SERVER ){

	&server( $PORT );

} elsif( !$SERVER ){

	if( $MASTER_NODE !~ m/([0-9]{1,3}\.?){4}/ and $MASTER_NODE !~ m/localhost/ ){
		if( $DEBUG ){
			print "Invalid master node address.\n";
		}
		exit 1;
	}

	&client( $PORT,$MASTER_NODE );

}

if($DEBUG){ print "No option selected... Master Node: <$MASTER_NODE>\n\n"; &display_help(); }

exit 1;


# Sub for the server
sub server {
	my $PORT = shift;

	my ($socket, $client_socket);

	# Create the socket object
	$socket = new IO::Socket::INET (
	LocalHost => '129.21.50.75',
	LocalPort => $PORT,
	Proto => 'tcp',
	Listen => 5,
	Reuse => 1
	) or die "ERROR in Socket Creation : $!\n";

	if($DEBUG){ print "Awaiting client connections on port $PORT\n"; }

	my ($peer_address, $peer_port, $client_data, @data_array );
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);

	while(1){

		# wait to accept a new client connection	
		$client_socket = $socket->accept();
	
		# extract the peer address and port
		$peer_address = $client_socket->peerhost();
		$peer_port = $client_socket->peerport();

		if($DEBUG){ print "Accepted new client: $peer_address, $peer_port\n"; }
		
		# print $client_socket "$data\n";
		$client_data = <$client_socket>;
		@data_array = split(',', $client_data);

		if($DEBUG){
			print "\tData recieved:\n";
			foreach (@data_array) {
				print "\t\t$_\n";
			}
		}

		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
		$year += 1900;
		my $filename = "temps\_$year-$mon-$mday.log";
		open( FILE, '>>', $filename );
		
		print FILE "\"$year-$mon-$mday $hour:$min:$sec\",$peer_address,$data_array[1]\n";

		close( FILE );

	}
	
	$socket->close();
	exit 0;

} #end of server sub

sub client {
	my ($PORT, $MASTERNODE) = @_;

	my $hostname = `hostname`; chomp($hostname);
	my @info = `sensors`;
	my @data;

	if( $info[0] =~ m/No sensors found!/ ){
		if( $DEBUG ){ print "No sensors output, exiting.\n"; }
		exit 1;
	}

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
			#if($DEBUG){
			#	print "Final arranged data:\n";
			#	foreach (@data) {
			#		print "$_\n";
			#	}
			#}
			last;
		}
	}

	if( !@data ){
		if( $DEBUG ){ print "No temperature output in sensors, exiting.\n"; }
		exit 1;
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
		} else {
			if($DEBUG){print "No core temp found\n";}
		}
	} #end foreach for each sensors entry
	
	my $avg = 0;
	$avg = sum(@temps)/@temps;
	if($DEBUG){print "Average temp: $avg\n";}
	
	my $data = "$hostname,$avg";

	# Start networked client portion
	# $MASTER_NODE is the argument variable used for the masternode to report
	# to if being run as the client.
	
	my ($socket, $client_socket);

	# Create the socket object
	$socket = new IO::Socket::INET (
	PeerAddr => $MASTERNODE,
	PeerPort => $PORT,
	Proto => 'tcp',
	) or die "ERROR in Socket Creation : $!\n";

	if($DEBUG){ print "Connecting to $MASTERNODE on port $PORT\n"; }

	my ($peer_address, $peer_port, $client_data, @data_array );
	
	if($DEBUG){ print "Sending data: $data\n"; }
	
	print $socket "$data";
	
	if($DEBUG){ print "Data sent...\n"; }

	# End networked client portion
	$socket->close();

	exit 0;
} #end if for in client (!$SERVER)

# Subroutine for checking the version of the program
sub check_version {
	my $version = shift;
	print "Temps.pl\t(Version: $version)\n",
		"Author: Reed Swiernik\n\n",
		"Temp-Log\n",
		"===\n",
		"Temperature monitoring in perl using lm-sensors. This perl script scraps the output of the 'sensors' portion of lm-sensors. In the designed use-case, the server portion of Temps is run on the master node and each client whoes temperature is being monitored is then reported to the master. \n",
		"This project works to report temperature data to a master node\n",
		"enabling use in restful API's and other data collection uses.\n";
	exit 0;
}

# Subroutine for displaying the help page
sub display_help {

	my $help_output = <<'HELP';
Uasge as Client:
When run as the client, the script gathers core temperature data, means them, and sends the data to a master node. By default, when run as the client the program will send info to localhost. 
~$ ./temps.pl -m <master node>
	[-v | --version]
	[-d | --debug]
					
Uasge as Server:
When run as the master node, the program should be run in the background awaiting outer node information.
~$ ./temps.pl -s &
	[-v | --version]
	[-d | --debug]
HELP

	print "$help_output\n";
	exit 0;
}
