#!/usr/bin/env perl

use Data::Dumper;


my %hash=(
	0 => 1234789,
	1 => 1234883,
	2 => 1234012,
	3 => 1221222,
);

print Dumper(\%hash);

# Method 1. Only works in Windows

print "Method 1:\n";

my @keys = sort { $hash{$a} <=> $hash{$b} } keys %hash;

print Dumper(\@keys);

foreach my $item ( @keys ) {
	print "Item=$item Epoch=$hash{$item} \n";
}

