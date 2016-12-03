
#!/usr/bin/perl -w
use strict;
use warnings;
use LWP::Simple;

my $path = "B:\\Business\\Data\\BabyNameGuesser";
open (INFILE, "<$path\\genni_firstnamelist.txt") or die "Can't open subjects file: genni_firstnamelist.txt";
open (OUTFILE, ">$path\\BNG_Harvest.txt") or die "Can't open subjects file: BNG_Harvest.txt";

while (<INFILE>) {
  
  if (/(.*)\n/) {

    my $name=$1;
    print "$name\n";
    my $url = "http://www.gpeters.com/names/baby-names.php?name=$name&button=Go";
    my $content = get $url;
    die "Couldn't get $url" unless defined $content;
    sleep 1.5;

    if ($content=~/<b>It's a (.*?)!<\/b>/) {
       my $gender=$1;
       print OUTFILE "$name 	$gender\n";
    }
  }
}

close INFILE;
close OUTFILE;
