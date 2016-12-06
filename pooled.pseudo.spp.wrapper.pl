#!/usr/bin/perl
#use strict;
use warnings;
use Data::Dumper;

unless ($#ARGV == 0) {print "Usage: chipseq.pl < path >\n";exit;}

my $data_dir = $ARGV[0];
my $scripts_dir = "/home/strickt2/scripts/shell/";
my $run_spp = "/home/strickt2/SEQanalysis/phantompeakqualtools/run_spp.R";

my %chip;
my %zcat;
my $file = "/home/strickt2/filelists/luigi.sample.list.txt";
open(AA, "$file")||die "Can't open $file!";
while(<AA>){
    chomp $_;
 
    my @temp = split(/\t/, $_);
    my $condition = join '', $temp[2], $temp[3],$temp[4];
    $chip{$temp[0]}{COND}=$condition;
    $chip{$temp[0]}{INPUT}=$temp[5];
    $chip{$temp[0]}{NAME}=$temp[1];
    push @{$zcat{$condition}}, $temp[0];
}

print Dumper \%zcat;
print Dumper \%chip;


my @files = `find $ARGV[0] -name '*tagAlign.gz'`;
#print Dumper \@files;


my %fin;
foreach my $i (0..$#files){
    chomp $files[$i];
    unless ($files[$i]=~/TPS/){
	my @temp = split(/\//,$files[$i]);
	my @name = split('\.', $temp[$#temp]);

	$fin{$name[0]} = $files[$i];
    }
}
print Dumper \%fin;


#`mkdir $data_dir/filter/`;
foreach my $foo (keys %zcat){
    print "$foo\n";
    #unless ($foo =~ /TPS-280/){
    my $output_script = $scripts_dir.$foo.".spp.pseudo.sh";
    open (OUT, ">$output_script")||die "Can't open $output_script!";
    my $email = "thomas.stricker\@vanderbilt.edu";
    print OUT "\#\!\/bin\/bash\n\#SBATCH --mail-user=$email\n\#SBATCH --mail-type=ALL\n\#SBATCH --nodes=1\n\#SBATCH --ntasks=1\n\#SBATCH --mem=10000mb\n\#SBATCH --time=96:00:00\n\#SBATCH -o /home/strickt2/log/$foo.pseudo.log\n";
    my $out = $data_dir."/".$foo;
    my $pool = $out."/".$foo.".pooled.tagAlign.gz";

    my $out = $data_dir."/".$foo;
    my $out1 = $out."00";
    my $out2 = $out."01";
    my $out_dir = $data_dir."/".$foo."pooledPseudo/";
    #`mkdir $out_dir`;
    my $pool = $out."/".$foo.".pooled.tagAlign.gz";
    print OUT "setpkgs -a R\n";
    #print " \$nlines = (zcat -f $fin{$foo} | wc -l)\n";
    my $nlines = `zcat -f $pool | wc -l`;
    my $nlines1 = ($nlines+1)*"0.5";
    my $nlines2 =  sprintf("%.0f", $nlines1);
    print "$nlines2\t$nlines1\t$nlines\n";
    #my $nlines = 5000;
    print OUT "zcat $fin{$foo} | shuf | split -d -l $nlines2 - $out\n";
    print OUT "gzip $out1\n";
    print OUT "gzip $out2\n";
    print OUT "mv $out1.gz $out.pr1.tagAlign.gz\n";
    print OUT "mv $out2.gz $out.pr2.tagAlign.gz\n";
    print OUT "Rscript $run_spp -c=$out.pr1.tagAlign.gz -i=$chip{$zcat{$foo}[0]}{INPUT} -npeak=300000 -odir=$out_dir -savr -savp -rf\n";  
    print OUT "Rscript $run_spp -c=$out.pr2.tagAlign.gz -i=$chip{$zcat{$foo}[0]}{INPUT} -npeak=300000 -odir=$out_dir -savr -savp -rf\n";
  `sbatch $output_script`;
   # }
}



