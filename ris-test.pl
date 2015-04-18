#!/usr/bin/env perl
#

use warnings;
use strict;
use SOAP::Lite  +trace => 'debug';
use Data::Dumper;
use MIME::Base64;

my $cucmip = "10.1.1.70";
my $axl_port = "8443";
my $user = "axl";
my $password = "axl";
my $axltoolkit = "AXLAPI.wsdl";

$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

#BEGIN {
#	sub SOAP::Transport::HTTP::Client::get_basic_credentials {
#		return ($user => $password)
#	};
#}
		
my $cm = new SOAP::Lite
	 encodingStyle => '',
         uri => "$axltoolkit",
	 proxy => "https://$cucmip:$axl_port/axl/";

$cm = Login($cm,$user,$password);

#axl request
my $res =  $cm->getUser(SOAP::Data->name("userid" => "imguser"));
unless ($res->fault) {
	print $res->valueof('//getUserResponse/return/user/telephoneNumber');
	print "\n";
} else {
	print join ', ',
		   $res->faultcode,
		   $res->faultstring;
}                               

################################################

sub Login {
	$cm->transport->http_request->header (
		'Authorization' => 'Basic ' . encode_base64("$user:$password", '')
	);

	return $cm;
}
################################################### 
