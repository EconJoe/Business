
#!/usr/bin/perl -w
use strict;
use warnings;
use LWP::Simple;

my $inpath = "B:\\Business\\Data\\GenderPrediction";
open (INFILE, "<$inpath\\ohio_firstnamelist.txt") or die "Can't open subjects file: ohio_firstnamelist.txt";

my $outpath = "B:\\Business\\Data\\GenderPrediction\\BabyNameGuesser";
open (OUTFILE, ">$outpath\\BNG_OhioHarvest.txt") or die "Can't open subjects file: BNG_OhioHarvest.txt";
print OUTFILE "first_name	gender\n";

my $counter=0;
while (<INFILE>) {

  if (/(.*)\n/) {

    my $name=$1;
    $counter++;
    print "$name  ($counter of out 197,184)\n";
    my $url = "http://www.gpeters.com/names/baby-names.php?name=$name&button=Go";
    my $content = get $url;
    die "Couldn't get $url" unless defined $content;
    sleep 1;

    if ($content=~/<b>It's a (.*?)!<\/b>/) {
       my $gender=$1;
       print OUTFILE "$name	$gender\n";
    }
  }
}

close INFILE;
close OUTFILE;
