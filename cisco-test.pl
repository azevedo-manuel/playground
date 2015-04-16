#!/usr/bin/env perl

require LWP::UserAgent;
use XML::Bare;

my $ua = LWP::UserAgent->new;
my $response = $ua->get('http://10.1.1.103/DeviceInformationX');


if ($response->is_success) {
	#print $response->decoded_content;
	my $ob = new XML::Bare (text=>$response->decoded_content);
	my $xml = $ob->parse();

	print "Model Number : $xml->{DeviceInformation}->{modelNumber}->{value}\n";
	print "Serial Number: $xml->{DeviceInformation}->{serialNumber}->{value}\n";
	print "MAC Address  : $xml->{DeviceInformation}->{MACAddress}->{value}\n";
} else {
	print $response->status_line;
}


