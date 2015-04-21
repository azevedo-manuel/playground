#!/usr/bin/env perl
#

#use warnings;
use strict;
use SOAP::Lite;#+trace => 'debug';
use Data::Dump qw(dump);
use LWP::UserAgent;
use Net::Ping;
use XML::Simple;

my $cucmip               = "10.1.1.70";
my $axlport              = "8443";
my $user                 = "axluser";
my $password             = "axlpassword";
my $axltoolkit           = "AXLAPI.wsdl";
my $ristoolkit           = "file:./risdb/RisPort.wsdl";
my $ver                  = "8.5";
my $AXLnamespace         = "http://www.cisco.com/AXL/API/$ver";
my $RISnamespace         = "http://schemas.cisco.com/ast/soap/";
my $RISmaxPhones         = 200;
my $PhoneNamePattern     = "SEP%";
my $delayBetweenRequests = 1;

# Disable in case it complains about the certificate! Remember to put as a parameter
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

*SOAP::Deserializer::typecast = sub {shift; return shift};

BEGIN {
	sub SOAP::Transport::HTTP::Client::get_basic_credentials {
		return ($user => $password)
	};
}

# Create an AXL request 

print "** Querying AXL database for all phones starting with \'$PhoneNamePattern\'\n";

my $cm = new SOAP::Lite
	encodingStyle => '',
	on_action     => (sub {return "CUCM:DB ver=$ver"}),
	proxy         => "https://$cucmip:$axlport/axl/",
	ns            => $AXLnamespace;

# Build the request

my $res = $cm->listPhone(SOAP::Data->name("searchCriteria" => \SOAP::Data->value(SOAP::Data->name("name"         => $PhoneNamePattern)),
										 SOAP::Data->name("returnedTags" => \SOAP::Data->value( SOAP::Data->name("name"        => "?"),
																 	SOAP::Data->name("description" => "?"),
																	SOAP::Data->name("product"     => "?"),
																	SOAP::Data->name("model"       => "?"),
																	SOAP::Data->name("class"       => "?"),
																	SOAP::Data->name("protocol"    => "?")
																	)
												 )
					)
);

sleep ($delayBetweenRequests);

my $totalPhones;
my @phones;
unless ($res->fault) {
	@phones = $res->valueof('//listPhoneResponse/return/phone');
	print "Total number of configured phones found: ".($totalPhones=scalar(@phones))."\n\n";
	foreach (@phones){
		print $_->{name}." : ";
		print $_->{product}." : ";
		print $_->{class}." : ";
		print $_->{protocol}." \n";
	}
} else {
	print "Code   : ".$res->faultcode."\n";
	print "Message: ".$res->faultstring." \n";
}

print "\n\n";

# Query risDB about the phones

print "** Querying RISDB for registered phones \n";

$cm = new SOAP::Lite
	encodingStyle => '',
	on_action     => (sub {return "CUCM:DB ver=$ver"}),
	proxy         => "https://$cucmip:$axlport/realtimeservice/services/RisPort",
	service       => $ristoolkit,
	ns            => $RISnamespace;


my @chunks;
push @chunks, [splice @phones,0,$RISmaxPhones] while @phones;


# Build request

my $numberChunks = scalar(@chunks);
print "Created $numberChunks chunk(s) with a maximum of $RISmaxPhones phones (each).\n\n";
my $i=1;
my @phoneList;
my @IPphoneList;
my @RegisteredPhones;

for my $chunk (@chunks) {
	print "=> Getting chunk: $i ====>\n";
	@phoneList = ();
	for my $phone (@$chunk) {
		push @phoneList, $phone->{name};
	}
	my @selection=();
	my $sel;
	foreach (@phoneList){
		$sel = SOAP::Data->name("SelectItem" => \SOAP::Data->value(SOAP::Data->name("Item" => "$_")));
		push (@selection, $sel);
	}
	

	my $res = $cm->SelectCmDevice(SOAP::Data->name("CmSelectionCriteria" => \SOAP::Data->value(SOAP::Data->name("Status"      => "Registered"),
												   SOAP::Data->name("SelectBy"    => "Name"),
												   SOAP::Data->name("SelectItems" => \@selection),
												  )
						      )
	);
	unless ($res->fault){
		my @resNode =$res->valueof('//SelectCmDeviceResponse/SelectCmDeviceResult/CmNodes/item/CmDevices/item');
		foreach (@resNode) {
			push @RegisteredPhones, $_->{IpAddress};
			printf "%-15s : %-30s : %-15s : %-30s : %-10s : %d : %d : %-10s \n", $_->{Name},
											     $_->{Description},
											     $_->{IpAddress},
											     $_->{DirNumber},
											     $_->{Class},
											     $_->{Model},
											     $_->{Product},
											     $_->{Status};
		}
	} else {
		print "Code   : ".$res->faultcode."\n";
		print "Message: ".$res->faultstring." \n";
	}
	$i++;
	sleep ($delayBetweenRequests);
}


print "\n\n";
print "** Checking if phone is alive and get XML data from phone\n";

foreach (@RegisteredPhones){
	my $ua = LWP::UserAgent->new;
	my $response = $ua->get("http://$_/DeviceInformationX");
	if ($response->is_success) {
		my $xml = new XML::Simple;
		my $phoneData = $xml->XMLin($response->decoded_content);
		printf " %-12s : %-15s : %-15s : %-20s : %-15s : %-20s \n", $phoneData->{MACAddress},
									    $phoneData->{HostName},
									    $phoneData->{phoneDN},
									    $phoneData->{versionID},
									    $phoneData->{serialNumber},
									    $phoneData->{modelNumber};
	} else {
		print "Could not be reached through HTTP: $response->status_line\n";
	}
}
