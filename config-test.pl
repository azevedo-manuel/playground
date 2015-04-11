#!/usr/bin/env perl
#

use Config::Std;

read_config 'config-test.conf' => my %config;

my $username       = $config{''}{username};
my $password       = $config{''}{password};
my $thumbnailURL   = $config{''}{thumbnailURL};
my $backgroundURL  = $config{''}{backgroundURL};
my $logging        = $config{''}{logging};
my $logfile        = $config{''}{logfile};
my $IP             = $config{''}{IP};


print "Username:       $username\n";
print "Password:       $password\n";
print "Thumbnail URL:  $thumbnailURL\n";
print "Background URL: $backgroundURL\n";
print "Logging:        $logging\n";
print "Log file:       $logfile\n";
if (ref $IP eq 'ARRAY'){
	foreach (@$IP) {
		print "IP (array):     $_\n";
	}
} else {
	print "IP:             $IP\n";
}


