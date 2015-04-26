#!/usr/bin/env perl
#

use strict;
use warnings;
use Data::Dumper +qw(Dumper);


my %phones = (
	369   => {model =>'7906', res =>'95x34x1'},
	307   => {model =>'7911', res =>'95x34x1'},
	434   => {model =>'7942', res =>'320x196x4'},
	435   => {model =>'7945', res =>'320x212x16'},
	404   => {model =>'7962', res =>'320x212x16'},
	436   => {model =>'7965', res =>'320x196x4'},
	30006 => {model =>'7970', res =>'320x212x12'},
	119   => {model =>'7971', res =>'320x212x12'},
	437   => {model =>'7975', res =>'320x216x16'},
	302   => {model =>'7985', res =>'800x600x16'},
	36217 => {model =>'8811', res =>'800x480x24'},
	683   => {model =>'8841', res =>'800x480x24'},
	684   => {model =>'8851', res =>'800x480x24'},
	685   => {model =>'8861', res =>'800x480x24'},
	586   => {model =>'8941', res =>'640x380x24'},
	585   => {model =>'8945', res =>'640x380x24'},
	540   => {model =>'8961', res =>'640x380x24'},
	537   => {model =>'9951', res =>'640x380x24'},
	493   => {model =>'9971', res =>'640x380x24'},
);

my $phoneID = $ARGV[0] or die ('Requires at least one argument!');

if (!exists $phones{$phoneID}) {
	print "Phone ID '$phoneID' is unknown. Skipping\n";
} else {
	printf "Selected resolution for '%s' is '%s'\n",$phones{$phoneID}{model},$phones{$phoneID}{res};
}
