#!/usr/bin/env perl
#

use warnings;
use strict;
use SOAP::Lite;#+trace => 'debug';
use Data::Dump qw(dump);

my $cucmip        = "10.1.1.70";
my $axlport       = "8443";
my $user          = "axluser";
my $password      = "axlpassword";
my $axltoolkit    = "AXLAPI.wsdl";
my $ristoolkit    = "file:./risdb/RisPort.wsdl";
my $ver           = "8.5";
my $AXLnamespace  = "http://www.cisco.com/AXL/API/$ver";
my $RISnamespace  = "http://schemas.cisco.com/ast/soap/";
my $RISmaxPhones  = 4;

# Disable in case it complains about the certificate! Remember to put as a parameter
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

*SOAP::Deserializer::typecast = sub {shift; return shift};

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
my @phones;
unless ($res->fault) {
	@phones = $res->valueof('//listPhoneResponse/return/phone');
	print "Total number of found phones: ".($totalPhones=scalar(@phones))."\n";
	foreach (@phones){
		print $_->{name}." : ";
		print $_->{product}." : ";
		print $_->{class}." : ";
		print $_->{protocol}." \n";
	} 
} else {

}

my $numberChunks = int($totalPhones / $RISmaxPhones);

print "Total number of chunks is $numberChunks\n";

# Query risDB about the phones

$cm = new SOAP::Lite
         encodingStyle => '',
	 on_action     => (sub {return "CUCM:DB ver=$ver"}),
	 proxy         => "https://$cucmip:$axlport/realtimeservice/services/RisPort",
	 service       => $ristoolkit, 
	 ns            => $RISnamespace;


my @chunks;
push @chunks, [splice @phones,0,$RISmaxPhones] while @phones;

print " &&& Phones into chunks &&& \n";

# Build request

print "Created chunks: ".scalar(@chunks)."\n\n";
my $i=1;
my @phoneList;
my @IPphoneList;
for my $chunk (@chunks) {
	print "===== CHUNK: $i ====\n\n";
	for my $phone (@$chunk) {
		push @phoneList, $phone->{name};
	}
	my @selection=();
	my $sel;
	foreach (@phoneList){
		$sel = SOAP::Data->name("SelectItem" => \SOAP::Data->value(SOAP::Data->name("Item" => "$_")));
		push (@selection, $sel)
	}
	

	my $res = $cm->SelectCmDevice(SOAP::Data->name("CmSelectionCriteria" => \SOAP::Data->value(SOAP::Data->name("Status"      => "Registered"),
	                                                                                           SOAP::Data->name("SelectBy"    => "Name"),
				                                                                   SOAP::Data->name("SelectItems" => \@selection), 
				                                                                   )
				                      )
			             );
	$i++;
	unless ($res->fault){
		my @resNode =$res->valueof('//SelectCmDeviceResponse/SelectCmDeviceResult/CmNodes/item');
#		dump (@resNode);
#		exit 0;
		foreach (@resNode['CmDevices']) {
			#if (ref($_) eq "HASH") { push @IPphoneList,@$_ };
			dump($_);
		}
	} else {
        	print "Code   : ".$res->faultcode."\n";
	        print "Message: ".$res->faultstring." \n";	
	}
}

dump(@IPphoneList);
