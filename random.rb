#!/usr/bin/env ruby

unique_id = ('a'..'z').to_a.shuffle[0,8].join
print unique_id+"\n"

another_id = rand(100000000)
print another_id+"\n"

