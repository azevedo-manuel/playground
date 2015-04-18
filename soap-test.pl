#!/usr/bin/env perl
#

use warnings;
use strict;
use SOAP::Lite;#  +trace => 'debug';

my $cucmip     = "10.1.1.70";
my $axl_port   = "8443";
my $user       = "axluser";
my $password   = "axlpassword";
my $axltoolkit = "AXLAPI.wsdl";
my $ver        = "8.5";
my $namespace  = "http://www.cisco.com/AXL/API/$ver";

# Disable in case it complains about the certificate! Remember to put as a parameter
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

BEGIN {
	sub SOAP::Transport::HTTP::Client::get_basic_credentials {
		return ($user => $password)
	};
}
		
my $cm = new SOAP::Lite
	 encodingStyle => '',
	 on_action => (sub {return "CUCM:DB ver=$ver"}),
	 proxy => "https://$cucmip:$axl_port/axl/",
	 ns => $namespace;

# Here's the Request
#
my $res =  $cm->getUser(SOAP::Data->name("userid" => "imguser"));
unless ($res->fault) {
	print "Returned answer:\n";
	print "First name: ".$res->valueof('//getUserResponse/return/user/firstName')."\n";
	print "Last name : ".$res->valueof('//getUserResponse/return/user/lastName')."\n";
	print "Telephone : ".$res->valueof('//getUserResponse/return/user/telephoneNumber')."\n";
	my @devices = $res->valueof('//getUserResponse/return/user/associatedDevices/device');
	foreach (@devices) {
		print "IP Phone: $_ \n";
	}
	print "\n";
} else {
	print "Code   : ".$res->faultcode."\n";
	print "Message: ".$res->faultstring." \n";
}                               

