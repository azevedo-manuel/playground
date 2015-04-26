#!/usr/bin/env perl
#

use strict;
require LWP::UserAgent;
require XML::Bare;
use Data::Dump qw(dump);

my $bkgURL   = "http://10.1.1.70:6970/Desktops/320x212x16/7965-cabo-espichel.png";
my $bkgThn   = "http://10.1.1.70:6970/Desktops/320x212x16/7965-cabo-espichel-tn.png";
my $phoneIP  = "10.1.1.103";
my $user     = "imguser";
my $password = "imgpassword";

#
# function setBackground
# 
# Pushes the configuration to the phone and returns either an error or a sucess response status
#
# Usage:
# ($error,$response) = setBackground ($username,$password,$phoneIP,$bkgURL,$bkgThn)
#
# where:
# $username and $password are from CUCM's End User that has both phones associated with
# $phoneIP is the IP address of the web and customization enabled phone 
# $bkgURL is the background image URL. 
# $bkgThn is the background image thumbnail URL.
#
# The function returns $error and $response. If $error is defined then the background push failed for some reason
sub setBackground {
	
	my $user    =@_[0];
	my $password=@_[1];
	my $phoneIP =@_[2];
	my $bkgURL  =@_[3];
	my $bkgThn  =@_[4];
	my $error;
	my $response;

	# This XML request is pushed to the Phone
	my $setBkgXML = "<setBackground><background><image>$bkgURL</image><icon>$bkgThn</icon></background></setBackground>";
	my $phoneWeb  = "http://$phoneIP/CGI/Execute";

	# Create new connection
	my $ua = LWP::UserAgent->new();

	# Phone's will query CUCM for authorization. 
   	$ua->credentials("$phoneIP:80","user",$user,$password);
	# Timeout was lowered from 300s to 5s
	$ua->timeout(7);

	# Use HTTP post to send the 'XML' parameter to the phone
   	my $post = $ua->post($phoneWeb, {'XML' => $setBkgXML} );

	# Test if the answer from the HTTP connection is OK.
	# This does not yet mean the phone background was set, but could indicated the phone's web-service is not enabled
	# or the phone is not reachable.
	if ($post->is_success){

		# HTTP request was a sucess. Let's decode the phone's answer
		my $content = $post->decoded_content();

		# Usually the phone answers with a XML response. Let's decode it.
		my $xmlObj = new XML::Bare (text=>$content);
		my $xmlAns = $xmlObj->parse();

		# If there was an error setting the image, the phone returns this value
		$error=$xmlAns->{CiscoIPPhoneError}->{Number}->{value};
		# If the background was correctly pushed, the phone will answer in this value
		$response=$xmlAns->{CiscoIPPhoneResponse}->{ResponseItem}->{Data}->{value};
	} else {
		# There was an HTTP error. Report the error
		$error = $post->status_line;
	}
	# Return data to caller
	return($error,$response);

}

my $error;
my $response;

($error,$response) = setBackground($user,$password,$phoneIP,$bkgURL,$bkgThn);

if ($error){
	print "IP Phone error: $error\n"
} else {
	print "Response: $response\n";
}

