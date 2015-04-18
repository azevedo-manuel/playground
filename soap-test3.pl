#!/usr/bin/env  perl

use strict;
use warnings;
use Text::CSV;
use LWP::UserAgent;
use LWP::Protocol::https;
use HTTP::Request;
use MIME::Base64;
use XML::LibXML;

#username und password for CUCM
my $encoded = encode_base64('axluser:alxpassword');
#URL of AXL service
my $cucmAxlUrl = 'https://10.1.1.70:8443/axl/';

my $soapAction = "\"CUCM:DB ver=9.1 listLine\"";

my $message;
my $userAgent;
my $request;
my $response;

#deactivate certificate validation
$userAgent = LWP::UserAgent->new(
	agent => 'perl post',
	ssl_opts => { SSL_verify_mode => 'SSL_VERIFY_NONE' },
);

$userAgent->add_handler("request_send",  sub { shift->dump(maxlength=>0); return });
$userAgent->add_handler("response_done", sub { shift->dump(maxlength=>0); return });

# Example for listing a line
$message = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:axl="http://www.cisco.com/AXL/API/9.1">
   <soapenv:Header/>
   <soapenv:Body>
      <axl:listLine sequence="?">
        <searchCriteria>
          <pattern>2001</pattern>
        </searchCriteria>
        <returnedTags>
          <pattern/>
          <description/>
          <usage/>
          <routePartitionName/>
        </returnedTags>
    </axl:listLine>
   </soapenv:Body>
</soapenv:Envelope>';

#generate HTTP request and header
$request = HTTP::Request->new('POST', $cucmAxlUrl);
$request->protocol('HTTP/1.1');
$request->header('Content-Type' => 'text/xml; charset=utf-8',
         	 'SOAPAction' => $soapAction,
		 Authorization => "Basic $encoded",
		 Host => "10.1.1.70:8443");
$request->content($message);
#send HTTP request
$response = $userAgent->request($request);


#extract xml from the response
my $xmldoc = XML::LibXML->load_xml(string => $response->decoded_content) or die "error with xml";
#use xpath syntax to find the results
print $xmldoc->findnodes('//pattern/text()') . "\n";
print $xmldoc->findnodes('//description/text()') . "\n";
print $xmldoc->findnodes('//usage/text()') . "\n";
print $xmldoc->findnodes('//routePartitionName/text()') . "\n";
