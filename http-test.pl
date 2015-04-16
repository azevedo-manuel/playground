#!/usr/bin/env perl

require LWP::UserAgent;

my $ua = LWP::UserAgent->new;
my $response = $ua->get('http://10.1.1.103/DeviceInformationX');

if ($response->is_success) {
	print $response->decoded_content;
} else {
	print $response->status_line;
}

