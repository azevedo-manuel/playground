#!/usr/bin/env perl
use Net::IP;
  
my @ip;


push @ip, new Net::IP ('192.168.1.1')    or die (Net::IP::Error());
push @ip, new Net::IP ('172.100.1.0/24') or die (Net::IP::Error());
push @ip, new Net::IP ('194.122.11.22 - 194.122.11.40') or die (Net::IP::Error());

my $host;

foreach (@ip){
	$host = $_;
	
	if ($host->size() == 1){
		print "Range: ".$host->size()." address\n";
		print $host->ip()." - ".$host->intip()."\n";
	} else {
		print "Range: ".$host->size()." addresses\n";
		do {
			print $host->ip()." - ".$host->intip()."\n";
		} while (++$host);
	}
}
