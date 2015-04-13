  #!/usr/bin/perl
  use v5.14;

  open(GRADES, "<:utf8", "grades")  || die "Can't open grades: $!\n";
  binmode(STDOUT, ':utf8');

  my %grades;
  while (my $line = <GRADES>) {
      my ($student, $grade) = split(" ", $line);
      $grades{$student} .= $grade . " ";
  }

  for my $student (sort keys %grades) {






      }
      my $average = $total / $scores;
      print "$student: $grades{$student}\tAverage: $average\n";
 }