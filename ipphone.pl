#!/usr/bin/env perl

use strict;
use Data::Dumper qw(Dumper);

my %phone = (
    '7906' => {mid => 369, res => "95x34x1"},
    '7911' => {mid => 307, res => "95x34x1"}
);

print Dumper (\%phone);


print "Model ".$phone{7906}{mid}."\n";