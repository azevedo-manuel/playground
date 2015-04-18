#!/usr/bin/env perl
#

use warnings;
use strict;
use SOAP::Lite; #+trace => 'debug';
use Data::Dump qw(dump);

my $cucmip        = "10.1.1.70";
my $axlport       = "8443";
my $user          = "axluser";
my $password      = "axlpassword";
my $axltoolkit    = "AXLAPI.wsdl";
my $ristoolkit    = "RisPort.wsdl";
my $ver           = "8.5";
my $AXLnamespace  = "http://www.cisco.com/AXL/API/$ver";
my $RISnamespace  = "http://schemas.cisco.com/ast/soap/";

# Disable in case it complains about the certificate! Remember to put as a parameter
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

BEGIN {
	sub SOAP::Transport::HTTP::Client::get_basic_credentials {
		return ($user => $password)
	};
}

# Create an AXL request 

my $cm = new SOAP::Lite
         encodingStyle => '',
	 on_action     => (sub {return "CUCM:DB ver=$ver"}),
	 proxy         => "https://$cucmip:$axlport/axl/",
	 ns            => $AXLnamespace;

# Build the request

my $res = $cm->listPhone(SOAP::Data->name("searchCriteria" => \SOAP::Data->value(SOAP::Data->name("name"        => "SEP%")),
	                 SOAP::Data->name("returnedTags"   => \SOAP::Data->value(SOAP::Data->name("name"        => "?"),
			                                                         SOAP::Data->name("description" => "?"),
				                                                 SOAP::Data->name("product"     => "?"),
				                                                 SOAP::Data->name("model"       => "?"),
				                                                 SOAP::Data->name("class"       => "?"),
				                                                 SOAP::Data->name("protocol"    => "?")
			                                      )
                                         )
			)
);

my $totalPhones;
unless ($res->fault) {
	my @phones = $res->valueof('//listPhoneResponse/return/phone');
	print "Total number of found phones: ".($totalPhones=scalar(@phones))."\n";
	foreach (@phones){
		print $_->{name}." : ";
		print $_->{product}." : ";
		print $_->{class}." : ";
		print $_->{protocol}." \n";
	} 
} else {

}

my $numberChunks = int($totalPhones / 200);

print "Total number of chunks is $numberChunks\n";
