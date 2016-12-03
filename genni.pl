
#!/usr/bin/perl -w
use strict;
use warnings;
use LWP::Simple;

my $path = "B:\\Business\\Data\\Genni";
open (INFILE, "<$path\\genni_firstnamelist.txt") or die "Can't open subjects file: genni_firstnamelist.txt";
open (OUTFILE, ">$path\\Genni_Harvest.txt") or die "Can't open subjects file: Genni_Harvest.txt";

while (<INFILE>) {
  
  if (/(.*)\n/) {

    my $name=$1;
    print "$name\n";
    my $url = "http://abel.lis.illinois.edu/cgi-bin/genni/nameprediction.cgi?name=$name";
    my $content = get $url;
    die "Couldn't get $url" unless defined $content;
    sleep 1.5;

    if ($content=~/<p>Based on the current population distribution, there is a <b>(.*?)%<\/b> chance that a living person named <b>(.*?)<\/b> is <b>(.*?)<\/b>/) {
       my $percent=$1;
       my $name=$2;
       my $gender=$3;
       print OUTFILE "$name 	$gender	$percent\n";
    }
  }
}

close INFILE;
close OUTFILE;
